#!/bin/bash

# EKS Cost Optimization Script
set -e

CLUSTER_NAME=${1:-"my-eks-cluster"}
REGION=${2:-"us-west-2"}

echo "💰 EKS Cost Optimization Analysis for cluster: $CLUSTER_NAME"

# Check node utilization
echo "📊 Checking node utilization..."
kubectl top nodes

# Check pod resource requests vs usage
echo "📊 Checking pod resource efficiency..."
kubectl get pods --all-namespaces -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,CPU_REQ:.spec.containers[*].resources.requests.cpu,MEM_REQ:.spec.containers[*].resources.requests.memory"

# Identify unused resources
echo "🔍 Identifying unused resources..."
kubectl get pv | grep Available
kubectl get pvc --all-namespaces | grep -v Bound

# Check for over-provisioned nodes
echo "🔍 Checking for over-provisioned nodes..."
aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name worker-nodes --region $REGION --query 'nodegroup.scalingConfig'

# Spot instance recommendations
echo "💡 Cost optimization recommendations:"
echo "1. Consider using Spot instances for non-critical workloads"
echo "2. Right-size your node groups based on actual usage"
echo "3. Use Cluster Autoscaler to scale down unused nodes"
echo "4. Consider using Fargate for serverless workloads"
echo "5. Review and optimize resource requests/limits"

# Generate cost report
echo "📋 Generating cost optimization report..."
cat > cost-optimization-report.md << EOF
# EKS Cost Optimization Report

## Cluster: $CLUSTER_NAME
## Region: $REGION
## Date: $(date)

### Current Node Configuration
\`\`\`
$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name worker-nodes --region $REGION --query 'nodegroup.{InstanceTypes:instanceTypes,ScalingConfig:scalingConfig,AmiType:amiType}' --output table)
\`\`\`

### Resource Utilization
\`\`\`
$(kubectl top nodes)
\`\`\`

### Recommendations
1. **Spot Instances**: Save up to 90% on compute costs
2. **Right-sizing**: Adjust instance types based on actual usage
3. **Auto-scaling**: Use Cluster Autoscaler and HPA
4. **Reserved Instances**: For predictable workloads
5. **Fargate**: For serverless container workloads

### Next Steps
- [ ] Implement Spot instance node groups
- [ ] Set up resource quotas and limits
- [ ] Configure Horizontal Pod Autoscaler
- [ ] Review storage costs and optimize
EOF

echo "✅ Cost optimization analysis complete! Check cost-optimization-report.md"