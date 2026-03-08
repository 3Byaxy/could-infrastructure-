#!/usr/bin/env bash
# =============================================================================
# setup.sh — Environment Dependency Setup Script
# =============================================================================
# This script detects the host operating system and installs all tools
# required for this cloud infrastructure project:
#   - Terraform
#   - Ansible
#   - kubectl
#   - Docker (CLI)
#   - AWS CLI v2
#
# Usage:
#   chmod +x scripts/setup.sh
#   ./scripts/setup.sh
#
# Supported platforms: Ubuntu/Debian, macOS (via Homebrew)
# =============================================================================

set -euo pipefail  # Exit on error, unset variable, or pipe failure

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------
info()    { echo -e "\033[1;34m[INFO]\033[0m  $*"; }
success() { echo -e "\033[1;32m[OK]\033[0m    $*"; }
warn()    { echo -e "\033[1;33m[WARN]\033[0m  $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; exit 1; }

command_exists() { command -v "$1" &>/dev/null; }

# -----------------------------------------------------------------------------
# Detect OS
# -----------------------------------------------------------------------------
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
  elif [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    case "$ID" in
      ubuntu|debian) OS="debian" ;;
      centos|rhel|fedora|amzn) OS="redhat" ;;
      *) error "Unsupported Linux distribution: $ID" ;;
    esac
  else
    error "Cannot detect operating system."
  fi
  info "Detected OS: $OS"
}

# -----------------------------------------------------------------------------
# Install Homebrew (macOS only)
# -----------------------------------------------------------------------------
install_homebrew() {
  if command_exists brew; then
    success "Homebrew already installed."
  else
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    success "Homebrew installed."
  fi
}

# -----------------------------------------------------------------------------
# Install Terraform
# -----------------------------------------------------------------------------
install_terraform() {
  if command_exists terraform; then
    success "Terraform already installed: $(terraform version -json | python3 -c 'import sys,json; print(json.load(sys.stdin)["terraform_version"])' 2>/dev/null || terraform version | head -1)"
    return
  fi

  info "Installing Terraform..."
  case "$OS" in
    macos)
      brew tap hashicorp/tap
      brew install hashicorp/tap/terraform
      ;;
    debian)
      sudo apt-get update -qq
      sudo apt-get install -y gnupg software-properties-common
      wget -O- https://apt.releases.hashicorp.com/gpg | \
        sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list
      sudo apt-get update -qq && sudo apt-get install -y terraform
      ;;
    redhat)
      sudo yum install -y yum-utils
      sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
      sudo yum install -y terraform
      ;;
  esac
  success "Terraform installed: $(terraform version | head -1)"
}

# -----------------------------------------------------------------------------
# Install Ansible
# -----------------------------------------------------------------------------
install_ansible() {
  if command_exists ansible; then
    success "Ansible already installed: $(ansible --version | head -1)"
    return
  fi

  info "Installing Ansible..."
  case "$OS" in
    macos)   brew install ansible ;;
    debian)  sudo apt-get install -y ansible ;;
    redhat)  sudo yum install -y ansible ;;
  esac
  success "Ansible installed: $(ansible --version | head -1)"
}

# -----------------------------------------------------------------------------
# Install kubectl
# -----------------------------------------------------------------------------
install_kubectl() {
  if command_exists kubectl; then
    success "kubectl already installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
    return
  fi

  info "Installing kubectl..."
  case "$OS" in
    macos)
      brew install kubectl
      ;;
    debian|redhat)
      KUBECTL_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
      curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
        -o /tmp/kubectl
      sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
      rm /tmp/kubectl
      ;;
  esac
  success "kubectl installed: $(kubectl version --client --short 2>/dev/null || true)"
}

# -----------------------------------------------------------------------------
# Install Docker CLI
# -----------------------------------------------------------------------------
install_docker() {
  if command_exists docker; then
    success "Docker already installed: $(docker --version)"
    return
  fi

  info "Installing Docker..."
  case "$OS" in
    macos)
      warn "Please install Docker Desktop for macOS from https://www.docker.com/products/docker-desktop/"
      ;;
    debian)
      sudo apt-get update -qq
      sudo apt-get install -y ca-certificates curl gnupg lsb-release
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update -qq
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
      sudo usermod -aG docker "$USER"
      ;;
    redhat)
      sudo yum install -y yum-utils
      sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
      sudo systemctl enable --now docker
      sudo usermod -aG docker "$USER"
      ;;
  esac
  success "Docker installed."
}

# -----------------------------------------------------------------------------
# Install AWS CLI v2
# -----------------------------------------------------------------------------
install_awscli() {
  if command_exists aws; then
    success "AWS CLI already installed: $(aws --version)"
    return
  fi

  info "Installing AWS CLI v2..."
  case "$OS" in
    macos)
      brew install awscli
      ;;
    debian|redhat)
      curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
      unzip -q /tmp/awscliv2.zip -d /tmp/
      sudo /tmp/aws/install
      rm -rf /tmp/awscliv2.zip /tmp/aws
      ;;
  esac
  success "AWS CLI installed: $(aws --version)"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
  info "Starting cloud infrastructure environment setup..."
  detect_os

  [[ "$OS" == "macos" ]] && install_homebrew

  install_terraform
  install_ansible
  install_kubectl
  install_docker
  install_awscli

  echo ""
  success "✅ All dependencies installed successfully!"
  info "Run 'aws configure' to set up your AWS credentials."
  info "Run 'cd terraform && terraform init' to initialise Terraform."
}

main "$@"
