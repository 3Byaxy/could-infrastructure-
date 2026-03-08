#!/bin/bash
# =============================================================================
# File: scripts/deploy.sh
# Language: Bash/Shell Script
# What it does: Automates the Terraform deployment workflow by initializing
#               the backend, creating a plan, and applying the infrastructure.
#               Prints status messages at every step.
# Maintainer: @3Byaxy
# =============================================================================

# Exit immediately if any command fails.
set -e

# =============================================================================
# COLOR CODES — for readable, color-coded output
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # Reset color

print_info()    { echo -e "${BLUE}[INFO]${NC}    $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC}   $1"; }
print_step()    { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

# =============================================================================
# CONFIGURATION — adjust these variables before deploying
# =============================================================================
TERRAFORM_DIR="${1:-terraform}"   # Default to the 'terraform' directory
PLAN_FILE="/tmp/terraform-plan-$(date +%Y%m%d%H%M%S).tfplan"

# =============================================================================
# PREFLIGHT CHECKS — make sure all required tools are available
# =============================================================================
preflight_checks() {
  print_step "Running Preflight Checks"

  if ! command -v terraform &>/dev/null; then
    print_error "Terraform is not installed. Run scripts/setup.sh first."
    exit 1
  fi
  print_success "Terraform found: $(terraform version | head -1)"

  if [ ! -d "$TERRAFORM_DIR" ]; then
    print_error "Terraform directory '$TERRAFORM_DIR' not found."
    exit 1
  fi
  print_success "Terraform directory found: $TERRAFORM_DIR"

  # Check that AWS credentials are configured
  if ! aws sts get-caller-identity &>/dev/null 2>&1; then
    print_warning "AWS credentials not configured or AWS CLI not installed."
    print_warning "Run 'aws configure' or set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY."
    print_warning "Continuing anyway (Terraform will fail if credentials are missing)."
  else
    print_success "AWS credentials verified."
  fi
}

# =============================================================================
# TERRAFORM INIT — downloads providers and initializes the working directory
# =============================================================================
run_terraform_init() {
  print_step "Step 1: Terraform Init"
  print_info "Initializing Terraform in '$TERRAFORM_DIR'..."

  cd "$TERRAFORM_DIR"
  terraform init -upgrade   # -upgrade: update providers to latest allowed version

  print_success "Terraform initialized successfully."
}

# =============================================================================
# TERRAFORM PLAN — shows what changes Terraform will make without applying them
# =============================================================================
run_terraform_plan() {
  print_step "Step 2: Terraform Plan"
  print_info "Creating execution plan..."
  print_info "This shows what resources will be CREATED, CHANGED, or DESTROYED."

  terraform plan -out="$PLAN_FILE"

  print_success "Plan created and saved to: $PLAN_FILE"
  echo ""
  print_warning "Review the plan above carefully before applying!"
}

# =============================================================================
# CONFIRM APPLY — asks the user to confirm before making real changes
# =============================================================================
confirm_apply() {
  echo ""
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}  ⚠️  You are about to apply changes to REAL cloud infrastructure.${NC}"
  echo -e "${YELLOW}  ⚠️  This may incur AWS costs. Verify the plan above before continuing.${NC}"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""

  # Check if running in CI (non-interactive) — skip the prompt if so
  if [ "${CI:-false}" == "true" ] || [ "${AUTO_APPROVE:-false}" == "true" ]; then
    print_info "Running in CI/non-interactive mode. Auto-approving apply."
    return 0
  fi

  read -r -p "Type 'yes' to apply, anything else to cancel: " user_input
  if [ "$user_input" != "yes" ]; then
    print_warning "Apply cancelled by user."
    exit 0
  fi
}

# =============================================================================
# TERRAFORM APPLY — applies the planned changes to create/update infrastructure
# =============================================================================
run_terraform_apply() {
  print_step "Step 3: Terraform Apply"
  print_info "Applying changes to infrastructure..."

  terraform apply "$PLAN_FILE"

  print_success "Infrastructure deployed successfully! 🚀"
}

# =============================================================================
# SHOW OUTPUTS — display the important values from the deployed infrastructure
# =============================================================================
show_outputs() {
  print_step "Deployment Outputs"
  print_info "Here are the key details of your deployed infrastructure:"
  echo ""

  terraform output
}

# =============================================================================
# CLEANUP — remove the temporary plan file
# =============================================================================
cleanup() {
  if [ -f "$PLAN_FILE" ]; then
    rm -f "$PLAN_FILE"
    print_info "Cleaned up temporary plan file."
  fi
}

# Register cleanup to run when the script exits (even on error)
trap cleanup EXIT

# =============================================================================
# MAIN — orchestrates all deployment steps
# =============================================================================
main() {
  echo ""
  echo -e "${GREEN}════════════════════════════════════════${NC}"
  echo -e "${GREEN}  Cloud Infrastructure — Deploy Script  ${NC}"
  echo -e "${GREEN}  Maintainer: @3Byaxy                   ${NC}"
  echo -e "${GREEN}════════════════════════════════════════${NC}"

  preflight_checks
  run_terraform_init
  run_terraform_plan
  confirm_apply
  run_terraform_apply
  show_outputs

  echo ""
  print_success "Deployment complete! Your infrastructure is live. 🎉"
}

# Run the main function, passing all arguments
main "$@"
