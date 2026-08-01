package terraform.security

# Every planned S3 bucket must have an encryption configuration resource.
deny contains msg if {
    bucket := input.resource_changes[_]
    bucket.type == "aws_s3_bucket"

    not encryption_configuration_exists

    msg := sprintf(
        "S3 bucket %s has no encryption configuration",
        [bucket.change.after.bucket]
    )
}

encryption_configuration_exists if {
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    algorithm := encryption.change.after.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm
    algorithm == "AES256"
}

# All four S3 public-access controls must be enabled.
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"

    not resource.change.after.block_public_acls

    msg := "S3 bucket must block public ACLs"
}

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"

    not resource.change.after.block_public_policy

    msg := "S3 bucket must block public bucket policies"
}

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"

    not resource.change.after.ignore_public_acls

    msg := "S3 bucket must ignore public ACLs"
}

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"

    not resource.change.after.restrict_public_buckets

    msg := "S3 bucket must restrict public buckets"
}

# Versioning must be enabled.
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_versioning"

    resource.change.after.versioning_configuration[0].status != "Enabled"

    msg := "S3 bucket versioning must be enabled"
}