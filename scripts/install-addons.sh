#!/usr/bin/env bash
set -euo pipefail

CYAN="\033[0;36m"; MAGENTA="\033[0;35m"; GREEN="\033[0;32m"; NC="\033[0m"

echo -e "${MAGENTA}=== Install EKS Add-ons ===${NC}"

if [ -f .env ]; then
  set -a; source .env; set +a
fi

CLUSTER_NAME="${CLUSTER_NAME:-eks-demo}"
AWS_REGION="${AWS_REGION:-eu-central-1}"

echo -e "${CYAN}Installing Cluster Autoscaler...${NC}"
kubectl apply -f manifests/cluster-autoscaler.yaml
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler \
  cluster-autoscaler.kubernetes.io/safe-to-evict="false" --overwrite

echo -e "${CYAN}Installing Metrics Server...${NC}"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

echo -e "${CYAN}Installing EBS CSI Driver...${NC}"
aws eks create-addon \
  --cluster-name "${CLUSTER_NAME}" \
  --addon-name aws-ebs-csi-driver \
  --region "${AWS_REGION}" || true

echo -e "${GREEN}Add-ons installed successfully!${NC}"