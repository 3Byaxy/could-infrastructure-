# Use Case 5: DevOps Workflow with CI/CD

Set up **GitHub Actions** workflows to automatically validate and deploy infrastructure code on every Git push.

---

## 📁 Directory Structure

```
05-devops-workflow/
├── .github/
│   └── workflows/
│       ├── terraform-validate.yml  # Validate Terraform on every PR/push
│       └── terraform-deploy.yml    # Deploy to AWS on merge to main
└── README.md
```

---

## Overview

This use case demonstrates two essential CI/CD workflows for Infrastructure as Code:

| Workflow | Trigger | What It Does |
|----------|---------|-------------|
| `terraform-validate.yml` | Push to any branch, Pull Requests | Runs `terraform fmt`, `terraform init`, and `terraform validate` |
| `terraform-deploy.yml` | Push to `main` (merge) | Runs `terraform plan` and `terraform apply` automatically |

---

## Setup

### Step 1 — Add AWS Credentials as GitHub Secrets

In your repository, go to **Settings → Secrets and variables → Actions** and add:

| Secret Name | Description |
|-------------|-------------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key |
| `AWS_REGION` | Target AWS region (e.g. `us-east-1`) |

### Step 2 — Copy Workflows to Your Repo Root

Copy the workflow files to your repository's `.github/workflows/` directory:

```bash
cp .github/workflows/*.yml ../../.github/workflows/
```

Or reference this directory as-is if you want to keep use cases isolated.

### Step 3 — Push Your Terraform Code

Make a change to any Terraform file and push. The `terraform-validate` workflow will run automatically.

---

## What You'll Learn

- Writing GitHub Actions workflows for Terraform
- Running `terraform fmt --check`, `terraform init`, and `terraform validate` in CI
- Using GitHub Secrets for secure credential management
- Automatically applying infrastructure changes on merge to `main`
- The basics of a GitOps workflow for infrastructure
