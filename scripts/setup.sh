#!/usr/bin/env bash
# setup.sh – Bootstrap local development environment
# Usage: ./scripts/setup.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

print_step() { echo -e "\n\033[1;34m==> $*\033[0m"; }
print_ok()   { echo -e "\033[1;32m  ✓ $*\033[0m"; }
print_err()  { echo -e "\033[1;31m  ✗ $*\033[0m" >&2; }

require_cmd() {
  if ! command -v "$1" &>/dev/null; then
    print_err "Required command not found: $1. Please install it and re-run."
    exit 1
  fi
}

# ── Pre-flight checks ──────────────────────────────────────────────────────────
print_step "Checking required tools"
require_cmd docker
require_cmd docker-compose || require_cmd "docker compose"
require_cmd node
require_cmd npm
require_cmd terraform
print_ok "All required tools are available"

# ── Copy environment files ─────────────────────────────────────────────────────
print_step "Setting up environment files"
if [ ! -f "$REPO_ROOT/backend/.env" ]; then
  cp "$REPO_ROOT/backend/.env.example" "$REPO_ROOT/backend/.env"
  print_ok "Created backend/.env from .env.example"
else
  print_ok "backend/.env already exists – skipping"
fi

# ── Install backend dependencies ───────────────────────────────────────────────
print_step "Installing backend dependencies"
cd "$REPO_ROOT/backend"
npm install
print_ok "Backend dependencies installed"

# ── Install frontend dependencies ─────────────────────────────────────────────
print_step "Installing frontend dependencies"
cd "$REPO_ROOT/frontend"
npm install
print_ok "Frontend dependencies installed"

# ── Start services with Docker Compose ────────────────────────────────────────
print_step "Starting services with Docker Compose"
cd "$REPO_ROOT"
docker compose up -d --build
print_ok "Services started"

echo ""
echo "────────────────────────────────────────────────"
echo "  Setup complete! Services are running:"
echo "    Frontend : http://localhost"
echo "    Backend  : http://localhost:3000"
echo "    Postgres : localhost:5432"
echo "────────────────────────────────────────────────"
