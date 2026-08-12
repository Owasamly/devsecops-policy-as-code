#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TERRAFORM_DIR="${PROJECT_ROOT}/terraform"

for command in aws terraform; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "Required command not found: ${command}" >&2
    exit 127
  fi
done

endpoint="${LOCALSTACK_ENDPOINT:-http://localhost:4566}"
bucket="$(terraform -chdir="${TERRAFORM_DIR}" output -raw application_bucket)"
security_group="$(terraform -chdir="${TERRAFORM_DIR}" output -raw application_security_group)"

# LocalStack accepts these conventional development credentials. They are scoped
# to this process so the script never reads or modifies the user's AWS profile.
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
aws_args=(--endpoint-url "${endpoint}" --region "${AWS_DEFAULT_REGION}")

echo "S3 encryption"
aws "${aws_args[@]}" s3api get-bucket-encryption --bucket "${bucket}"

echo "S3 public-access block"
aws "${aws_args[@]}" s3api get-public-access-block --bucket "${bucket}"

echo "S3 versioning"
aws "${aws_args[@]}" s3api get-bucket-versioning --bucket "${bucket}"

echo "S3 tags"
aws "${aws_args[@]}" s3api get-bucket-tagging --bucket "${bucket}"

echo "Security-group rules"
aws "${aws_args[@]}" ec2 describe-security-groups --group-ids "${security_group}"

echo "LocalStack verification passed."
