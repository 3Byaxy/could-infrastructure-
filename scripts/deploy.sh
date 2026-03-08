#!/usr/bin/env bash
# =============================================================================
# deploy.sh — Deploy the application to a target environment
# =============================================================================
# Usage: ./scripts/deploy.sh --env <dev|staging|prod> --tag <image-tag>
#
# This script:
#   1. Validates the environment
#   2. Builds and pushes the Docker image
#   3. Applies Kubernetes manifests
#   4. Waits for the rollout to complete
#   5. Performs a health check
#
# BEGINNER TIP: Read each step to understand a typical deployment pipeline!
# =============================================================================

set -euo pipefail

# --- Colours ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log_info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_success() { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
die()         { log_error "$*"; exit 1; }
command_exists() { command -v "$1" &>/dev/null; }

# --- Defaults ---
ENV=""
IMAGE_TAG="latest"
REGISTRY="ghcr.io/3byaxy/cloud-infra"
NAMESPACE="default"
DEPLOY_NAME="web-app"
TIMEOUT="300s"

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)    ENV="$2";       shift 2 ;;
    --tag)    IMAGE_TAG="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 --env <dev|staging|prod> [--tag <image-tag>]"
      echo ""
      echo "Options:"
      echo "  --env   Target environment (dev, staging, prod)"
      echo "  --tag   Docker image tag to deploy (default: latest)"
      exit 0
      ;;
    *) die "Unknown argument: $1" ;;
  esac
done

# --- Validate ---
[[ -n "$ENV" ]] || die "Missing required argument: --env"
[[ "$ENV" =~ ^(dev|staging|prod)$ ]] || die "Invalid --env: $ENV. Must be dev, staging, or prod."
command_exists docker   || die "docker is not installed. Run ./scripts/setup.sh first."
command_exists kubectl  || die "kubectl is not installed. Run ./scripts/setup.sh first."

IMAGE="${REGISTRY}:${IMAGE_TAG}"

# --- Banner ---
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  🚀  Cloud Infrastructure — Deploy           ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
log_info "Environment : $ENV"
log_info "Image       : $IMAGE"
log_info "Namespace   : $NAMESPACE"
log_info "Deployment  : $DEPLOY_NAME"
echo ""

# --- Confirm production deploys ---
if [[ "$ENV" == "prod" ]]; then
  log_warn "You are about to deploy to PRODUCTION!"
  read -rp "Are you sure? Type 'yes' to continue: " CONFIRM
  [[ "$CONFIRM" == "yes" ]] || { log_info "Deployment cancelled."; exit 0; }
fi

# --- Step 1: Build Docker image ---
log_info "Step 1/5: Building Docker image..."
docker build -t "$IMAGE" ./docker/
log_success "Image built: $IMAGE"

# --- Step 2: Push Docker image ---
log_info "Step 2/5: Pushing image to registry..."
# Uncomment to push (requires docker login):
# docker push "$IMAGE"
log_warn "Image push skipped (enable by uncommenting in deploy.sh)."
log_success "Image ready."

# --- Step 3: Apply Kubernetes manifests ---
log_info "Step 3/5: Applying Kubernetes manifests..."
kubectl apply -f kubernetes/deployment.yaml -n "$NAMESPACE"
kubectl apply -f kubernetes/service.yaml    -n "$NAMESPACE"

# Update image tag in the deployment
kubectl set image deployment/"$DEPLOY_NAME" \
  web-app="$IMAGE" \
  -n "$NAMESPACE" \
  2>/dev/null || log_warn "Could not update image (deployment may not exist yet — that's OK on first deploy)."

log_success "Kubernetes manifests applied."

# --- Step 4: Wait for rollout ---
log_info "Step 4/5: Waiting for rollout to complete (timeout: $TIMEOUT)..."
if kubectl rollout status deployment/"$DEPLOY_NAME" -n "$NAMESPACE" --timeout="$TIMEOUT"; then
  log_success "Rollout complete."
else
  log_error "Rollout timed out or failed! Check: kubectl describe deployment $DEPLOY_NAME"
  kubectl get pods -n "$NAMESPACE" -l app="$DEPLOY_NAME"
  exit 1
fi

# --- Step 5: Health check ---
log_info "Step 5/5: Running health check..."
POD=$(kubectl get pod -n "$NAMESPACE" -l app="$DEPLOY_NAME" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [[ -n "$POD" ]]; then
  HTTP_STATUS=$(kubectl exec "$POD" -n "$NAMESPACE" -- wget -qO- -S http://localhost/health 2>&1 | grep "HTTP/" | awk '{print $2}' || echo "unknown")
  if [[ "$HTTP_STATUS" == "200" ]]; then
    log_success "Health check passed! (HTTP $HTTP_STATUS)"
  else
    log_warn "Health check returned: $HTTP_STATUS. Verify manually."
  fi
else
  log_warn "No Pods found for health check. Verify manually."
fi

# --- Summary ---
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  ✅  Deployment Successful!                   ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "  Environment : $ENV"
echo "  Image       : $IMAGE"
echo ""
echo "Next steps:"
echo "  kubectl get pods -n $NAMESPACE"
echo "  kubectl port-forward service/$DEPLOY_NAME-service 8080:80 -n $NAMESPACE"
echo ""
