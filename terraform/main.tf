# =============================================================================
# main.tf — AWS Provider and Core Resource Definitions
# =============================================================================
# This file configures the Terraform AWS provider and defines the primary
# cloud resources for the project.
# =============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS provider using variables defined in variables.tf
provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# Example resource: S3 bucket for storing Terraform state or application data
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "main" {
  bucket = "${var.project_name}-${var.environment}-bucket"

  tags = {
    Name        = "${var.project_name}-${var.environment}-bucket"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Block all public access to the S3 bucket for security
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
