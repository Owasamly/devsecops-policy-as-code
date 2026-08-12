package terraform.security_test

import data.terraform.security.deny
import rego.v1

test_secure_plan_has_no_violations if {
	violations := deny with input as data.secure_plan
	count(violations) == 0
}

test_insecure_plan_has_expected_violations if {
	violations := deny with input as data.insecure_plan
	count(violations) == 5
	{violation.code | some violation in violations} == {
		"NETWORK_WORLD_INGRESS",
		"S3_ENCRYPTION_REQUIRED",
		"S3_PUBLIC_ACCESS_BLOCK_REQUIRED",
		"S3_REQUIRED_TAGS",
		"S3_VERSIONING_REQUIRED",
	}
}

test_each_violation_is_structured if {
	violations := deny with input as data.insecure_plan
	every violation in violations {
		is_string(violation.code)
		is_string(violation.resource)
		is_string(violation.message)
	}
}
