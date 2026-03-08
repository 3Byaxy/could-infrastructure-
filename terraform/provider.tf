terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure to store state remotely
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "cloud-infrastructure/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "cloud-infrastructure"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
