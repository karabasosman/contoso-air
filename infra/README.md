# Kubernetes Deployment Guide for Contoso Air

This guide explains how to deploy the Contoso Air application to a Kubernetes cluster using the enhanced deployment configuration that follows security and reliability best practices.

## Prerequisites

- Kubernetes cluster (Azure AKS recommended)
- kubectl configured to connect to your cluster
- Azure resources created (CosmosDB, Managed Identity)
- Container image built and pushed to Azure Container Registry

## Overview

The deployment consists of multiple Kubernetes resources:

- **ServiceAccount**: Dedicated service account with minimal RBAC permissions
- **ConfigMap**: Non-sensitive configuration variables
- **Secret**: Sensitive configuration like Azure credentials
- **Deployment**: Main application deployment with security hardening
- **Service**: LoadBalancer service to expose the application
- **HorizontalPodAutoscaler**: Automatic scaling based on CPU/memory usage
- **PodDisruptionBudget**: Ensures availability during cluster maintenance

## Quick Deploy

### Option 1: Using Kustomize (Recommended)

```bash
# Deploy all resources at once
kustomize build infra/ | kubectl apply -f -

# Or apply directly
kubectl apply -k infra/
```

### Option 2: Individual Files

```bash
# Apply in order (dependencies first)
kubectl apply -f infra/serviceaccount.yaml
kubectl apply -f infra/configmap.yaml
kubectl apply -f infra/secret.yaml
kubectl apply -f infra/deployment.yaml
kubectl apply -f infra/service.yaml
kubectl apply -f infra/hpa.yaml
kubectl apply -f infra/pdb.yaml
```

## Configuration Requirements

### 1. Update Secret Values

Before deploying, update the secret with actual values:

```bash
# Create secret with actual values
kubectl create secret generic contoso-air-web-secrets \
  --from-literal=AZURE_COSMOS_CLIENTID="your-managed-identity-client-id" \
  --from-literal=AZURE_COSMOS_LISTCONNECTIONSTRINGURL="your-cosmos-connection-url"

# Or edit the secret.yaml file with base64 encoded values
echo -n "your-client-id" | base64
echo -n "your-connection-url" | base64
```

### 2. Update ServiceAccount for Azure Workload Identity

Update the ServiceAccount annotation with your actual client ID:

```yaml
metadata:
  annotations:
    azure.workload.identity/client-id: "your-actual-client-id"
```

### 3. Pin Container Image (Security Best Practice)

Replace the image tag with a specific digest:

```bash
# Get the digest of your image
az acr repository show-manifests --name osktestcrqpjmtpx4xyv3e --repository contosoair

# Update deployment.yaml
image: osktestcrqpjmtpx4xyv3e.azurecr.io/contosoair@sha256:your-actual-digest
```

## Monitoring and Validation

### Check Deployment Status

```bash
# Check all resources
kubectl get all -l app=contoso-air-web

# Check specific resources
kubectl get deployment contoso-air-web
kubectl get service contoso-air-web
kubectl get hpa contoso-air-web-hpa
kubectl get pdb contoso-air-web-pdb

# Check pod details and logs
kubectl describe pod -l app=contoso-air-web
kubectl logs -l app=contoso-air-web
```

### Verify Security Configuration

```bash
# Check security context
kubectl get pod -l app=contoso-air-web -o jsonpath='{.items[0].spec.securityContext}'

# Check container security context
kubectl get pod -l app=contoso-air-web -o jsonpath='{.items[0].spec.containers[0].securityContext}'

# Verify service account
kubectl get pod -l app=contoso-air-web -o jsonpath='{.items[0].spec.serviceAccountName}'
```

### Test Application

```bash
# Get service external IP
kubectl get service contoso-air-web

# Test health endpoint
curl http://EXTERNAL-IP/

# Check if HPA is working
kubectl top pods -l app=contoso-air-web
kubectl get hpa contoso-air-web-hpa
```

## Security Features Implemented

- **Non-root execution**: Application runs as user ID 1000
- **Read-only root filesystem**: Prevents runtime file system modifications
- **No privilege escalation**: Blocks privilege escalation attacks
- **Dropped capabilities**: Removes all Linux capabilities
- **Seccomp profile**: Uses runtime default seccomp profile
- **Resource limits**: CPU and memory limits prevent resource exhaustion
- **Pod anti-affinity**: Spreads pods across nodes for high availability
- **Network security**: Service account with minimal RBAC permissions
- **Image pinning**: Uses specific digest instead of tags (when configured)

## Customization

### Namespace Deployment

To deploy to a specific namespace:

```bash
# Create namespace
kubectl create namespace contoso-air

# Update kustomization.yaml
echo "namespace: contoso-air" >> infra/kustomization.yaml

# Deploy
kubectl apply -k infra/
```

### Environment-Specific Overlays

Create environment-specific configurations:

```bash
mkdir -p infra/overlays/prod infra/overlays/staging

# Create production overlay
cat > infra/overlays/prod/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../

patchesStrategicMerge:
  - hpa-patch.yaml
  - deployment-patch.yaml
EOF
```

## Troubleshooting

### Common Issues

1. **Pod fails to start**: Check if secrets are properly configured
2. **Service not accessible**: Verify LoadBalancer has external IP assigned
3. **HPA not scaling**: Ensure metrics server is installed in cluster
4. **Azure identity issues**: Verify managed identity and workload identity setup

### Debug Commands

```bash
# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Describe resources for detailed info
kubectl describe deployment contoso-air-web
kubectl describe service contoso-air-web

# Check resource usage
kubectl top nodes
kubectl top pods
```

## Cleanup

```bash
# Remove all resources
kubectl delete -k infra/

# Or remove individual resources
kubectl delete -f infra/
```