# =============================================================================
# Cloud Infrastructure - Terraform Variables
# =============================================================================
# Variables make your code reusable! Instead of hardcoding values,
# define them here and override them per environment.
#
# BEGINNER TIP: Copy example.tfvars to terraform.tfvars and fill in your values.
# =============================================================================

variable "project_name" {
  description = "A short name for your project. Used in resource names."
  type        = string
  default     = "cloud-infra"

  validation {
    condition     = length(var.project_name) <= 20
    error_message = "Project name must be 20 characters or fewer."
  }
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g. 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance. Use Amazon Linux 2023 for the chosen region."
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux 2023 (us-east-1) - update for your region
}

variable "instance_type" {
  description = "EC2 instance type. t2.micro is free-tier eligible!"
  type        = string
  default     = "t2.micro"
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH to the instance. Restrict this to your IP!"
  type        = list(string)
  default     = ["0.0.0.0/0"] # WARNING: Change this to your IP in production
}
