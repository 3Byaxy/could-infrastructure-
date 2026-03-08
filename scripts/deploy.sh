#!/usr/bin/env bash
# deploy.sh – Deploy the application to Kubernetes
# Usage: ./scripts/deploy.sh [--env <dev|staging|prod>] [--image-tag <tag>]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENVIRONMENT="dev"
IMAGE_TAG="latest"
REGISTRY="${REGISTRY:-docker.io/myorg}"

print_step() { echo -e "\n\033[1;34m==> $*\033[0m"; }
print_ok()   { echo -e "\033[1;32m  ✓ $*\033[0m"; }
print_err()  { echo -e "\033[1;31m  ✗ $*\033[0m" >&2; }

require_cmd() {
  if ! command -v "$1" &>/dev/null; then
    print_err "Required command not found: $1"
    exit 1
  fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --env)       ENVIRONMENT="$2"; shift 2 ;;
    --image-tag) IMAGE_TAG="$2";   shift 2 ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done

# ── Pre-flight ─────────────────────────────────────────────────────────────────
print_step "Checking required tools"
require_cmd docker
require_cmd kubectl
print_ok "Tools available"

# ── Build & push Docker images ─────────────────────────────────────────────────
print_step "Building Docker images (tag: ${IMAGE_TAG})"
docker build -t "${REGISTRY}/cloud-infra-backend:${IMAGE_TAG}"  "$REPO_ROOT/backend"
docker build -t "${REGISTRY}/cloud-infra-frontend:${IMAGE_TAG}" "$REPO_ROOT/frontend"
print_ok "Images built"

print_step "Pushing images to registry"
docker push "${REGISTRY}/cloud-infra-backend:${IMAGE_TAG}"
docker push "${REGISTRY}/cloud-infra-frontend:${IMAGE_TAG}"
print_ok "Images pushed"

# ── Apply Kubernetes manifests ─────────────────────────────────────────────────
print_step "Applying Kubernetes manifests for environment: ${ENVIRONMENT}"
kubectl apply -f "$REPO_ROOT/kubernetes/namespaces/"
kubectl apply -f "$REPO_ROOT/kubernetes/deployments/"
kubectl apply -f "$REPO_ROOT/kubernetes/services/"
kubectl apply -f "$REPO_ROOT/kubernetes/ingress/"

# Update image tags in deployments
kubectl set image deployment/backend \
  backend="${REGISTRY}/cloud-infra-backend:${IMAGE_TAG}" \
  -n cloud-infra

kubectl set image deployment/frontend \
  frontend="${REGISTRY}/cloud-infra-frontend:${IMAGE_TAG}" \
  -n cloud-infra

print_ok "Manifests applied"

# ── Wait for rollout ───────────────────────────────────────────────────────────
print_step "Waiting for rollout to complete"
kubectl rollout status deployment/backend  -n cloud-infra --timeout=120s
kubectl rollout status deployment/frontend -n cloud-infra --timeout=120s
print_ok "Rollout complete"

echo ""
echo "────────────────────────────────────────────────"
echo "  Deployment to ${ENVIRONMENT} complete!"
echo "────────────────────────────────────────────────"
