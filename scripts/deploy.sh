#!/usr/bin/env bash
# deploy.sh - Deploy application to Kubernetes or Docker Compose
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

ENVIRONMENT="${ENVIRONMENT:-dev}"
DEPLOY_TARGET="${DEPLOY_TARGET:-compose}"  # compose | kubernetes
IMAGE_TAG="${IMAGE_TAG:-latest}"
REGISTRY="${REGISTRY:-}"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
die() { log "ERROR: $*" >&2; exit 1; }

build_images() {
    log "Building Docker images (tag: $IMAGE_TAG)..."
    local backend_image="cloud-infra/backend:$IMAGE_TAG"
    local frontend_image="cloud-infra/frontend:$IMAGE_TAG"

    if [[ -n "$REGISTRY" ]]; then
        backend_image="$REGISTRY/$backend_image"
        frontend_image="$REGISTRY/$frontend_image"
    fi

    docker build -t "$backend_image" "$ROOT_DIR/backend"
    log "  ✓ Built $backend_image"

    docker build -t "$frontend_image" \
        --build-arg REACT_APP_API_URL="${REACT_APP_API_URL:-}" \
        "$ROOT_DIR/frontend"
    log "  ✓ Built $frontend_image"

    if [[ -n "$REGISTRY" ]]; then
        docker push "$backend_image"
        docker push "$frontend_image"
        log "  ✓ Pushed images to registry"
    fi
}

deploy_compose() {
    log "Deploying with Docker Compose (env: $ENVIRONMENT)..."
    cd "$ROOT_DIR"
    docker compose pull 2>/dev/null || true
    docker compose up -d --build --remove-orphans
    docker compose ps
    log "  ✓ Compose deployment complete"
}

deploy_kubernetes() {
    log "Deploying to Kubernetes (env: $ENVIRONMENT)..."
    command -v kubectl &>/dev/null || die "kubectl is required for Kubernetes deployment."

    kubectl apply -f "$ROOT_DIR/kubernetes/namespaces/"
    kubectl apply -f "$ROOT_DIR/kubernetes/configmaps/"
    kubectl apply -f "$ROOT_DIR/kubernetes/deployments/"
    kubectl apply -f "$ROOT_DIR/kubernetes/services/"
    kubectl apply -f "$ROOT_DIR/kubernetes/ingress/"

    log "Waiting for deployments to roll out..."
    kubectl rollout status deployment/backend -n cloud-infra --timeout=120s
    kubectl rollout status deployment/frontend -n cloud-infra --timeout=120s
    log "  ✓ Kubernetes deployment complete"
}

main() {
    log "=== Cloud Infrastructure Deploy ==="
    log "Environment: $ENVIRONMENT"
    log "Target:      $DEPLOY_TARGET"
    log "Image Tag:   $IMAGE_TAG"

    build_images

    case "$DEPLOY_TARGET" in
        compose)    deploy_compose ;;
        kubernetes) deploy_kubernetes ;;
        *) die "Unknown DEPLOY_TARGET: $DEPLOY_TARGET. Use 'compose' or 'kubernetes'." ;;
    esac

    log "=== Deployment complete! ==="
}

main "$@"
