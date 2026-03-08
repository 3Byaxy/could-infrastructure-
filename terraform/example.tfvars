# =============================================================================
# Example Terraform variable values
# =============================================================================
# Copy this file to terraform.tfvars and fill in your own values.
# The terraform.tfvars file is in .gitignore so your secrets stay safe!
# =============================================================================

project_name       = "my-cloud-project"
environment        = "dev"
aws_region         = "us-east-1"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
instance_type      = "t2.micro"

# IMPORTANT: Replace with your actual IP to restrict SSH access
# You can find your IP at https://checkip.amazonaws.com/
allowed_ssh_cidrs = ["YOUR.IP.HERE/32"]
