# Terraform Starter Guide

Welcome to the **Terraform** section of this cloud infrastructure project! 🏗️

Terraform lets you define your cloud infrastructure as code (IaC), which means you can version, review, and automate your infrastructure just like software.

---

## 📋 What's in This Folder

| File | Purpose |
|------|---------|
| `main.tf` | Core infrastructure resources (VPC, subnet, EC2 instance) |
| `variables.tf` | Configurable variables |
| `outputs.tf` | Values displayed after `terraform apply` |
| `example.tfvars` | Example variable values — copy to `terraform.tfvars` |

---

## 🚦 Getting Started

### Step 1: Install Terraform

Download from https://developer.hashicorp.com/terraform/install

Or in Codespaces, it's already installed! ✅

### Step 2: Configure AWS credentials

```bash
# Option 1: Environment variables (recommended for learning)
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Option 2: AWS CLI
aws configure
```

### Step 3: Set your variables

```bash
cp example.tfvars terraform.tfvars
# Edit terraform.tfvars with your values
```

### Step 4: Initialise Terraform

```bash
terraform init
```

### Step 5: Preview your changes

```bash
terraform plan
```

### Step 6: Apply the changes

```bash
terraform apply
```

### Step 7: Destroy resources when done

> ⚠️ Always destroy resources when you're done learning to avoid unexpected charges!

```bash
terraform destroy
```

---

## 🧠 Key Concepts

| Concept | What it means |
|---------|--------------|
| **Provider** | Plugin that talks to a cloud (e.g., AWS, Azure, GCP) |
| **Resource** | A piece of infrastructure (e.g., VM, database, network) |
| **Variable** | A configurable input to your code |
| **Output** | A value shown after apply (e.g., IP address) |
| **State** | A file tracking what Terraform has created |
| **Plan** | Preview of what Terraform *will* do |
| **Apply** | Actually creates/updates resources |

---

## ⚠️ Common Mistakes for Beginners

1. **Committing secrets** — Never commit `terraform.tfvars` or AWS credentials!
2. **Forgetting to destroy** — Cloud resources cost money. Always run `terraform destroy` after learning.
3. **Wide-open security groups** — Restrict SSH access to your IP only.

---

## 📚 Learn More

- [Terraform Tutorials (official)](https://developer.hashicorp.com/terraform/tutorials)
- [AWS Free Tier](https://aws.amazon.com/free/)
