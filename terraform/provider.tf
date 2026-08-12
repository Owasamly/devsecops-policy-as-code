provider "aws" {
  region     = var.aws_region
  access_key = "test"
  secret_key = "test"

  endpoints {
    ec2 = var.localstack_endpoint
    iam = var.localstack_endpoint
    s3  = var.localstack_endpoint
  }

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}
