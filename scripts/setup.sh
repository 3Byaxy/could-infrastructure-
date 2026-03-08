#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🚀 SETUP SCRIPT — Cloud Infrastructure Dev Environment
#
# This script installs all the tools you need to work with
# cloud infrastructure. It runs automatically when you open
# this project in GitHub Codespaces!
#
# 💡 To run manually: bash scripts/setup.sh
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# "set -e" means: stop immediately if any command fails.
# This prevents partially-installed setups that cause confusing errors.
set -e

# A helper function to print colorful section headers.
print_header() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  $1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

print_header "🚀 Starting Cloud Infrastructure Setup..."

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 1: Update package lists
# This refreshes the list of available software packages.
# Like hitting "refresh" on the app store!
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print_header "📦 Step 1: Updating package lists..."
sudo apt-get update -y

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 2: Install basic dependencies
# These are tools that other installers need to work.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print_header "🔧 Step 2: Installing basic tools..."
sudo apt-get install -y \
  curl \          # A tool for downloading files from the internet
  wget \          # Another download tool (some installers prefer wget)
  unzip \         # Needed to extract .zip files
  gnupg \         # Used to verify the identity of downloaded software
  software-properties-common \  # Helps add new software sources
  apt-transport-https \         # Allows downloading over HTTPS
  ca-certificates               # Trusted security certificates

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 3: Install Terraform
# Terraform is a tool for building cloud infrastructure with code.
# We download it from HashiCorp's official package repository.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print_header "🏗️  Step 3: Installing Terraform..."

# Add HashiCorp's GPG key so we can verify the download is authentic.
wget -O- https://apt.releases.hashicorp.com/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp's package repository to our list of software sources.
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update package list again (to include HashiCorp packages) then install Terraform.
sudo apt-get update -y && sudo apt-get install -y terraform

# Print the installed version to confirm it worked.
echo "✅ Terraform installed: $(terraform version | head -1)"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 4: Install Ansible
# Ansible is a tool for automating server configuration.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print_header "⚙️  Step 4: Installing Ansible..."

# Install Ansible using pip (Python package manager).
# pipx installs Ansible in an isolated environment to avoid conflicts.
sudo apt-get install -y python3-pip pipx
pipx ensurepath
pipx install ansible

echo "✅ Ansible installed: $(ansible --version | head -1)"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 5: Install kubectl
# kubectl (kube-control) is the command-line tool for managing Kubernetes clusters.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print_header "☸️  Step 5: Installing kubectl..."

# Download the latest stable kubectl binary directly from Kubernetes.
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

# Make it executable (runnable as a command).
chmod +x kubectl

# Move it to a system-wide location so you can run it from anywhere.
sudo mv kubectl /usr/local/bin/kubectl

echo "✅ kubectl installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 6: Install AWS CLI
# The AWS CLI lets you control Amazon Web Services from the terminal.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print_header "☁️  Step 6: Installing AWS CLI..."

# Download the AWS CLI installer package.
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"

# Unzip it into the /tmp directory.
unzip -q /tmp/awscliv2.zip -d /tmp/

# Run the installer.
sudo /tmp/aws/install

# Clean up the downloaded files to save disk space.
rm -rf /tmp/awscliv2.zip /tmp/aws

echo "✅ AWS CLI installed: $(aws --version)"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 7: Final message
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
print_header "🎉 Setup Complete!"
echo ""
echo "  All tools are installed and ready to use:"
echo "  • terraform  → Build cloud infrastructure as code"
echo "  • ansible    → Automate server configuration"
echo "  • kubectl    → Manage Kubernetes clusters"
echo "  • aws        → Control Amazon Web Services"
echo ""
echo "  🚀 Happy cloud building!"
echo ""
