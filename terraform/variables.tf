variable "aws_region" {
  description = "AWS region emulated by LocalStack."
  type        = string
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  description = "LocalStack edge endpoint used by the AWS provider."
  type        = string
  default     = "http://localhost:4566"

  validation {
    condition     = startswith(var.localstack_endpoint, "http://") || startswith(var.localstack_endpoint, "https://")
    error_message = "localstack_endpoint must be an HTTP or HTTPS URL."
  }
}

variable "environment" {
  description = "Environment tag applied to managed resources."
  type        = string
  default     = "development"
}

variable "owner" {
  description = "Owner tag applied to managed resources."
  type        = string
  default     = "Osama"
}

variable "bucket_name" {
  description = "Globally unique name for the demonstration S3 bucket."
  type        = string
  default     = "devsecops-policy-demo"

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "bucket_name must contain between 3 and 63 characters."
  }
}

variable "management_cidr" {
  description = "Trusted network allowed to reach the application security group over HTTPS."
  type        = string
  default     = "10.0.0.0/8"

  validation {
    condition     = can(cidrhost(var.management_cidr, 0)) && !contains(["0.0.0.0/0", "::/0"], var.management_cidr)
    error_message = "management_cidr must be a valid, restricted CIDR block."
  }
}
