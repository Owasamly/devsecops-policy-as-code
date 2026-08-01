resource "aws_s3_bucket" "application_bucket" {

  bucket = "company-app-data"

}


resource "aws_s3_bucket_public_access_block" "public_access" {

  bucket = aws_s3_bucket.application_bucket.id

  block_public_acls = false

  block_public_policy = false

  ignore_public_acls = false

  restrict_public_buckets = false

}


resource "aws_s3_bucket_versioning" "versioning" {

  bucket = aws_s3_bucket.application_bucket.id


  versioning_configuration {

    status = "Disabled"

  }

}


