output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "get_credentials_command" {
  value = "aws eks update-kubeconfig --name ${aws_eks_cluster.this.name}"
}
