# Kubernetes Manifests

This directory contains Kubernetes manifests for deploying the Contoso Air web application to a Kubernetes cluster.

## Files Overview

- **k8s-deployment.yaml**: Defines the Deployment resource for the web application
- **k8s-service.yaml**: Defines the Service resource to expose the application
- **k8s-configmap.yaml**: Configuration data for the application
- **k8s-hpa.yaml**: Horizontal Pod Autoscaler for automatic scaling
- **k8s-pdb.yaml**: Pod Disruption Budget for high availability

## Best Practices Implemented

### Labels and Annotations
All resources use standard Kubernetes labels following the recommended format:
- `app.kubernetes.io/name`: Application name
- `app.kubernetes.io/component`: Component within the application
- `app.kubernetes.io/part-of`: Name of the higher-level application
- `app.kubernetes.io/managed-by`: Tool managing the resource

### Security
- **Non-root user**: Containers run as non-root user (UID 1000)
- **Read-only root filesystem**: Enabled where possible
- **Dropped capabilities**: All Linux capabilities are dropped
- **Security context**: Applied at both pod and container level
- **No privilege escalation**: Explicitly disabled

### High Availability
- **Replica count**: Minimum of 2 replicas for redundancy
- **Pod Disruption Budget**: Ensures at least 1 pod is always available
- **Rolling updates**: Zero-downtime deployments with `maxUnavailable: 0`
- **Graceful shutdown**: 30-second termination grace period

### Resource Management
- **Resource requests**: CPU (100m) and memory (128Mi) requests defined
- **Resource limits**: CPU (500m) and memory (256Mi) limits defined
- **Horizontal Pod Autoscaler**: Scales between 2-10 replicas based on CPU/memory

### Health Checks
- **Liveness probe**: Checks if the application is running
- **Readiness probe**: Checks if the application is ready to serve traffic
- Both probes use HTTP GET requests to the root path

### Configuration
- **ConfigMap**: Centralized configuration management
- **Environment variables**: Loaded from ConfigMap
- **Secrets support**: Ready for sensitive data via Kubernetes Secrets

## Deployment

### Prerequisites
- Kubernetes cluster (v1.20+)
- kubectl configured to access your cluster
- Container image pushed to your registry

### Deploy All Resources

```bash
# Apply all manifests
kubectl apply -f infra/k8s/

# Verify deployment
kubectl get all -l app=contoso-air-web

# Check pod status
kubectl get pods -l app=contoso-air-web

# View logs
kubectl logs -l app=contoso-air-web --tail=100 -f
```

### Deploy Individual Resources

```bash
# ConfigMap first (if needed)
kubectl apply -f infra/k8s/k8s-configmap.yaml

# Deployment
kubectl apply -f infra/k8s/k8s-deployment.yaml

# Service
kubectl apply -f infra/k8s/k8s-service.yaml

# HPA
kubectl apply -f infra/k8s/k8s-hpa.yaml

# PDB
kubectl apply -f infra/k8s/k8s-pdb.yaml
```

## Configuration

### Update Container Image

Edit `k8s-deployment.yaml` and update the image reference:

```yaml
image: your-registry.azurecr.io/your-image:tag
```

Or use kubectl:

```bash
kubectl set image deployment/contoso-air-web \
  contoso-air-web=your-registry.azurecr.io/your-image:tag
```

### Update Environment Variables

Edit `k8s-configmap.yaml` and add/modify configuration:

```yaml
data:
  AZURE_COSMOS_LISTCONNECTIONSTRINGURL: "your-value"
  AZURE_COSMOS_SCOPE: "your-value"
  AZURE_COSMOS_CLIENTID: "your-value"
```

Then apply the changes:

```bash
kubectl apply -f infra/k8s/k8s-configmap.yaml
kubectl rollout restart deployment/contoso-air-web
```

### Scale Manually

```bash
# Scale to specific number of replicas
kubectl scale deployment/contoso-air-web --replicas=3

# Check scaling status
kubectl get deployment contoso-air-web
kubectl get hpa contoso-air-web-hpa
```

## Monitoring

### Check Deployment Status

```bash
# Overall status
kubectl get deployment contoso-air-web

# Detailed description
kubectl describe deployment contoso-air-web

# Pod status
kubectl get pods -l app=contoso-air-web

# HPA metrics
kubectl get hpa contoso-air-web-hpa
```

### View Logs

```bash
# All pods
kubectl logs -l app=contoso-air-web

# Specific pod
kubectl logs <pod-name>

# Follow logs
kubectl logs -l app=contoso-air-web -f

# Previous container logs (if crashed)
kubectl logs <pod-name> --previous
```

### Debug Pod Issues

```bash
# Describe pod
kubectl describe pod <pod-name>

# Get events
kubectl get events --sort-by='.lastTimestamp'

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/sh
```

## Cleanup

```bash
# Delete all resources
kubectl delete -f infra/k8s/

# Or delete individually
kubectl delete deployment contoso-air-web
kubectl delete service contoso-air-web
kubectl delete configmap contoso-air-web-config
kubectl delete hpa contoso-air-web-hpa
kubectl delete pdb contoso-air-web-pdb
```

## Troubleshooting

### Pod Not Starting

```bash
# Check pod status and events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Check if image can be pulled
kubectl get events | grep -i pull
```

### Service Not Accessible

```bash
# Check service
kubectl get svc contoso-air-web
kubectl describe svc contoso-air-web

# Check endpoints
kubectl get endpoints contoso-air-web

# Test from another pod
kubectl run -it --rm debug --image=busybox --restart=Never -- \
  wget -O- http://contoso-air-web
```

### HPA Not Scaling

```bash
# Check HPA status
kubectl get hpa contoso-air-web-hpa
kubectl describe hpa contoso-air-web-hpa

# Check metrics server
kubectl top pods
kubectl top nodes
```

## Additional Resources

- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/azure/aks/)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/security-checklist/)
