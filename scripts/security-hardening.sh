#!/bin/bash

# EKS Security Hardening Script
set -e

CLUSTER_NAME=${1:-"my-eks-cluster"}
REGION=${2:-"us-west-2"}

echo "🔒 EKS Security Hardening for cluster: $CLUSTER_NAME"

# Enable audit logging
echo "📝 Enabling EKS audit logging..."
aws eks update-cluster-config \
  --region $REGION \
  --name $CLUSTER_NAME \
  --logging '{"enable":[{"types":["api","audit","authenticator","controllerManager","scheduler"]}]}'

# Apply security policies
echo "🛡️ Applying security policies..."
kubectl apply -f manifests/security/

# Install Falco for runtime security
echo "🔍 Installing Falco for runtime security monitoring..."
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
helm install falco falcosecurity/falco \
  --set falco.grpc.enabled=true \
  --set falco.grpcOutput.enabled=true

# Install OPA Gatekeeper
echo "⚖️ Installing OPA Gatekeeper for policy enforcement..."
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml

# Apply network policies
echo "🌐 Applying network policies..."
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# Security scan
echo "🔍 Running security scan..."
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.securityContext}{"\n"}{end}' | grep -v "null"

echo "✅ Security hardening complete!"
echo "📋 Security checklist:"
echo "- [x] Audit logging enabled"
echo "- [x] Network policies applied"
echo "- [x] Falco runtime security installed"
echo "- [x] OPA Gatekeeper policy enforcement"
echo "- [ ] Review RBAC permissions"
echo "- [ ] Enable Pod Security Standards"
echo "- [ ] Configure AWS Security Groups"