# =============================================================================
# variables.tf — Input Variable Declarations
# =============================================================================
# Define all configurable input variables for this Terraform configuration.
# Override defaults by creating a terraform.tfvars file or passing -var flags.
# =============================================================================

variable "aws_region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "A short, lowercase name for the project used in resource naming."
  type        = string
  default     = "cloud-infra"
}
