#!/bin/bash
# Production Kubernetes Deployment Script for Contoso Air
# This script deploys the Contoso Air application with production-ready configurations

set -euo pipefail

# Configuration
NAMESPACE="contoso-air"
DEPLOYMENT_NAME="contoso-air-web"
KUSTOMIZE_DIR="$(dirname "$0")"
DRY_RUN=${DRY_RUN:-false}
WAIT_TIMEOUT=${WAIT_TIMEOUT:-600}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        log_error "kubectl cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    if ! command -v kustomize &> /dev/null; then
        log_warning "kustomize not found, using kubectl apply -k"
    fi
    
    log_success "Prerequisites check completed"
}

# Validate YAML files
validate_yaml() {
    log_info "Validating YAML files..."
    
    if command -v yamllint &> /dev/null; then
        yamllint "$KUSTOMIZE_DIR"/*.yaml || {
            log_warning "YAML linting found issues, but continuing..."
        }
    fi
    
    # Test kustomize build
    if kubectl kustomize "$KUSTOMIZE_DIR" > /dev/null; then
        log_success "Kustomize configuration is valid"
    else
        log_error "Kustomize configuration is invalid"
        exit 1
    fi
}

# Deploy function
deploy() {
    local dry_run_flag=""
    if [[ "$DRY_RUN" == "true" ]]; then
        dry_run_flag="--dry-run=client"
        log_info "Running in DRY RUN mode"
    fi
    
    log_info "Deploying Contoso Air application to Kubernetes..."
    
    # Apply namespace first
    kubectl apply $dry_run_flag -f "$KUSTOMIZE_DIR/k8s-namespace.yaml"
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Wait for namespace to be ready
        kubectl wait --for=condition=Active namespace/$NAMESPACE --timeout=60s
    fi
    
    # Apply all other resources
    kubectl apply $dry_run_flag -k "$KUSTOMIZE_DIR"
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Wait for deployment to be ready
        log_info "Waiting for deployment to be ready..."
        kubectl wait --for=condition=Available deployment/$DEPLOYMENT_NAME \
            -n $NAMESPACE --timeout=${WAIT_TIMEOUT}s
        
        # Check pod status
        log_info "Checking pod status..."
        kubectl get pods -n $NAMESPACE -l app=contoso-air-web
        
        # Check service endpoints
        log_info "Checking service endpoints..."
        kubectl get endpoints -n $NAMESPACE $DEPLOYMENT_NAME
        
        log_success "Deployment completed successfully!"
        
        # Show access information
        show_access_info
    else
        log_success "Dry run completed successfully!"
    fi
}

# Show access information
show_access_info() {
    log_info "Application access information:"
    
    echo "Namespace: $NAMESPACE"
    echo "Service: $DEPLOYMENT_NAME"
    
    # Get service information
    kubectl get service $DEPLOYMENT_NAME -n $NAMESPACE -o wide
    
    # Get ingress information if available
    if kubectl get ingress -n $NAMESPACE &> /dev/null; then
        echo ""
        log_info "Ingress information:"
        kubectl get ingress -n $NAMESPACE
    fi
    
    # Show monitoring endpoints
    echo ""
    log_info "Monitoring endpoints:"
    echo "Health check: http://<service-ip>/health"
    echo "Ready check: http://<service-ip>/ready"
    echo "Metrics: http://<service-ip>/metrics"
}

# Cleanup function
cleanup() {
    log_info "Cleaning up Contoso Air deployment..."
    
    # Delete all resources except namespace
    kubectl delete -k "$KUSTOMIZE_DIR" --ignore-not-found=true
    
    # Optionally delete namespace (commented out for safety)
    # kubectl delete namespace $NAMESPACE --ignore-not-found=true
    
    log_success "Cleanup completed"
}

# Status check function
status() {
    log_info "Checking Contoso Air application status..."
    
    if ! kubectl get namespace $NAMESPACE &> /dev/null; then
        log_error "Namespace $NAMESPACE does not exist"
        return 1
    fi
    
    echo "=== Namespace ==="
    kubectl get namespace $NAMESPACE
    
    echo -e "\n=== Deployments ==="
    kubectl get deployments -n $NAMESPACE
    
    echo -e "\n=== Pods ==="
    kubectl get pods -n $NAMESPACE -o wide
    
    echo -e "\n=== Services ==="
    kubectl get services -n $NAMESPACE
    
    echo -e "\n=== HPA ==="
    kubectl get hpa -n $NAMESPACE
    
    echo -e "\n=== PDB ==="
    kubectl get pdb -n $NAMESPACE
    
    echo -e "\n=== ConfigMaps ==="
    kubectl get configmaps -n $NAMESPACE
    
    echo -e "\n=== Secrets ==="
    kubectl get secrets -n $NAMESPACE
    
    echo -e "\n=== Events ==="
    kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | tail -10
}

# Main function
main() {
    case "${1:-}" in
        deploy)
            check_prerequisites
            validate_yaml
            deploy
            ;;
        cleanup)
            cleanup
            ;;
        status)
            status
            ;;
        validate)
            validate_yaml
            ;;
        *)
            echo "Usage: $0 {deploy|cleanup|status|validate}"
            echo ""
            echo "Commands:"
            echo "  deploy   - Deploy the application"
            echo "  cleanup  - Remove the application"
            echo "  status   - Show application status"
            echo "  validate - Validate YAML files"
            echo ""
            echo "Environment variables:"
            echo "  DRY_RUN=true     - Run deploy in dry-run mode"
            echo "  WAIT_TIMEOUT=600 - Deployment wait timeout in seconds"
            exit 1
            ;;
    esac
}

main "$@"