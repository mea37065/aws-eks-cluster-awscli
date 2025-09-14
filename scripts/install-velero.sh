#!/bin/bash

# Velero Backup Automation for EKS
# Resolves: https://github.com/mea37065/aws-eks-cluster-awscli/issues/10

set -e

CLUSTER_NAME=${1:-"my-eks-cluster"}
REGION=${2:-"us-west-2"}
BACKUP_BUCKET=${3:-"eks-velero-backups-$(date +%s)"}
NAMESPACE=${4:-"velero"}

echo "🛡️ Installing Velero backup automation for cluster: $CLUSTER_NAME"

# Create S3 bucket for backups
echo "📦 Creating S3 backup bucket: $BACKUP_BUCKET"
aws s3 mb s3://$BACKUP_BUCKET --region $REGION

# Create IAM policy for Velero
cat > velero-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::$BACKUP_BUCKET/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::$BACKUP_BUCKET"
            ]
        }
    ]
}
EOF

# Create IAM role and policy
POLICY_NAME="VeleroBackupPolicy-$CLUSTER_NAME"
ROLE_NAME="VeleroBackupRole-$CLUSTER_NAME"

aws iam create-policy \
    --policy-name $POLICY_NAME \
    --policy-document file://velero-policy.json \
    --region $REGION || echo "Policy already exists"

# Get OIDC issuer
OIDC_ISSUER=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query 'cluster.identity.oidc.issuer' --output text)
OIDC_ID=$(echo $OIDC_ISSUER | cut -d '/' -f 5)

# Create trust policy
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):oidc-provider/oidc.eks.$REGION.amazonaws.com/id/$OIDC_ID"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.$REGION.amazonaws.com/id/$OIDC_ID:sub": "system:serviceaccount:$NAMESPACE:velero",
          "oidc.eks.$REGION.amazonaws.com/id/$OIDC_ID:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

# Create IAM role
aws iam create-role \
    --role-name $ROLE_NAME \
    --assume-role-policy-document file://trust-policy.json || echo "Role already exists"

# Attach policy to role
aws iam attach-role-policy \
    --role-name $ROLE_NAME \
    --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/$POLICY_NAME

# Install Velero
echo "🚀 Installing Velero..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Download and install Velero CLI if not present
if ! command -v velero &> /dev/null; then
    echo "📥 Installing Velero CLI..."
    curl -fsSL -o velero-v1.12.1-linux-amd64.tar.gz https://github.com/vmware-tanzu/velero/releases/download/v1.12.1/velero-v1.12.1-linux-amd64.tar.gz
    tar -xzf velero-v1.12.1-linux-amd64.tar.gz
    sudo mv velero-v1.12.1-linux-amd64/velero /usr/local/bin/
    rm -rf velero-v1.12.1-linux-amd64*
fi

# Install Velero in cluster
velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.8.0 \
    --bucket $BACKUP_BUCKET \
    --backup-location-config region=$REGION \
    --snapshot-location-config region=$REGION \
    --service-account-annotations iam.amazonaws.com/role=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/$ROLE_NAME

# Wait for Velero to be ready
echo "⏳ Waiting for Velero deployment..."
kubectl wait --for=condition=available --timeout=300s deployment/velero -n $NAMESPACE

# Create backup schedules
echo "📅 Creating backup schedules..."

# Daily backup for critical workloads
velero schedule create daily-backup \
    --schedule="0 2 * * *" \
    --ttl 720h \
    --include-namespaces default,kube-system,monitoring

# Weekly backup for all namespaces
velero schedule create weekly-backup \
    --schedule="0 3 * * 0" \
    --ttl 2160h

# Monthly backup for long-term retention
velero schedule create monthly-backup \
    --schedule="0 4 1 * *" \
    --ttl 8760h

# Create test backup
echo "🧪 Creating test backup..."
velero backup create test-backup-$(date +%Y%m%d-%H%M%S) --wait

# Cleanup temporary files
rm -f velero-policy.json trust-policy.json

echo "✅ Velero backup automation installed successfully!"
echo "📊 Backup schedules:"
echo "  - Daily: 02:00 UTC (30 days retention)"
echo "  - Weekly: 03:00 UTC Sunday (90 days retention)"
echo "  - Monthly: 04:00 UTC 1st day (1 year retention)"
echo ""
echo "🔍 Monitor backups with:"
echo "  velero backup get"
echo "  velero schedule get"
echo "  kubectl logs deployment/velero -n $NAMESPACE"