# =============================================================================
# Cloud Infrastructure - Terraform Starter
# =============================================================================
# This file defines the infrastructure resources to be created.
# Terraform uses HashiCorp Configuration Language (HCL).
#
# BEGINNER TIP: Read this file top to bottom. Each block creates something!
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # AWS provider - comment out if using a different cloud
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: Store state remotely so teams can share it
  # Uncomment and configure for team use:
  # backend "s3" {
  #   bucket = "my-terraform-state-bucket"
  #   key    = "cloud-infra/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# =============================================================================
# VPC (Virtual Private Cloud) - your private network in the cloud
# =============================================================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Public subnet - resources here can be reached from the internet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Internet Gateway - allows traffic between VPC and the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Route Table - tells traffic where to go
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# =============================================================================
# Security Group - a virtual firewall for your resources
# =============================================================================
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from anywhere
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from anywhere
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH (restrict this to your IP in production!)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# =============================================================================
# EC2 Instance - a virtual server in the cloud
# =============================================================================
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]

  # User data script runs when the instance first starts
  user_data = <<-EOF
    #!/bin/bash
    set -e
    yum update -y
    yum install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Hello from ${var.project_name}! 🚀</h1>" > /usr/share/nginx/html/index.html
  EOF

  tags = {
    Name = "${var.project_name}-web-server"
  }
}
