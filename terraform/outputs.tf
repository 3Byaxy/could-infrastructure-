# =============================================================================
# outputs.tf — Output Value Definitions
# =============================================================================
# Outputs expose selected resource attributes after a successful apply.
# They can be consumed by other Terraform configurations via remote state.
# =============================================================================

output "s3_bucket_name" {
  description = "The name of the provisioned S3 bucket."
  value       = aws_s3_bucket.main.bucket
}

output "s3_bucket_arn" {
  description = "The ARN of the provisioned S3 bucket."
  value       = aws_s3_bucket.main.arn
}

output "aws_region" {
  description = "The AWS region where resources were provisioned."
  value       = var.aws_region
}

output "environment" {
  description = "The deployment environment."
  value       = var.environment
}
