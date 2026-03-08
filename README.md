# Cloud Infrastructure 🚀

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/3Byaxy/could-infrastructure-)
[![Terraform Lint](https://github.com/3Byaxy/could-infrastructure-/actions/workflows/terraform-lint.yml/badge.svg)](https://github.com/3Byaxy/could-infrastructure-/actions/workflows/terraform-lint.yml)
[![Docker Build](https://github.com/3Byaxy/could-infrastructure-/actions/workflows/docker-build.yml/badge.svg)](https://github.com/3Byaxy/could-infrastructure-/actions/workflows/docker-build.yml)

> A beginner-friendly, real-world cloud infrastructure project using Terraform, Ansible, Docker, Kubernetes, Python, and Bash. Perfect for learning how modern cloud systems are built and deployed.

---

## 📖 What Is This Project?

This repository contains **working code** that demonstrates how cloud infrastructure is built and managed in the real world. Every file is heavily commented to help beginners understand not just *what* the code does, but *why*.

Whether you're a student, a junior developer, or just curious about DevOps — this project is for you.

---

## 🛠️ Languages & Tools Used

| Icon | Language / Tool | Purpose |
|------|----------------|---------|
| 🟣 | **HCL / Terraform** | Provision AWS cloud resources (VPC, EC2, S3) |
| 🟡 | **YAML / Ansible** | Automate server configuration and setup |
| 🟡 | **YAML / Kubernetes** | Deploy and scale containerized applications |
| 🟡 | **YAML / Docker Compose** | Run multi-container apps locally |
| 🟡 | **YAML / GitHub Actions** | Automate CI/CD pipelines |
| 🔵 | **Dockerfile** | Build lightweight, production-ready container images |
| 🟢 | **Bash** | Automate setup and deployment tasks |
| 🟠 | **Python** | Inspect and report on live AWS infrastructure |

---

## 📁 Project Structure

```
could-infrastructure-/
├── terraform/
│   ├── main.tf          # AWS resources: VPC, EC2, S3 bucket
│   ├── variables.tf     # Input variables (region, instance type, etc.)
│   └── outputs.tf       # Output values (EC2 IP, VPC ID, S3 name)
│
├── ansible/
│   ├── playbook.yml     # Installs and configures Nginx on remote servers
│   └── inventory.ini    # List of servers for Ansible to manage
│
├── kubernetes/
│   ├── deployment.yaml  # Deploys Nginx with 2 replicas and health checks
│   └── service.yaml     # Exposes the deployment via a LoadBalancer
│
├── docker/
│   ├── Dockerfile       # Multi-stage build: builder → nginx:alpine
│   └── docker-compose.yml # Web + PostgreSQL multi-service app
│
├── scripts/
│   ├── setup.sh         # Installs all required tools (Terraform, Docker, etc.)
│   ├── deploy.sh        # Runs terraform init → plan → apply
│   └── check_infra.py   # Lists running EC2 instances and S3 buckets via boto3
│
├── .github/
│   └── workflows/
│       ├── terraform-lint.yml  # CI: checks Terraform formatting and validity
│       └── docker-build.yml    # CI: builds the Docker image on every push
│
├── README.md            # This file
└── LEARN.md             # Beginner guide explaining every language used
```

---

## ⚡ Getting Started

### Option 1 — Open in GitHub Codespaces (Easiest)

Click the button below to launch a fully configured development environment in your browser — no local setup required!

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/3Byaxy/could-infrastructure-)

### Option 2 — Local Setup

#### Prerequisites

Make sure you have the following installed:
- [Git](https://git-scm.com/)
- [Bash](https://www.gnu.org/software/bash/) (Linux/macOS included; Windows use WSL2)

#### Step 1: Clone the repository

```bash
git clone https://github.com/3Byaxy/could-infrastructure-.git
cd could-infrastructure-
```

#### Step 2: Install all required tools automatically

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

This script detects whether you're on **Ubuntu** or **macOS** and installs:
- Terraform
- Ansible
- Docker
- kubectl
- AWS CLI

#### Step 3: Configure AWS credentials

```bash
aws configure
# Enter your Access Key ID, Secret Access Key, region (e.g. us-east-1), and output format (json)
```

#### Step 4: Deploy infrastructure with Terraform

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

This will:
1. Run `terraform init` to download providers
2. Run `terraform plan` to show what will be created
3. Ask you to confirm before applying
4. Run `terraform apply` to create the real AWS resources

#### Step 5: Run the infrastructure health check

```bash
pip3 install boto3
python3 scripts/check_infra.py
```

---

## 🐳 Running Locally with Docker Compose

To run the web + database stack on your local machine:

```bash
cd docker
docker compose up -d
```

Then open your browser and visit: **http://localhost**

To stop the containers:

```bash
docker compose down
```

---

## ☸️ Deploying to Kubernetes

If you have a Kubernetes cluster (e.g., minikube, EKS, GKE):

```bash
# Deploy the Nginx app with 2 replicas
kubectl apply -f kubernetes/deployment.yaml

# Expose it via a LoadBalancer service
kubectl apply -f kubernetes/service.yaml

# Check the status of your pods
kubectl get pods

# Get the external IP of the service
kubectl get service nginx-service
```

---

## 🤖 Running Ansible

```bash
# Test the playbook locally (installs Nginx on localhost)
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml

# Run against remote servers (update inventory.ini with your server IPs first)
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --ask-become-pass
```

---

## 🔄 CI/CD Pipelines

This project includes two GitHub Actions workflows:

| Workflow | Trigger | What it does |
|----------|---------|-------------|
| `terraform-lint.yml` | Push/PR to `main` (terraform/ changes) | Checks `terraform fmt` and runs `terraform validate` |
| `docker-build.yml` | Push/PR to `main` (docker/ changes) | Builds the Docker image to verify it compiles |

---

## 🔐 Security Notes

- **Never commit AWS credentials** to this repository
- Use `aws configure` or environment variables for authentication
- The S3 bucket has **public access blocked** by default
- The EC2 security group allows SSH — restrict this to your IP in production
- Change the default PostgreSQL password in `docker-compose.yml` before deploying to production

---

## 📚 Want to Learn More?

See **[LEARN.md](LEARN.md)** for a beginner-friendly guide explaining:
- What is Terraform / HCL?
- What is Ansible?
- What is Docker?
- What is Kubernetes?
- What is Bash?
- What is Python in DevOps?
- Free resources to learn each tool

---

## 🤝 Contributing

This project is open to contributions! Feel free to:
- Fix typos or improve comments
- Add new features or examples
- Open issues with questions or suggestions

---

## 📄 License

This project is licensed under the **MIT License** — feel free to use it for learning and personal projects.

---

*Maintained by [@3Byaxy](https://github.com/3Byaxy)*