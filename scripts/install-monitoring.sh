#!/bin/bash

# Enhanced Monitoring Stack Installation
set -e

CLUSTER_NAME=${1:-"my-eks-cluster"}
REGION=${2:-"us-west-2"}
NAMESPACE=${3:-"monitoring"}

echo "📊 Installing comprehensive monitoring stack for EKS cluster: $CLUSTER_NAME"

# Create monitoring namespace
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Add Helm repositories
echo "📦 Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

# Install Prometheus Stack (includes Grafana, AlertManager)
echo "🔍 Installing Prometheus Stack..."
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace $NAMESPACE \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.retention=30d \
  --set grafana.adminPassword=admin123 \
  --set grafana.service.type=LoadBalancer \
  --set alertmanager.alertmanagerSpec.retention=120h

# Install Jaeger for distributed tracing
echo "🔗 Installing Jaeger..."
helm upgrade --install jaeger jaegertracing/jaeger \
  --namespace $NAMESPACE \
  --set provisionDataStore.cassandra=false \
  --set allInOne.enabled=true \
  --set storage.type=memory \
  --set query.service.type=LoadBalancer

# Install Fluent Bit for log aggregation
echo "📝 Installing Fluent Bit..."
helm upgrade --install fluent-bit fluent/fluent-bit \
  --namespace $NAMESPACE \
  --set config.outputs="[OUTPUT]\n    Name cloudwatch_logs\n    Match *\n    region $REGION\n    log_group_name /aws/eks/$CLUSTER_NAME/fluent-bit\n    auto_create_group true"

# Create ServiceMonitor for custom metrics
kubectl apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: eks-cluster-metrics
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      app: kubernetes
  endpoints:
  - port: https
    scheme: https
    tlsConfig:
      insecureSkipVerify: true
EOF

echo "✅ Monitoring stack installed successfully!"
echo "🌐 Access points:"
echo "  Grafana: kubectl port-forward -n $NAMESPACE svc/prometheus-grafana 3000:80"
echo "  Prometheus: kubectl port-forward -n $NAMESPACE svc/prometheus-kube-prometheus-prometheus 9090:9090"
echo "  Jaeger: kubectl port-forward -n $NAMESPACE svc/jaeger-query 16686:16686"
echo "  AlertManager: kubectl port-forward -n $NAMESPACE svc/prometheus-kube-prometheus-alertmanager 9093:9093"