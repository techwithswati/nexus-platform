output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "Kubernetes version"
  value       = module.eks.cluster_version
}

output "ecr_repository_url" {
  description = "EKS repository URL for Docker images"
  value       = aws_ecr_repository.nexus_app.repository_url
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC"
  value       = aws_iam_role.github_actions.arn
}

output "configure_kubectl" {
  description = "Run this command to config kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "nat_gateway_ip" {
  description = "NAT Gateway IP"
  value       = module.vpc.nat_public_ips
}
