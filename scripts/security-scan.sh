#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TERRAFORM_DIR="${PROJECT_ROOT}/terraform"
POLICY_DIR="${PROJECT_ROOT}/policies"
GENERATED_DIR="${PROJECT_ROOT}/.generated"
REPORT_DIR="${PROJECT_ROOT}/reports"
PLAN_FILE="${GENERATED_DIR}/tfplan"
PLAN_JSON="${GENERATED_DIR}/tfplan.json"
REPORT_JSON="${REPORT_DIR}/policy-report.json"

for command in terraform opa jq; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "Required command not found: ${command}" >&2
    exit 127
  fi
done

mkdir -p "${GENERATED_DIR}" "${REPORT_DIR}"

echo "[1/6] Checking Terraform formatting"
terraform -chdir="${TERRAFORM_DIR}" fmt -check -recursive

echo "[2/6] Initializing Terraform"
terraform -chdir="${TERRAFORM_DIR}" init -backend=false -input=false

echo "[3/6] Validating Terraform"
terraform -chdir="${TERRAFORM_DIR}" validate

echo "[4/6] Building an offline Terraform plan"
terraform -chdir="${TERRAFORM_DIR}" plan \
  -refresh=false \
  -input=false \
  -out="${PLAN_FILE}"

echo "[5/6] Exporting the plan as JSON"
terraform -chdir="${TERRAFORM_DIR}" show -json "${PLAN_FILE}" >"${PLAN_JSON}"

echo "[6/6] Evaluating OPA policies"
opa eval \
  --format raw \
  --data "${POLICY_DIR}" \
  --input "${PLAN_JSON}" \
  'json.marshal(data.terraform.security.deny)' >"${REPORT_JSON}"

violation_count="$(jq 'length' "${REPORT_JSON}")"

if ((violation_count > 0)); then
  echo
  echo "Policy gate failed with ${violation_count} violation(s):"
  jq -r '.[] | "- [\(.code)] \(.resource): \(.message)"' "${REPORT_JSON}"
  exit 1
fi

echo
echo "Policy gate passed: no violations found."
echo "Plan:   ${PLAN_JSON}"
echo "Report: ${REPORT_JSON}"
