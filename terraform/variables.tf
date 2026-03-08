# 📋 TERRAFORM VARIABLES FILE
#
# Variables are like the "settings" of your infrastructure.
# Instead of writing values (like your region or server size) directly in the code,
# we put them here so they're easy to find and change.
#
# 💡 Analogy: Think of variables like the dials and switches on a machine —
# you tweak them to control how the machine works without opening it up!

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VARIABLE: aws_region
# Which AWS data center location should we use?
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
variable "aws_region" {
  description = "The AWS region where resources will be created (e.g. us-east-1 = Virginia)"
  type        = string
  default     = "us-east-1"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VARIABLE: instance_type
# How powerful should our cloud server be?
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
variable "instance_type" {
  description = "The EC2 instance type — controls CPU and RAM (t2.micro is free tier!)"
  type        = string
  default     = "t2.micro"

  # Validation makes sure we only use approved instance sizes.
  # It's like checking that you only buy shirts in allowed sizes!
  validation {
    condition     = contains(["t2.micro", "t2.small", "t2.medium", "t3.micro"], var.instance_type)
    error_message = "Must be one of: t2.micro, t2.small, t2.medium, t3.micro."
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VARIABLE: ami_id
# Which operating system image should the server use?
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
variable "ami_id" {
  description = "The Amazon Machine Image (AMI) ID — the OS for your server. Default: Ubuntu 22.04 in us-east-1"
  type        = string
  default     = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS (us-east-1)
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VARIABLE: environment
# Are we building for development, staging, or production?
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
variable "environment" {
  description = "The deployment environment: dev (for testing), staging (for review), or prod (live!)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be 'dev', 'staging', or 'prod'."
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VARIABLE: project_name
# A name to label all our cloud resources so we know they belong together.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
variable "project_name" {
  description = "A short name for the project, used to label cloud resources"
  type        = string
  default     = "cloud-infrastructure"
}
