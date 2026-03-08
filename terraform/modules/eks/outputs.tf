output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_ca_data" {
  description = "Certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "node_group_arn" {
  description = "ARN of the EKS node group"
  value       = aws_eks_node_group.main.arn
}
