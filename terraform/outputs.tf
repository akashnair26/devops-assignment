output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate authority data for the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "region" {
  description = "AWS cluster region"
  value       = var.aws_region
}

output "configure_kubectl" {
  description = "Command to configure kubectl for the cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "ecr_repo_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.hello_world.repository_url
}
