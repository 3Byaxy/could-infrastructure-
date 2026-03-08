#!/bin/bash
# =============================================================================
# File: scripts/setup.sh
# Language: Bash/Shell Script
# What it does: Sets up a development environment by detecting the operating
#               system and installing Terraform, Ansible, Docker, kubectl,
#               and the AWS CLI. Verifies all installations at the end.
# Maintainer: @3Byaxy
# =============================================================================

# Exit immediately if any command fails (prevents silent errors).
set -e

# =============================================================================
# COLOR CODES — used to make success/failure messages easy to spot
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color — resets the color back to normal

# Helper functions for printing colored messages
print_info()    { echo -e "${BLUE}[INFO]${NC}    $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC}   $1"; }

# =============================================================================
# DETECT OPERATING SYSTEM
# =============================================================================
detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Check if this is Ubuntu or a Debian-based distro
    if [ -f /etc/os-release ]; then
      # shellcheck source=/dev/null
      source /etc/os-release
      OS_NAME="$NAME"
      OS_ID="$ID"
    else
      OS_NAME="Linux"
      OS_ID="linux"
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_NAME="macOS"
    OS_ID="macos"
  else
    print_error "Unsupported operating system: $OSTYPE"
    exit 1
  fi
  print_info "Detected OS: $OS_NAME"
}

# =============================================================================
# INSTALL TERRAFORM — used to provision cloud infrastructure
# =============================================================================
install_terraform() {
  print_info "Installing Terraform..."

  if command -v terraform &>/dev/null; then
    print_warning "Terraform is already installed: $(terraform version | head -1)"
    return
  fi

  if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" ]]; then
    # Import the HashiCorp GPG key and add the official repo
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update -y
    sudo apt-get install -y terraform
  elif [[ "$OS_ID" == "macos" ]]; then
    # Homebrew is the package manager for macOS
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
  else
    print_error "Cannot install Terraform on $OS_NAME automatically. Please install it manually."
    return 1
  fi

  print_success "Terraform installed successfully."
}

# =============================================================================
# INSTALL ANSIBLE — used to automate server configuration
# =============================================================================
install_ansible() {
  print_info "Installing Ansible..."

  if command -v ansible &>/dev/null; then
    print_warning "Ansible is already installed: $(ansible --version | head -1)"
    return
  fi

  if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" ]]; then
    sudo apt-get update -y
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt-get install -y ansible
  elif [[ "$OS_ID" == "macos" ]]; then
    brew install ansible
  else
    # Fallback: install via Python pip (works on most systems)
    pip3 install ansible
  fi

  print_success "Ansible installed successfully."
}

# =============================================================================
# INSTALL DOCKER — used to build and run containerized applications
# =============================================================================
install_docker() {
  print_info "Installing Docker..."

  if command -v docker &>/dev/null; then
    print_warning "Docker is already installed: $(docker --version)"
    return
  fi

  if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" ]]; then
    # Install Docker using the official convenience script
    curl -fsSL https://get.docker.com | sudo bash
    # Add the current user to the docker group so they can run Docker without sudo
    sudo usermod -aG docker "$USER"
    print_warning "You may need to log out and back in for Docker group permissions to take effect."
  elif [[ "$OS_ID" == "macos" ]]; then
    print_warning "Please install Docker Desktop for Mac from https://www.docker.com/products/docker-desktop"
    return 1
  else
    print_error "Cannot install Docker on $OS_NAME automatically."
    return 1
  fi

  print_success "Docker installed successfully."
}

# =============================================================================
# INSTALL KUBECTL — the command-line tool for managing Kubernetes clusters
# =============================================================================
install_kubectl() {
  print_info "Installing kubectl..."

  if command -v kubectl &>/dev/null; then
    print_warning "kubectl is already installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
    return
  fi

  if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" ]]; then
    # Download and install the latest stable kubectl binary
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl   # Clean up the downloaded file
  elif [[ "$OS_ID" == "macos" ]]; then
    brew install kubectl
  else
    print_error "Cannot install kubectl on $OS_NAME automatically."
    return 1
  fi

  print_success "kubectl installed successfully."
}

# =============================================================================
# INSTALL AWS CLI — used to interact with Amazon Web Services from the terminal
# =============================================================================
install_aws_cli() {
  print_info "Installing AWS CLI..."

  if command -v aws &>/dev/null; then
    print_warning "AWS CLI is already installed: $(aws --version)"
    return
  fi

  if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" ]]; then
    # Download and install the official AWS CLI v2 package
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
    unzip /tmp/awscliv2.zip -d /tmp
    sudo /tmp/aws/install
    rm -rf /tmp/awscliv2.zip /tmp/aws
  elif [[ "$OS_ID" == "macos" ]]; then
    brew install awscli
  else
    print_error "Cannot install AWS CLI on $OS_NAME automatically."
    return 1
  fi

  print_success "AWS CLI installed successfully."
}

# =============================================================================
# VERIFY INSTALLATIONS — confirm every tool was installed correctly
# =============================================================================
verify_installations() {
  print_info "Verifying all installations..."
  echo ""

  local all_ok=true

  # Helper to check a command and print its version
  check_tool() {
    local tool=$1
    local version_cmd=$2
    if command -v "$tool" &>/dev/null; then
      print_success "$tool: $(eval "$version_cmd" 2>&1 | head -1)"
    else
      print_error "$tool: NOT FOUND"
      all_ok=false
    fi
  }

  check_tool "terraform" "terraform version"
  check_tool "ansible"   "ansible --version"
  check_tool "docker"    "docker --version"
  check_tool "kubectl"   "kubectl version --client 2>/dev/null || echo 'client installed'"
  check_tool "aws"       "aws --version"

  echo ""
  if $all_ok; then
    print_success "All tools installed and verified successfully! 🎉"
  else
    print_error "Some tools failed to install. Please review the errors above."
    exit 1
  fi
}

# =============================================================================
# MAIN — runs all functions in order
# =============================================================================
main() {
  echo ""
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}  Cloud Infrastructure — Setup Script   ${NC}"
  echo -e "${BLUE}  Maintainer: @3Byaxy                   ${NC}"
  echo -e "${BLUE}========================================${NC}"
  echo ""

  detect_os
  echo ""

  install_terraform
  install_ansible
  install_docker
  install_kubectl
  install_aws_cli

  echo ""
  verify_installations
}

# Run the main function
main "$@"
