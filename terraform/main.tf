# 🏗️ TERRAFORM MAIN CONFIGURATION FILE
# Terraform is a tool that lets you describe your cloud infrastructure using code.
# Think of this file as a blueprint — like the plans an architect draws before building a house!

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TERRAFORM BLOCK — Tells Terraform which version to use and
# which "providers" (cloud plugins) we need.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
terraform {
  required_version = ">= 1.0"

  required_providers {
    # The AWS provider lets Terraform talk to Amazon Web Services.
    # It's like installing a special plugin for your cloud!
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROVIDER BLOCK — Configures the cloud we want to use.
# Here we tell Terraform to use AWS in the US East region.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
provider "aws" {
  # The region is like choosing which Amazon warehouse/data center
  # you want your servers to live in. "us-east-1" is in Virginia, USA.
  region = var.aws_region
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RESOURCE — An EC2 Instance (a virtual server in the cloud)
# This is like renting a computer in Amazon's data center!
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
resource "aws_instance" "web_server" {
  # The AMI (Amazon Machine Image) is like choosing which operating
  # system to install on your cloud computer. This is Ubuntu 22.04.
  ami = var.ami_id

  # The instance type controls how powerful your server is.
  # "t2.micro" is a small, free-tier eligible server — great for learning!
  instance_type = var.instance_type

  # Tags are labels that help you find and organize your cloud resources.
  # Like putting a sticky note on your server!
  tags = {
    Name        = "cloud-infrastructure-web-server"
    Environment = var.environment
    Project     = "cloud-infrastructure"
    ManagedBy   = "Terraform"
  }
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# S3 BUCKET — Cloud storage (like Google Drive, but for your app)
# Great for storing files, backups, or static websites!
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
resource "aws_s3_bucket" "app_storage" {
  # The bucket name must be unique across ALL of AWS!
  bucket = "${var.project_name}-storage-${var.environment}"

  tags = {
    Name        = "${var.project_name}-storage"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Block all public access to the S3 bucket for security.
# We don't want strangers downloading our files!
resource "aws_s3_bucket_public_access_block" "app_storage_block" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
