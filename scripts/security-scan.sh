#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TERRAFORM_DIR="${PROJECT_ROOT}/terraform"
POLICY_DIR="${PROJECT_ROOT}/policies"

echo "==== Terraform Init ===="
terraform -chdir="${TERRAFORM_DIR}" init -input=false

echo "==== Terraform Plan ===="
terraform -chdir="${TERRAFORM_DIR}" plan \
  -input=false \
  -out=tfplan

echo "==== Terraform JSON Export ===="
terraform -chdir="${TERRAFORM_DIR}" show -json tfplan \
  > "${TERRAFORM_DIR}/tfplan.json"

echo "==== OPA Security Scan ===="

VIOLATIONS="$(
  opa eval \
    --format raw \
    --data "${POLICY_DIR}" \
    --input "${TERRAFORM_DIR}/tfplan.json" \
    'json.marshal(data.terraform.security.deny)'
)"

echo "${VIOLATIONS}"

if [[ "${VIOLATIONS}" != "[]" ]]; then
  echo "Security violations detected. Pipeline blocked."
  exit 1
fi

echo "Security scan passed."