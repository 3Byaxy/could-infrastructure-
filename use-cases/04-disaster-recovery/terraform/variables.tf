variable "aws_region" {
  description = "AWS region for the backup bucket"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "cloud-infra"
}
