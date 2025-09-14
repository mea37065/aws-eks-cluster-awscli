# Spot Instance Node Group for Cost Optimization

resource "aws_eks_node_group" "spot_nodes" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "spot-worker-nodes"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.private_subnet_ids

  capacity_type = "SPOT"
  
  instance_types = ["t3.medium", "t3.large", "m5.large"]

  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Taints for spot instances
  taint {
    key    = "spot-instance"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  tags = {
    Name = "EKS-Spot-Node-Group"
    Type = "spot"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_group_AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Output spot node group info
output "spot_node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Spot Node Group"
  value       = aws_eks_node_group.spot_nodes.arn
}

output "spot_node_group_status" {
  description = "Status of the EKS Spot Node Group"
  value       = aws_eks_node_group.spot_nodes.status
}