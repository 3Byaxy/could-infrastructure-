# =============================================================================
# Cloud Infrastructure - Terraform Outputs
# =============================================================================
# Outputs display useful information after `terraform apply` runs.
# You can also reference outputs from other Terraform modules.
# =============================================================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public.id
}

output "web_server_public_ip" {
  description = "The public IP address of the web server"
  value       = aws_instance.web.public_ip
}

output "web_server_public_dns" {
  description = "The public DNS name of the web server"
  value       = aws_instance.web.public_dns
}

output "web_url" {
  description = "URL to access the web server"
  value       = "http://${aws_instance.web.public_dns}"
}

output "security_group_id" {
  description = "The ID of the web security group"
  value       = aws_security_group.web.id
}
