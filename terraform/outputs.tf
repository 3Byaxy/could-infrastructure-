# =============================================================================
# File: terraform/outputs.tf
# Language: HCL (HashiCorp Configuration Language) — Terraform
# What it does: Defines the values Terraform will print after a successful
#               deployment so you can quickly find your resource details.
# Maintainer: @3Byaxy
# =============================================================================

# Print the public IP address of the EC2 web server.
# You can paste this into your browser to visit the web page!
output "ec2_public_ip" {
  description = "The public IP address of the EC2 web server"
  value       = aws_instance.web.public_ip
}

# Print the public DNS hostname of the EC2 instance.
output "ec2_public_dns" {
  description = "The public DNS hostname of the EC2 web server"
  value       = aws_instance.web.public_dns
}

# Print the unique ID of the VPC that was created.
output "vpc_id" {
  description = "The ID of the VPC created for this project"
  value       = aws_vpc.main.id
}

# Print the name of the S3 bucket so you can easily reference it.
output "s3_bucket_name" {
  description = "The name of the S3 bucket used for asset storage"
  value       = aws_s3_bucket.main.bucket
}

# Print the ARN (Amazon Resource Name) of the S3 bucket.
# ARNs are unique identifiers used in AWS policies and permissions.
output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}
