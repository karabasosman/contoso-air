# Kubernetes Production Deployment Guide

This directory contains production-ready Kubernetes configurations for the Contoso Air application, optimized for scalability, security, and observability.

## 📋 Overview

The deployment includes the following production best practices:
- **Security**: RBAC, SecurityContext, NetworkPolicies, PodSecurityStandards
- **Reliability**: Health checks, PodDisruptionBudget, multi-replica deployment
- **Scalability**: HorizontalPodAutoscaler with CPU and memory metrics
- **Observability**: Monitoring, logging, and metrics collection
- **Configuration Management**: ConfigMaps, Secrets, and environment-specific configs

## 📁 File Structure

```
k8s/
├── deploy.sh                 # Deployment script
├── kustomization.yaml        # Kustomize configuration
├── k8s-namespace.yaml        # Namespace, ResourceQuota, LimitRange
├── k8s-rbac.yaml            # ServiceAccount, Role, RoleBinding
├── k8s-secrets.yaml         # Secrets and External Secrets
├── k8s-configmap.yaml       # Application configuration
├── k8s-deployment.yaml      # Main application deployment
├── k8s-service.yaml         # Service configuration
├── k8s-hpa.yaml            # Horizontal Pod Autoscaler
├── k8s-pdb.yaml            # Pod Disruption Budget
├── k8s-networkpolicy.yaml  # Network security policies
├── k8s-ingress.yaml        # Ingress configuration
├── k8s-monitoring.yaml     # Monitoring and observability
└── README.md               # This file
```

## 🚀 Quick Start

### Prerequisites

- Kubernetes cluster (v1.24+)
- kubectl configured
- Ingress controller (nginx)
- Metrics server for HPA
- External Secrets Operator (optional, for Azure Key Vault integration)

### Deploy

```bash
# Validate configuration
./deploy.sh validate

# Deploy with dry-run first
DRY_RUN=true ./deploy.sh deploy

# Deploy to production
./deploy.sh deploy

# Check status
./deploy.sh status
```

### Cleanup

```bash
./deploy.sh cleanup
```

## 🔧 Configuration

### Environment Variables

The application supports the following configuration through ConfigMap:

| Variable | Default | Description |
|----------|---------|-------------|
| `log-level` | `info` | Application log level |
| `session-timeout` | `3600` | Session timeout in seconds |
| `max-connections` | `100` | Maximum concurrent connections |
| `cache-ttl` | `300` | Cache time-to-live in seconds |
| `db-pool-size` | `10` | Database connection pool size |
| `db-timeout` | `5000` | Database connection timeout |
| `metrics-enabled` | `true` | Enable metrics collection |

### Secrets Management

Secrets are managed through two approaches:

1. **Kubernetes Secrets** (basic): For local development and testing
2. **External Secrets** (recommended): Integration with Azure Key Vault for production

Required secrets:
- `session-secret`: Session encryption key
- `jwt-secret`: JWT signing key
- `cosmos-connection-string`: Database connection string

### Resource Requirements

**Default resource allocation per pod:**
- CPU Request: 200m
- CPU Limit: 1000m
- Memory Request: 256Mi
- Memory Limit: 512Mi
- Ephemeral Storage: 1Gi

**Namespace limits:**
- Total CPU: 8 cores
- Total Memory: 16Gi
- Maximum Pods: 20

## 📊 Scaling

### Horizontal Pod Autoscaler (HPA)

The HPA is configured with:
- **Min Replicas**: 3
- **Max Replicas**: 20
- **CPU Target**: 70%
- **Memory Target**: 80%
- **Scale-up behavior**: Aggressive (50% increase or 4 pods per minute)
- **Scale-down behavior**: Conservative (10% decrease or 2 pods per minute)

### Manual Scaling

```bash
# Scale to specific replica count
kubectl scale deployment contoso-air-web -n contoso-air --replicas=5

# Check HPA status
kubectl get hpa -n contoso-air
```

## 🔒 Security

### Network Policies

- **Default Deny**: All ingress and egress blocked by default
- **Selective Allow**: Only necessary traffic allowed:
  - Ingress from ingress controller
  - Egress to DNS, HTTPS endpoints, and database

### Pod Security

- **Non-root user**: Runs as UID 1000
- **Read-only root filesystem**: Prevents runtime modifications
- **Dropped capabilities**: All Linux capabilities dropped
- **Security profiles**: Uses RuntimeDefault seccomp profile

### RBAC

Minimal RBAC permissions:
- Service account with restricted permissions
- Access only to ConfigMaps and Secrets in the same namespace

## 📈 Monitoring & Observability

### Health Checks

| Endpoint | Purpose | Frequency |
|----------|---------|-----------|
| `/health` | Liveness probe | Every 30s |
| `/ready` | Readiness probe | Every 10s |
| `/metrics` | Prometheus metrics | Scraped by monitoring |

### Metrics

The application exposes Prometheus metrics at `/metrics` including:
- HTTP request duration and rate
- Error rates by status code
- Custom business metrics

### Logging

Structured JSON logging with configurable levels:
- Application logs: `/var/log/app`
- Access logs: Standard output
- Error logs: Standard error

## 🌐 Ingress & Traffic Management

### Ingress Configuration

- **TLS Termination**: Automatic HTTPS redirect
- **Rate Limiting**: 100 requests per minute per IP
- **Security Headers**: OWASP recommended headers
- **External DNS**: Automatic DNS record creation

### Load Balancing

- **Session Affinity**: None (stateless application)
- **Health Checks**: Integration with application health endpoints
- **SSL Passthrough**: Disabled (TLS terminated at ingress)

## 🔄 Deployment Strategy

### Rolling Updates

- **Strategy**: RollingUpdate
- **Max Surge**: 1 pod
- **Max Unavailable**: 1 pod
- **Grace Period**: 30 seconds

### Pod Disruption Budget

- **Min Available**: 2 pods
- Ensures availability during cluster maintenance

## 🐛 Troubleshooting

### Common Issues

1. **Pods not starting**:
   ```bash
   kubectl describe pod -n contoso-air -l app=contoso-air-web
   kubectl logs -n contoso-air -l app=contoso-air-web
   ```

2. **HPA not scaling**:
   ```bash
   kubectl describe hpa -n contoso-air
   kubectl top pods -n contoso-air
   ```

3. **Service not accessible**:
   ```bash
   kubectl get endpoints -n contoso-air
   kubectl get ingress -n contoso-air
   ```

### Debug Commands

```bash
# Get all resources
kubectl get all -n contoso-air

# Check events
kubectl get events -n contoso-air --sort-by='.lastTimestamp'

# View logs
kubectl logs -n contoso-air deployment/contoso-air-web -f

# Port forward for local access
kubectl port-forward -n contoso-air service/contoso-air-web 8080:80
```

## 📝 Customization

### Environment-Specific Overlays

Create environment-specific configurations using Kustomize overlays:

```yaml
# overlays/staging/kustomization.yaml
namePrefix: staging-
commonLabels:
  environment: staging
resources:
  - ../../base
patchesStrategicMerge:
  - deployment-patch.yaml
```

### Security Customization

Update security policies based on your requirements:
- Modify NetworkPolicy rules for specific traffic patterns
- Adjust SecurityContext based on container requirements
- Configure Pod Security Standards per namespace

## 🔗 Integration

### CI/CD Pipeline

Example GitHub Actions integration:

```yaml
- name: Deploy to Kubernetes
  run: |
    cd infra/k8s
    ./deploy.sh validate
    ./deploy.sh deploy
```

### Monitoring Integration

- **Prometheus**: ServiceMonitor for metrics scraping
- **Grafana**: Pre-configured dashboard
- **AlertManager**: Custom alerting rules

## 📚 Additional Resources

- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [HPA Documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Kustomize Documentation](https://kustomize.io/)