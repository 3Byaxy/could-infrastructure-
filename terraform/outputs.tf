output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "eks_cluster_ca_data" {
  description = "Certificate authority data for the EKS cluster"
  value       = module.eks.cluster_ca_data
  sensitive   = true
}

output "kubeconfig_command" {
  description = "AWS CLI command to update kubeconfig for this cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
