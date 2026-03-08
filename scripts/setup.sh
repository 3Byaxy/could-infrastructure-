#!/usr/bin/env bash
# scripts/setup.sh – Bootstrap the local development environment.
# Usage: bash scripts/setup.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m"

info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }
require() { command -v "$1" &>/dev/null || error "'$1' is required but not installed."; }

# ─── Prerequisites ─────────────────────────────────────────────────────────────

info "Checking prerequisites…"
require node
require npm
require docker

NODE_MAJOR=$(node -e "process.stdout.write(process.versions.node.split('.')[0])")
[ "$NODE_MAJOR" -ge 18 ] || error "Node.js >=18 is required (found $(node -v))."

# ─── Backend dependencies ──────────────────────────────────────────────────────

info "Installing backend dependencies…"
cd "$REPO_ROOT/backend"
npm install

# ─── Frontend dependencies ─────────────────────────────────────────────────────

info "Installing frontend dependencies…"
cd "$REPO_ROOT/frontend"
npm install

cd "$REPO_ROOT"

# ─── Environment file ──────────────────────────────────────────────────────────

if [ ! -f backend/.env ]; then
  cp backend/.env.example backend/.env
  warn "Created backend/.env from .env.example – review and update values."
fi

# ─── Done ──────────────────────────────────────────────────────────────────────

info "Setup complete! Next steps:"
echo ""
echo "  For local development (without Docker):"
echo "    cd backend  && npm run dev      # starts API on :3000"
echo "    cd frontend && npm run dev      # starts UI  on :5173"
echo ""
echo "  For Docker Compose (full stack):"
echo "    docker compose up --build"
echo ""
echo "  Visit http://localhost (Docker) or http://localhost:5173 (Vite dev)"
