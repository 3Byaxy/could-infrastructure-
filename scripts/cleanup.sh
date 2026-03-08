#!/usr/bin/env bash
# cleanup.sh - Tear down local development environment
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

TARGET="${TARGET:-compose}"  # compose | kubernetes
PRUNE_VOLUMES="${PRUNE_VOLUMES:-false}"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
die() { log "ERROR: $*" >&2; exit 1; }

cleanup_compose() {
    log "Stopping Docker Compose services..."
    cd "$ROOT_DIR"
    if [[ "$PRUNE_VOLUMES" == "true" ]]; then
        docker compose down -v --remove-orphans
        log "  ✓ Containers and volumes removed"
    else
        docker compose down --remove-orphans
        log "  ✓ Containers removed (volumes preserved)"
        log "  Tip: set PRUNE_VOLUMES=true to also remove data volumes"
    fi
}

cleanup_kubernetes() {
    log "Removing Kubernetes resources from cloud-infra namespace..."
    command -v kubectl &>/dev/null || die "kubectl is required."
    kubectl delete -f "$ROOT_DIR/kubernetes/ingress/" --ignore-not-found
    kubectl delete -f "$ROOT_DIR/kubernetes/services/" --ignore-not-found
    kubectl delete -f "$ROOT_DIR/kubernetes/deployments/" --ignore-not-found
    kubectl delete -f "$ROOT_DIR/kubernetes/configmaps/" --ignore-not-found
    kubectl delete -f "$ROOT_DIR/kubernetes/namespaces/" --ignore-not-found
    log "  ✓ Kubernetes resources removed"
}

main() {
    log "=== Cloud Infrastructure Cleanup ==="
    case "$TARGET" in
        compose)    cleanup_compose ;;
        kubernetes) cleanup_kubernetes ;;
        *) die "Unknown TARGET: $TARGET. Use 'compose' or 'kubernetes'." ;;
    esac
    log "=== Cleanup complete! ==="
}

main "$@"
