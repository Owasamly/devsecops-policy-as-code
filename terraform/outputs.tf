output "application_bucket" {
  description = "Name of the policy-compliant S3 bucket."
  value       = aws_s3_bucket.application_data.id
}

output "application_security_group" {
  description = "ID of the restricted application security group."
  value       = aws_security_group.application.id
}

output "policy_controls" {
  description = "Security controls demonstrated by this configuration."
  value = [
    "server-side encryption",
    "public access blocking",
    "versioning",
    "required ownership tags",
    "restricted ingress",
  ]
}
