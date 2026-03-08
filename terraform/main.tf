# =============================================================================
# File: terraform/main.tf
# Language: HCL (HashiCorp Configuration Language) — Terraform
# What it does: Provisions AWS cloud infrastructure including a VPC, EC2
#               instance, and S3 bucket for a web application.
# Maintainer: @3Byaxy
# =============================================================================

# Tell Terraform which cloud provider to use and what version is required.
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS provider — this tells Terraform to talk to AWS
# and which region to create resources in.
provider "aws" {
  region = var.aws_region
}

# =============================================================================
# VPC — Virtual Private Cloud
# Think of this as your own private section of the AWS data center.
# All your resources live inside this network.
# =============================================================================
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16" # IP address range for the entire network
  enable_dns_hostnames = true           # Allow EC2 instances to get DNS names
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Internet Gateway — lets traffic flow between your VPC and the internet.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# Public subnet — a segment of the VPC where resources can have public IPs.
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24" # Smaller IP range inside the VPC
  map_public_ip_on_launch = true          # Auto-assign public IPs to instances
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Environment = var.environment
  }
}

# Route table — rules that direct network traffic.
# This one sends all internet-bound traffic through the Internet Gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                    # All traffic
    gateway_id = aws_internet_gateway.main.id   # Goes through the internet gateway
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

# Associate the route table with the public subnet.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# =============================================================================
# Security Group
# Acts like a firewall — controls what traffic is allowed in and out
# of our EC2 instance.
# =============================================================================
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Allow HTTP and SSH access"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP traffic on port 80 from anywhere
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS traffic on port 443 from anywhere
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH access on port 22 — useful for logging into the server
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (the server can make requests to the internet)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-web-sg"
    Environment = var.environment
  }
}

# =============================================================================
# EC2 Instance — Elastic Compute Cloud
# This is your virtual server running in the cloud.
# We install Nginx (a web server) on it automatically via user_data.
# =============================================================================

# Look up the latest Amazon Linux 2 AMI (machine image) automatically.
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]

  # This script runs automatically when the server first starts up.
  # It installs and starts Nginx so the server serves a web page right away.
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Hello from ${var.project_name}!</h1>" > /usr/share/nginx/html/index.html
  EOF

  tags = {
    Name        = "${var.project_name}-web-server"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# =============================================================================
# S3 Bucket — Simple Storage Service
# Used for storing files, backups, logs, or static website content.
# =============================================================================
resource "aws_s3_bucket" "main" {
  # Bucket names must be globally unique across all of AWS.
  # We use the project name + a suffix to help keep it unique.
  bucket = "${var.project_name}-${var.environment}-assets"

  tags = {
    Name        = "${var.project_name}-assets"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Block all public access to the S3 bucket for security.
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning — keeps a history of every file stored in the bucket.
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}
