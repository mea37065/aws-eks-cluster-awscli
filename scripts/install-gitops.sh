#!/bin/bash

# GitOps Integration with ArgoCD and Flux
set -e

CLUSTER_NAME=${1:-"my-eks-cluster"}
GITOPS_TOOL=${2:-"argocd"}
NAMESPACE=${3:-"gitops"}

echo "🔄 Installing GitOps solution: $GITOPS_TOOL for cluster: $CLUSTER_NAME"

# Create namespace
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

if [ "$GITOPS_TOOL" = "argocd" ]; then
    echo "🚀 Installing ArgoCD..."
    
    # Install ArgoCD
    kubectl apply -n $NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    # Wait for ArgoCD to be ready
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n $NAMESPACE
    
    # Get initial admin password
    ARGOCD_PASSWORD=$(kubectl -n $NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    
    # Create LoadBalancer service for ArgoCD
    kubectl patch svc argocd-server -n $NAMESPACE -p '{"spec": {"type": "LoadBalancer"}}'
    
    echo "✅ ArgoCD installed successfully!"
    echo "🔑 Admin password: $ARGOCD_PASSWORD"
    echo "🌐 Access: kubectl port-forward svc/argocd-server -n $NAMESPACE 8080:443"
    
elif [ "$GITOPS_TOOL" = "flux" ]; then
    echo "🌊 Installing Flux..."
    
    # Install Flux CLI if not present
    if ! command -v flux &> /dev/null; then
        curl -s https://fluxcd.io/install.sh | sudo bash
    fi
    
    # Bootstrap Flux (requires GitHub token)
    if [ -z "$GITHUB_TOKEN" ]; then
        echo "⚠️  GITHUB_TOKEN environment variable required for Flux bootstrap"
        echo "Set it with: export GITHUB_TOKEN=<your-token>"
        exit 1
    fi
    
    # Bootstrap Flux
    flux bootstrap github \
        --owner=$GITHUB_USER \
        --repository=$CLUSTER_NAME-gitops \
        --branch=main \
        --path=./clusters/$CLUSTER_NAME \
        --personal
    
    echo "✅ Flux installed and bootstrapped!"
    echo "📁 GitOps repository: https://github.com/$GITHUB_USER/$CLUSTER_NAME-gitops"
    
else
    echo "❌ Unsupported GitOps tool: $GITOPS_TOOL"
    echo "Supported tools: argocd, flux"
    exit 1
fi

# Create sample application manifest
cat > sample-app.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app
  namespace: $NAMESPACE
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

echo "📝 Sample application manifest created: sample-app.yaml"
echo "🔄 GitOps setup complete!"