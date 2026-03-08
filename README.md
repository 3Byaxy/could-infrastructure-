# Cloud Infrastructure Learning Repository

A hands-on repository for learning and managing cloud infrastructure using **Infrastructure as Code (IaC)** tools including Terraform, Ansible, Docker, Kubernetes, and Python automation scripts.

---

## 📚 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Use Cases](#use-cases)
- [Getting Started](#getting-started)
- [Contributing](#contributing)

---

## Overview

This project is designed to help students, beginners, and cloud engineers learn how to build, deploy, and manage cloud infrastructure using industry-standard tools. Each use case is self-contained with starter scripts, documentation, and walkthroughs.

**Tools covered:**
- 🏗️ **Terraform** — Infrastructure as Code (AWS provisioning)
- 🐳 **Docker & Docker Compose** — Containerization and local service orchestration
- ☸️ **Kubernetes** — Container orchestration at scale
- 📦 **Ansible** — Configuration management and automation
- 🐍 **Python** — Scripting for health checks, backups, and automation
- ⚙️ **GitHub Actions** — CI/CD pipelines for infrastructure code

---

## Prerequisites

Before running any use case, ensure you have the following installed:

| Tool | Version | Install Guide |
|------|---------|--------------|
| Terraform | >= 1.5 | https://developer.hashicorp.com/terraform/install |
| Docker | >= 24.0 | https://docs.docker.com/get-docker/ |
| Docker Compose | >= 2.0 | https://docs.docker.com/compose/install/ |
| kubectl | >= 1.28 | https://kubernetes.io/docs/tasks/tools/ |
| Ansible | >= 2.14 | https://docs.ansible.com/ansible/latest/installation_guide/ |
| Python | >= 3.10 | https://www.python.org/downloads/ |
| AWS CLI | >= 2.0 | https://aws.amazon.com/cli/ |

> **Note:** AWS credentials must be configured via `aws configure` or environment variables before running Terraform and Python health check scripts.

---

## Use Cases

| # | Use Case | Tools Used | Directory |
|---|----------|-----------|-----------|
| 1 | [Static Website Deployment](#1-static-website-deployment) | Terraform, Docker Compose | [`use-cases/01-static-website/`](use-cases/01-static-website/) |
| 2 | [Automated Server Provisioning](#2-automated-server-provisioning) | Terraform, Ansible | [`use-cases/02-server-provisioning/`](use-cases/02-server-provisioning/) |
| 3 | [Kubernetes App Deployment](#3-kubernetes-app-deployment) | Kubernetes, Docker | [`use-cases/03-kubernetes-deployment/`](use-cases/03-kubernetes-deployment/) |
| 4 | [Disaster Recovery Infrastructure](#4-disaster-recovery-infrastructure) | Terraform, Python | [`use-cases/04-disaster-recovery/`](use-cases/04-disaster-recovery/) |
| 5 | [DevOps Workflow with CI/CD](#5-devops-workflow-with-cicd) | GitHub Actions, Terraform | [`use-cases/05-devops-workflow/`](use-cases/05-devops-workflow/) |
| 6 | [Cloud Infrastructure Health Checks](#6-cloud-infrastructure-health-checks) | Python, AWS | [`use-cases/06-health-checks/`](use-cases/06-health-checks/) |
| 7 | [Containerized App Deployment](#7-containerized-app-deployment) | Docker, Docker Compose | [`use-cases/07-containerized-app/`](use-cases/07-containerized-app/) |

---

### 1. Static Website Deployment

Deploy a static HTML website to AWS S3 using Terraform, or run it locally with Docker Compose and Nginx.

📁 [`use-cases/01-static-website/`](use-cases/01-static-website/)

**What you'll learn:**
- Provisioning an S3 bucket with static website hosting via Terraform
- Enabling public access and bucket policies
- Running a local web server with Docker Compose

---

### 2. Automated Server Provisioning

Launch an EC2 instance on AWS using Terraform and configure it with Ansible — installing Nginx, setting up a firewall, and deploying your app.

📁 [`use-cases/02-server-provisioning/`](use-cases/02-server-provisioning/)

**What you'll learn:**
- Provisioning EC2 instances with Terraform
- Writing Ansible playbooks for configuration management
- Managing SSH key pairs and security groups

---

### 3. Kubernetes App Deployment

Deploy a containerized web application to a Kubernetes cluster using manifests, and test it locally with Docker Compose.

📁 [`use-cases/03-kubernetes-deployment/`](use-cases/03-kubernetes-deployment/)

**What you'll learn:**
- Writing Kubernetes Deployments, Services, and Namespaces
- Packaging apps with Docker
- Local multi-service testing with Docker Compose

---

### 4. Disaster Recovery Infrastructure

Define backup plans, automated restoration scripts, and recovery infrastructure using Python and Terraform.

📁 [`use-cases/04-disaster-recovery/`](use-cases/04-disaster-recovery/)

**What you'll learn:**
- Creating S3-based backup buckets with versioning
- Writing Python scripts to back up and restore EC2 snapshots
- Automating disaster recovery workflows

---

### 5. DevOps Workflow with CI/CD

Set up GitHub Actions workflows to automatically validate and deploy infrastructure code on every Git push.

📁 [`use-cases/05-devops-workflow/`](use-cases/05-devops-workflow/)

**What you'll learn:**
- Creating GitHub Actions workflows for Terraform
- Running `terraform validate` and `terraform plan` in CI
- Deploying infrastructure automatically on merge to main

---

### 6. Cloud Infrastructure Health Checks

Use Python scripts to verify that AWS resources (EC2 instances, S3 buckets) are running and healthy. Automate periodic health reports.

📁 [`use-cases/06-health-checks/`](use-cases/06-health-checks/)

**What you'll learn:**
- Using the `boto3` AWS SDK in Python
- Checking EC2 instance states and S3 bucket accessibility
- Generating health reports

---

### 7. Containerized App Deployment

Package a web app with a database and cache layer using Docker and Docker Compose for local development and testing.

📁 [`use-cases/07-containerized-app/`](use-cases/07-containerized-app/)

**What you'll learn:**
- Writing Dockerfiles for Python web apps
- Defining multi-service environments with Docker Compose
- Connecting web apps to PostgreSQL and Redis containers

---

## Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/3Byaxy/could-infrastructure-.git
   cd could-infrastructure-
   ```

2. **Pick a use case** from the table above and navigate to its directory.

3. **Follow the `README.md`** inside each use case directory for step-by-step instructions.

---

## Contributing

Contributions, improvements, and new use cases are welcome! Please open an issue or pull request.

---

> Built for students, beginners, and cloud enthusiasts. Adapt it for personal projects, classroom learning, or business experimentation.
