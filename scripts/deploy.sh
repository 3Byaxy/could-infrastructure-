#!/usr/bin/env bash
# scripts/deploy.sh – Build Docker images and deploy to a Kubernetes cluster.
# Usage: bash scripts/deploy.sh [--env <dev|staging|prod>] [--tag <image-tag>]
#
# Prerequisites: docker, kubectl configured to point at the target cluster.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m"

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ─── Defaults ──────────────────────────────────────────────────────────────────

ENV="dev"
TAG="$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo latest)"
REGISTRY="${REGISTRY:-}"   # e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com

# ─── Argument parsing ──────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)  ENV="$2";  shift 2;;
    --tag)  TAG="$2";  shift 2;;
    --registry) REGISTRY="$2"; shift 2;;
    *) error "Unknown argument: $1";;
  esac
done

BACKEND_IMAGE="${REGISTRY:+$REGISTRY/}cloud-infra-backend:$TAG"
FRONTEND_IMAGE="${REGISTRY:+$REGISTRY/}cloud-infra-frontend:$TAG"

# ─── Build images ──────────────────────────────────────────────────────────────

info "Building backend image → $BACKEND_IMAGE"
docker build --target production -t "$BACKEND_IMAGE" "$REPO_ROOT/backend"

info "Building frontend image → $FRONTEND_IMAGE"
docker build --target production -t "$FRONTEND_IMAGE" "$REPO_ROOT/frontend"

# ─── Push images (if registry is set) ─────────────────────────────────────────

if [ -n "$REGISTRY" ]; then
  info "Pushing images to $REGISTRY…"
  docker push "$BACKEND_IMAGE"
  docker push "$FRONTEND_IMAGE"
fi

# ─── Apply Kubernetes manifests ───────────────────────────────────────────────

info "Applying Kubernetes manifests (env=$ENV)…"
kubectl apply -f "$REPO_ROOT/kubernetes/namespace.yaml"
kubectl apply -f "$REPO_ROOT/kubernetes/configmap.yaml"
kubectl apply -f "$REPO_ROOT/kubernetes/deployment.yaml"
kubectl apply -f "$REPO_ROOT/kubernetes/service.yaml"
kubectl apply -f "$REPO_ROOT/kubernetes/ingress.yaml"

# ─── Update image tags in the running deployment ──────────────────────────────

info "Updating deployment images…"
kubectl set image deployment/backend  backend="$BACKEND_IMAGE"  -n cloud-infra
kubectl set image deployment/frontend frontend="$FRONTEND_IMAGE" -n cloud-infra

# ─── Wait for rollout ─────────────────────────────────────────────────────────

info "Waiting for rollouts to complete…"
kubectl rollout status deployment/backend  -n cloud-infra --timeout=120s
kubectl rollout status deployment/frontend -n cloud-infra --timeout=120s

info "Deployment complete! ✓"
echo ""
echo "  Tag:         $TAG"
echo "  Environment: $ENV"
echo ""
echo "  Check pods:  kubectl get pods -n cloud-infra"
echo "  View logs:   kubectl logs -l app=backend -n cloud-infra --tail=50"
