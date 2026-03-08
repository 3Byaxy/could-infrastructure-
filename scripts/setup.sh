#!/usr/bin/env bash
# =============================================================================
# setup.sh — Bootstrap a new server or development environment
# =============================================================================
# Usage: ./scripts/setup.sh [--env dev|staging|prod]
#
# This script installs common tools needed for cloud infrastructure work.
# It works on Ubuntu/Debian systems.
#
# BEGINNER TIP: Run this script once on a fresh server to get ready quickly!
# =============================================================================

set -euo pipefail  # Exit on error, undefined var, or pipe failure

# --- Colours for pretty output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

# --- Helper functions ---
log_info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_success() { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Fail with a message
die() { log_error "$*"; exit 1; }

# Check if a command exists
command_exists() { command -v "$1" &>/dev/null; }

# --- Parse arguments ---
ENV="dev"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env) ENV="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--env dev|staging|prod]"
      exit 0
      ;;
    *) die "Unknown argument: $1" ;;
  esac
done

[[ "$ENV" =~ ^(dev|staging|prod)$ ]] || die "Invalid --env value: $ENV. Must be dev, staging, or prod."

# --- Main ---
echo ""
echo "╔══════════════════════════════════════╗"
echo "║  ☁️  Cloud Infrastructure Setup       ║"
echo "╚══════════════════════════════════════╝"
echo ""
log_info "Environment : $ENV"
log_info "OS          : $(uname -s) $(uname -m)"
log_info "User        : $(whoami)"
echo ""

# Ensure running on a supported OS
if ! command_exists apt-get; then
  die "This script requires a Debian/Ubuntu system (apt-get not found)."
fi

# Ensure not running as root (use sudo instead)
if [[ "$EUID" -eq 0 ]]; then
  log_warn "Running as root. It is recommended to run as a regular user with sudo access."
fi

# --- Step 1: Update system ---
log_info "Updating package lists..."
sudo apt-get update -qq
log_success "Package lists updated."

# --- Step 2: Install common tools ---
log_info "Installing common tools..."
PACKAGES=(
  curl
  wget
  git
  unzip
  jq
  ca-certificates
  gnupg
  lsb-release
  software-properties-common
  python3
  python3-pip
  python3-venv
)
sudo apt-get install -y -qq "${PACKAGES[@]}"
log_success "Common tools installed."

# --- Step 3: Install Docker ---
if command_exists docker; then
  log_success "Docker already installed: $(docker --version)"
else
  log_info "Installing Docker..."
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$(whoami)"
  log_success "Docker installed. You may need to log out and back in for group changes."
fi

# --- Step 4: Install kubectl ---
if command_exists kubectl; then
  log_success "kubectl already installed: $(kubectl version --client --short 2>/dev/null)"
else
  log_info "Installing kubectl..."
  KUBECTL_VERSION=$(curl -s https://dl.k8s.io/release/stable.txt)
  curl -sLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/kubectl
  log_success "kubectl ${KUBECTL_VERSION} installed."
fi

# --- Step 5: Install Terraform ---
if command_exists terraform; then
  log_success "Terraform already installed: $(terraform version -json | jq -r '.terraform_version')"
else
  log_info "Installing Terraform..."
  wget -qO- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt-get update -qq
  sudo apt-get install -y -qq terraform
  log_success "Terraform installed: $(terraform version | head -1)"
fi

# --- Step 6: Install Ansible ---
if command_exists ansible; then
  log_success "Ansible already installed: $(ansible --version | head -1)"
else
  log_info "Installing Ansible..."
  sudo apt-add-repository -y ppa:ansible/ansible
  sudo apt-get update -qq
  sudo apt-get install -y -qq ansible
  log_success "Ansible installed: $(ansible --version | head -1)"
fi

# --- Step 7: Install Python dependencies ---
if [[ -f "python/requirements.txt" ]]; then
  log_info "Installing Python dependencies..."
  pip3 install -q -r python/requirements.txt
  log_success "Python dependencies installed."
fi

# --- Summary ---
echo ""
echo "╔══════════════════════════════════════╗"
echo "║  ✅  Setup Complete!                  ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Installed versions:"
command_exists docker    && echo "  🐳 Docker     : $(docker --version)"
command_exists kubectl   && echo "  ⚓ kubectl    : $(kubectl version --client --short 2>/dev/null)"
command_exists terraform && echo "  🏗️  Terraform  : $(terraform version | head -1)"
command_exists ansible   && echo "  ⚙️  Ansible    : $(ansible --version | head -1)"
command_exists python3   && echo "  🐍 Python     : $(python3 --version)"
echo ""
log_success "You're ready to go! Happy cloud building. ☁️"
