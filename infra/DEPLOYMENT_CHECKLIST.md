# Production Deployment Checklist

## Pre-Deployment ✓

### Infrastructure Requirements
- [ ] Kubernetes cluster v1.24+ is available and accessible
- [ ] kubectl configured with appropriate cluster context
- [ ] Ingress controller (nginx) is installed and running
- [ ] Metrics server is installed for HPA functionality
- [ ] Monitoring stack (Prometheus/Grafana) is available
- [ ] External Secrets Operator installed (optional, for Azure Key Vault)

### Security Prerequisites
- [ ] Azure Key Vault created with required secrets (if using External Secrets)
- [ ] Service principal or managed identity configured for Key Vault access
- [ ] TLS certificates available for Ingress (or Let's Encrypt configured)
- [ ] Network policies compatible with cluster CNI

### Configuration Review
- [ ] Update image tags in kustomization.yaml to target version
- [ ] Review and customize ConfigMap values for environment
- [ ] Verify secrets are properly configured in k8s-secrets.yaml
- [ ] Update Ingress hostname to match your domain
- [ ] Adjust resource requests/limits based on capacity planning
- [ ] Review HPA min/max replicas for expected load

## Deployment Process ✓

### Validation Steps
- [ ] Run `./deploy.sh validate` to check YAML syntax and configuration
- [ ] Execute `DRY_RUN=true ./deploy.sh deploy` to test deployment
- [ ] Review generated resources with `kubectl kustomize .`
- [ ] Verify no resource conflicts in target namespace

### Deploy to Staging
- [ ] Deploy to staging environment first
- [ ] Run smoke tests to verify functionality
- [ ] Validate health endpoints are responding
- [ ] Test auto-scaling behavior under load
- [ ] Verify monitoring and alerting are working

### Production Deployment
- [ ] Execute `./deploy.sh deploy` in production
- [ ] Monitor deployment progress with `kubectl get events -n contoso-air --watch`
- [ ] Verify all pods reach Running/Ready state
- [ ] Check HPA is active and metrics are available
- [ ] Test application accessibility through Ingress

## Post-Deployment Verification ✓

### Application Health
- [ ] All pods are in Running state: `kubectl get pods -n contoso-air`
- [ ] Health endpoint responds: `curl https://your-domain/health`
- [ ] Ready endpoint responds: `curl https://your-domain/ready`
- [ ] Metrics endpoint accessible: `curl https://your-domain/metrics`
- [ ] Application functions correctly through web interface

### Infrastructure Status
- [ ] Service endpoints are available: `kubectl get endpoints -n contoso-air`
- [ ] Ingress is configured correctly: `kubectl get ingress -n contoso-air`
- [ ] HPA is functioning: `kubectl get hpa -n contoso-air`
- [ ] PDB is active: `kubectl get pdb -n contoso-air`
- [ ] Network policies are enforced: `kubectl get networkpolicy -n contoso-air`

### Security Verification
- [ ] Pods are running as non-root user
- [ ] Read-only root filesystem is enforced
- [ ] All Linux capabilities are dropped
- [ ] RBAC permissions are minimal and functional
- [ ] Network policies restrict traffic appropriately
- [ ] Secrets are mounted securely (not in environment variables)

### Monitoring & Observability
- [ ] Prometheus is scraping metrics from ServiceMonitor
- [ ] Grafana dashboard displays application metrics
- [ ] Logs are structured and accessible
- [ ] Alerting rules are active and properly configured
- [ ] Health check metrics are being recorded

## Load Testing & Performance ✓

### Scaling Verification
- [ ] Generate load to trigger HPA scaling
- [ ] Verify pods scale up automatically when CPU > 70%
- [ ] Confirm memory-based scaling when memory > 80%
- [ ] Test scale-down behavior when load decreases
- [ ] Validate PDB prevents too many pods from being unavailable

### Performance Baselines
- [ ] Response time < 200ms for health endpoints
- [ ] Response time < 2000ms for application pages
- [ ] Error rate < 1% under normal load
- [ ] CPU utilization stable under expected load
- [ ] Memory usage within configured limits

## Security Testing ✓

### Network Security
- [ ] Verify pods cannot access unauthorized services
- [ ] Confirm ingress-only access to application
- [ ] Test that egress is limited to required endpoints
- [ ] Validate DNS resolution works for allowed destinations

### Pod Security
- [ ] Attempt to execute privileged operations (should fail)
- [ ] Try to write to read-only filesystem (should fail)
- [ ] Verify container runs as expected non-root user
- [ ] Test that security context restrictions are enforced

## Rollback Plan ✓

### Emergency Procedures
- [ ] Document rollback command: `kubectl rollout undo deployment/contoso-air-web -n contoso-air`
- [ ] Verify previous deployment images are available
- [ ] Test rollback procedure in staging environment
- [ ] Document escalation procedures for critical issues

### Monitoring During Rollback
- [ ] Monitor application health during rollback
- [ ] Verify traffic is properly routed to healthy pods
- [ ] Check that rollback completes successfully
- [ ] Confirm application functionality post-rollback

## Documentation & Handover ✓

### Operations Documentation
- [ ] Update deployment runbook with any environment-specific notes
- [ ] Document any customizations made for this deployment
- [ ] Share access credentials and procedures with operations team
- [ ] Provide contact information for escalation

### Monitoring Setup
- [ ] Configure alerting contacts and escalation policies
- [ ] Set up on-call rotation for production support
- [ ] Document common troubleshooting procedures
- [ ] Create dashboard links for easy access

## Sign-off ✓

### Stakeholder Approval
- [ ] **Development Team Lead**: ________________________ Date: ________
- [ ] **DevOps Engineer**: ______________________________ Date: ________
- [ ] **Security Officer**: ______________________________ Date: ________
- [ ] **Operations Manager**: ____________________________ Date: ________

### Final Verification
- [ ] All checklist items completed successfully
- [ ] Production environment is stable and monitored
- [ ] Team is prepared for ongoing operations and support
- [ ] Documentation is complete and accessible

---

**Deployment Completed Successfully** ✅

**Environment**: _________________ **Date**: _________ **Time**: _________
**Deployed Version**: _____________ **Operator**: ___________________