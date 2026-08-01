provider "aws" {

  region = "us-east-1"

  access_key = "test"

  secret_key = "test"


  endpoints {

    s3 = "http://localhost:5566"

    iam = "http://localhost:5566"

  }

  s3_use_path_style = true

  skip_credentials_validation = true

  skip_metadata_api_check = true

  skip_requesting_account_id = true

}