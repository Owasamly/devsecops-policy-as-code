locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }
}
