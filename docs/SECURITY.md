# Security Best Practices

## Overview
This document outlines security best practices for EKS cluster deployment and management.

## Network Security

### VPC Configuration
- Private subnets for worker nodes
- Public subnets only for load balancers
- Single NAT Gateway for cost optimization
- Security groups with minimal required access

### Network Policies
Apply network policies to restrict pod-to-pod communication:
```bash
kubectl apply -f manifests/security/network-policy.yaml
```

## IAM Security

### Principle of Least Privilege
- Separate IAM roles for cluster and nodes
- OIDC provider for service account authentication
- Minimal required permissions for AWS Load Balancer Controller

### Service Account Security
```bash
# Annotate service accounts with IAM roles
kubectl annotate serviceaccount -n kube-system aws-load-balancer-controller \
  eks.amazonaws.com/role-arn=arn:aws:iam::ACCOUNT:role/ALBControllerRole
```

## Pod Security

### Security Context
Always run containers with security context:
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
```

### Pod Security Standards
Enable Pod Security Standards:
```bash
kubectl label namespace default pod-security.kubernetes.io/enforce=restricted
```

## Secrets Management

### AWS Secrets Manager
Use AWS Secrets Manager for sensitive data:
```bash
# Install Secrets Store CSI Driver
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system
```

### Encryption at Rest
Enable encryption for EKS secrets:
```bash
aws eks create-cluster \
  --encryption-config resources=secrets,provider='{keyId=arn:aws:kms:region:account:key/key-id}'
```

## Monitoring and Auditing

### Enable Audit Logging
```bash
aws eks update-cluster-config \
  --name cluster-name \
  --logging '{"enable":["audit","api","authenticator","controllerManager","scheduler"]}'
```

### Security Scanning
- Use Trivy for container image scanning
- Implement admission controllers (OPA Gatekeeper)
- Regular security assessments

## Compliance

### CIS Benchmarks
Follow CIS Kubernetes Benchmark guidelines:
- Disable anonymous authentication
- Use RBAC for authorization
- Enable audit logging
- Secure kubelet configuration

### SOC 2 Compliance
- Implement proper access controls
- Enable comprehensive logging
- Regular security reviews
- Incident response procedures

## Emergency Procedures

### Cluster Compromise Response
1. Isolate affected nodes
2. Rotate all credentials
3. Review audit logs
4. Update security policies
5. Conduct post-incident review

### Security Contacts
- Security Team: security@company.com
- On-call: +1-xxx-xxx-xxxx
- Incident Response: incident@company.com