#!/bin/bash

# Install Helm Charts for EKS cluster
set -e

CLUSTER_NAME=${1:-"my-eks-cluster"}
REGION=${2:-"us-west-2"}

echo "🚀 Installing Helm charts for EKS cluster: $CLUSTER_NAME"

# Add Helm repositories
helm repo add eks https://aws.github.io/eks-charts
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update

# Install AWS Load Balancer Controller
echo "📦 Installing AWS Load Balancer Controller..."
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  -n kube-system

# Install Cluster Autoscaler
echo "📦 Installing Cluster Autoscaler..."
helm upgrade --install cluster-autoscaler autoscaler/cluster-autoscaler \
  --set autoDiscovery.clusterName=$CLUSTER_NAME \
  --set awsRegion=$REGION \
  --set serviceAccount.create=false \
  --set serviceAccount.name=cluster-autoscaler \
  -n kube-system

echo "✅ Helm charts installed successfully!"