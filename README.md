# AWS EKS Cluster with AWS CLI

A collection of bash scripts to deploy and destroy a production-ready Amazon EKS cluster with VPC, NodeGroups, and AWS Load Balancer Controller using AWS CLI and CloudFormation.

## Features

- **VPC with 3 Availability Zones** - 3 public + 3 private subnets with NAT Gateway
- **EKS Cluster** - Kubernetes 1.29 with proper IAM roles and OIDC provider
- **Managed NodeGroup** - Auto-scaling worker nodes in private subnets
- **AWS Load Balancer Controller** - For ingress and load balancing
- **Complete Cleanup** - Destroy scripts remove all created resources
- **Interactive Prompts** - Configurable parameters with sensible defaults

## Prerequisites

- AWS CLI v2 installed and configured
- kubectl installed
- Helm v3 installed
- jq installed
- Proper AWS IAM permissions for EKS, VPC, IAM, and EC2

## Quick Start

### 1. Deploy VPC
```bash
./scripts/create-vpc.sh
```

### 2. Deploy EKS Cluster
```bash
./scripts/create-eks.sh
```

### 3. Verify Deployment
```bash
kubectl get nodes
kubectl get pods -n kube-system
```

## Cleanup

### Destroy EKS Cluster
```bash
./scripts/destroy-eks.sh
```

### Destroy VPC
```bash
./scripts/delete-vpc.sh
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        VPC (10.0.0.0/16)                   │
├─────────────────┬─────────────────┬─────────────────────────┤
│   AZ-A          │   AZ-B          │   AZ-C                  │
├─────────────────┼─────────────────┼─────────────────────────┤
│ Public Subnet   │ Public Subnet   │ Public Subnet           │
│ 10.0.0.0/24     │ 10.0.1.0/24     │ 10.0.2.0/24             │
│                 │                 │                         │
│ Private Subnet  │ Private Subnet  │ Private Subnet          │
│ 10.0.100.0/24   │ 10.0.101.0/24   │ 10.0.102.0/24           │
│                 │                 │                         │
│ [EKS Nodes]     │ [EKS Nodes]     │ [EKS Nodes]             │
└─────────────────┴─────────────────┴─────────────────────────┘
```

## Scripts Overview

| Script | Purpose | Resources Created |
|--------|---------|-------------------|
| `create-vpc.sh` | Deploy VPC infrastructure | VPC, Subnets, IGW, NAT Gateway, Route Tables |
| `create-eks.sh` | Deploy EKS cluster | EKS Cluster, NodeGroup, IAM Roles, OIDC, ALB Controller |
| `destroy-eks.sh` | Remove EKS resources | Removes all EKS-related resources |
| `delete-vpc.sh` | Remove VPC infrastructure | Removes VPC CloudFormation stack |

## Configuration

### Default Values
- **Region**: eu-central-1
- **VPC CIDR**: 10.0.0.0/16
- **Kubernetes Version**: 1.29
- **Instance Type**: t3.medium
- **Node Count**: 3
- **Cluster Name**: eks-demo

### Environment Variables
Scripts create a `.env` file with deployment parameters:
```bash
AWS_REGION=eu-central-1
VPC_STACK_NAME=eks-vpc
VPC_ID=vpc-xxxxx
CLUSTER_NAME=eks-demo
# ... additional variables
```

## IAM Permissions Required

Your AWS user/role needs permissions for:
- EKS (full access)
- EC2 (VPC, subnets, security groups, tags)
- IAM (create/delete roles and policies)
- CloudFormation (create/delete stacks)

## Troubleshooting

### Common Issues

**1. Insufficient IAM permissions**
```bash
# Check your AWS identity
aws sts get-caller-identity
```

**2. Region mismatch**
```bash
# Ensure consistent region usage
export AWS_DEFAULT_REGION=eu-central-1
```

**3. Resource limits**
- Check VPC limits in your region
- Verify EKS service quotas

### Cleanup Verification

The destroy script provides a verification report:
```
=== DESTRUCTION COMPLETE - VERIFICATION REPORT ===
✅ EKS Cluster removed: eks-demo
✅ NodeGroup removed: ng-1
✅ IAM Role removed: eksClusterRole-eks-demo
✅ IAM Role removed: eksNodeRole-eks-demo
✅ IAM Role removed: ALBControllerRole-eks-demo

🎉 All EKS resources successfully destroyed!
```

## File Structure

```
aws-eks-cluster-awscli/
├── scripts/
│   ├── create-vpc.sh          # VPC deployment
│   ├── create-eks.sh          # EKS deployment  
│   ├── destroy-eks.sh         # EKS cleanup
│   └── delete-vpc.sh          # VPC cleanup
├── cloudformation/
│   └── vpc-3az.yaml           # VPC CloudFormation template
├── iam/
│   └── aws-load-balancer-controller-policy.json
├── artifacts/                 # Generated files
├── .env                       # Environment variables
└── README.md
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

**LT** - [GitHub Profile](https://github.com/lubomir-tobek)

---

⚠️ **Important**: These scripts create AWS resources that incur costs. Always run the destroy scripts to clean up resources when done.