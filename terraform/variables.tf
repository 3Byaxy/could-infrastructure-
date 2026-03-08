# =============================================================================
# File: terraform/variables.tf
# Language: HCL (HashiCorp Configuration Language) — Terraform
# What it does: Defines all the input variables used in main.tf so that the
#               configuration is flexible and reusable across environments.
# Maintainer: @3Byaxy
# =============================================================================

# The AWS region where all resources will be created.
# Example values: "us-east-1", "eu-west-1", "ap-southeast-1"
variable "aws_region" {
  description = "The AWS region to deploy all resources into"
  type        = string
  default     = "us-east-1"
}

# The name of your project — used to label all AWS resources
# so you can easily find them in the AWS console.
variable "project_name" {
  description = "A short name for this project, used to tag and name all resources"
  type        = string
  default     = "cloud-infra"
}

# The deployment environment — helps separate development from production.
# Common values: "dev", "staging", "prod"
variable "environment" {
  description = "The environment this infrastructure belongs to (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"

  # Validation ensures only valid environment names are accepted.
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# The EC2 instance type determines how powerful your server is.
# t2.micro is free-tier eligible — great for learning!
# Larger options: "t3.small", "t3.medium", "t3.large"
variable "instance_type" {
  description = "The EC2 instance type to use for the web server"
  type        = string
  default     = "t2.micro"
}
