#!/usr/bin/env bash
# setup.sh - Bootstrap local development environment
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
die() { log "ERROR: $*" >&2; exit 1; }

check_dependencies() {
    log "Checking required dependencies..."
    local deps=(docker git curl)
    for dep in "${deps[@]}"; do
        command -v "$dep" &>/dev/null || die "$dep is required but not installed."
        log "  ✓ $dep found"
    done
    docker compose version &>/dev/null || die "Docker Compose is required but not installed."
    log "  ✓ docker compose found"
}

setup_env_files() {
    log "Setting up environment files..."
    if [[ ! -f "$ROOT_DIR/backend/.env" ]]; then
        cp "$ROOT_DIR/backend/.env.example" "$ROOT_DIR/backend/.env"
        log "  Created backend/.env from .env.example"
    else
        log "  backend/.env already exists, skipping"
    fi
    if [[ ! -f "$ROOT_DIR/frontend/.env" ]]; then
        cp "$ROOT_DIR/frontend/.env.example" "$ROOT_DIR/frontend/.env"
        log "  Created frontend/.env from .env.example"
    else
        log "  frontend/.env already exists, skipping"
    fi
}

start_services() {
    log "Starting services with Docker Compose..."
    cd "$ROOT_DIR"
    docker compose up -d --build
    log "Services started. Waiting for health checks..."
    sleep 5
    docker compose ps
}

main() {
    log "=== Cloud Infrastructure Setup ==="
    check_dependencies
    setup_env_files
    start_services
    log ""
    log "=== Setup complete! ==="
    log "Frontend: http://localhost"
    log "Backend:  http://localhost:5000"
    log "Health:   http://localhost:5000/health"
}

main "$@"
