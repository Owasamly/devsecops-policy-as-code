SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

.PHONY: help fmt validate policy-test scan demo-fail localstack-up localstack-down apply verify destroy clean

help: ## Show available commands.
	@awk 'BEGIN {FS = ":.*## "; printf "Available targets:\n"} /^[a-zA-Z_-]+:.*## / {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

fmt: ## Format Terraform and Rego files.
	terraform -chdir=terraform fmt -recursive
	opa fmt --write policies tests/opa

validate: ## Initialize and validate Terraform.
	terraform -chdir=terraform init -backend=false -input=false
	terraform -chdir=terraform validate

policy-test: ## Run OPA policy unit tests.
	opa check --strict policies tests/opa
	opa test policies tests/opa tests/fixtures -v

scan: ## Generate a Terraform plan and enforce every policy.
	./scripts/security-scan.sh

demo-fail: ## Evaluate the intentionally insecure plan fixture.
	@jq '.insecure_plan' tests/fixtures/insecure-plan.json | opa eval --stdin-input --format pretty --data policies 'data.terraform.security.deny'
	@test "$$(jq '.insecure_plan' tests/fixtures/insecure-plan.json | opa eval --stdin-input --format raw --data policies 'count(data.terraform.security.deny)')" -eq 5

localstack-up: ## Start LocalStack and wait until it is healthy.
	docker compose up -d --wait

localstack-down: ## Stop the LocalStack service.
	docker compose down

apply: localstack-up scan ## Apply the policy-approved Terraform plan locally.
	terraform -chdir=terraform apply -input=false ../.generated/tfplan

verify: ## Query LocalStack to prove the controls were applied.
	./scripts/verify-localstack.sh

destroy: ## Destroy the local lab resources.
	terraform -chdir=terraform destroy -auto-approve -input=false

clean: ## Remove generated plans and reports.
	rm -rf .generated reports
