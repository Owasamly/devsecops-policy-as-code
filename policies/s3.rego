package terraform.security


deny contains msg if {

    resource := input.resource_changes[_]

    resource.type == "aws_s3_bucket"


    not resource.change.after.server_side_encryption_configuration


    msg := sprintf(
        "S3 bucket %s has no encryption",
        [resource.change.after.bucket]
    )

}



deny contains msg if {

    resource := input.resource_changes[_]


    resource.type == "aws_s3_bucket_public_access_block"


    resource.change.after.block_public_acls == false


    msg := "S3 bucket allows public ACL access"

}



deny contains msg if {

    resource := input.resource_changes[_]


    resource.type == "aws_s3_bucket_versioning"


    resource.change.after.versioning_configuration[0].status != "Enabled"


    msg := "S3 bucket versioning must be enabled"

}