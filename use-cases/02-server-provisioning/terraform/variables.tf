variable "aws_region" {
  description = "AWS region to launch the EC2 instance in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used to name all created resources"
  type        = string
  default     = "cloud-infra"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "public_key_path" {
  description = "Path to the SSH public key file (e.g. ~/.ssh/id_rsa.pub)"
  type        = string
}

variable "environment" {
  description = "Deployment environment tag"
  type        = string
  default     = "dev"
}
