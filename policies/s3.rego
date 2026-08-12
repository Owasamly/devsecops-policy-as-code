package terraform.security

import rego.v1

required_tags := {"Environment", "ManagedBy", "Owner"}

deny contains violation if {
	some bucket in active_resource_changes
	bucket.type == "aws_s3_bucket"
	not valid_encryption_for(bucket.address)
	violation := finding(
		"S3_ENCRYPTION_REQUIRED",
		bucket.address,
		"S3 buckets require linked server-side encryption using AES256 or aws:kms",
	)
}

deny contains violation if {
	some bucket in active_resource_changes
	bucket.type == "aws_s3_bucket"
	not valid_public_access_block_for(bucket.address)
	violation := finding(
		"S3_PUBLIC_ACCESS_BLOCK_REQUIRED",
		bucket.address,
		"S3 buckets must enable all four public-access-block settings",
	)
}

deny contains violation if {
	some bucket in active_resource_changes
	bucket.type == "aws_s3_bucket"
	not versioning_enabled_for(bucket.address)
	violation := finding(
		"S3_VERSIONING_REQUIRED",
		bucket.address,
		"S3 bucket versioning must be enabled",
	)
}

deny contains violation if {
	some bucket in active_resource_changes
	bucket.type == "aws_s3_bucket"
	tags := object.get(bucket.change.after, "tags", {})
	some tag in required_tags
	object.get(tags, tag, "") == ""
	violation := finding(
		"S3_REQUIRED_TAGS",
		bucket.address,
		sprintf("S3 bucket is missing required tag %q", [tag]),
	)
}

valid_encryption_for(bucket_address) if {
	some resource in linked_resources(bucket_address, "aws_s3_bucket_server_side_encryption_configuration")
	some rule in object.get(resource.change.after, "rule", [])
	some defaults in object.get(rule, "apply_server_side_encryption_by_default", [])
	object.get(defaults, "sse_algorithm", "") in {"AES256", "aws:kms"}
}

valid_public_access_block_for(bucket_address) if {
	some resource in linked_resources(bucket_address, "aws_s3_bucket_public_access_block")
	after := resource.change.after
	after.block_public_acls == true
	after.block_public_policy == true
	after.ignore_public_acls == true
	after.restrict_public_buckets == true
}

versioning_enabled_for(bucket_address) if {
	some resource in linked_resources(bucket_address, "aws_s3_bucket_versioning")
	some configuration in object.get(resource.change.after, "versioning_configuration", [])
	configuration.status == "Enabled"
}
