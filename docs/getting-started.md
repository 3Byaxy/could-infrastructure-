# Getting Started

This guide walks you through running the cloud infrastructure project locally and deploying it to a cloud environment.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) 24+
- [Docker Compose](https://docs.docker.com/compose/install/) v2+
- [Git](https://git-scm.com/)
- (Optional) [Terraform](https://developer.hashicorp.com/terraform/install) 1.5+ for provisioning AWS resources
- (Optional) [kubectl](https://kubernetes.io/docs/tasks/tools/) for Kubernetes deployments
- (Optional) [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) 2.15+ for server configuration

## Quick Start (Local Development)

1. **Clone the repository**

   ```bash
   git clone https://github.com/3Byaxy/could-infrastructure-.git
   cd could-infrastructure-
   ```

2. **Run the setup script**

   ```bash
   bash scripts/setup.sh
   ```

   This will:
   - Copy `.env.example` files to `.env`
   - Build Docker images
   - Start all services (backend, frontend, postgres, redis)

3. **Open the application**

   | Service  | URL                          |
   |----------|------------------------------|
   | Frontend | http://localhost             |
   | Backend  | http://localhost:5000        |
   | Health   | http://localhost:5000/health |

## Manual Local Setup

If you prefer to run services individually:

```bash
# Copy env files
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env

# Start all services
docker compose up -d --build

# View logs
docker compose logs -f

# Stop services
docker compose down
```

## Provisioning Cloud Infrastructure (AWS)

> **Requirements**: AWS CLI configured with appropriate permissions.

1. **Navigate to Terraform**

   ```bash
   cd terraform
   ```

2. **Initialize Terraform**

   ```bash
   terraform init
   ```

3. **Plan changes for your environment**

   ```bash
   terraform plan -var-file="environments/dev/terraform.tfvars"
   ```

4. **Apply infrastructure**

   ```bash
   terraform apply -var-file="environments/dev/terraform.tfvars"
   ```

5. **Configure kubectl**

   ```bash
   # Use the output command from Terraform
   aws eks update-kubeconfig --region us-east-1 --name cloud-infra-dev
   ```

## Deploying to Kubernetes

After your EKS cluster is ready:

```bash
# Deploy all Kubernetes manifests
DEPLOY_TARGET=kubernetes bash scripts/deploy.sh
```

Or manually:

```bash
kubectl apply -f kubernetes/namespaces/
kubectl apply -f kubernetes/configmaps/
kubectl apply -f kubernetes/deployments/
kubectl apply -f kubernetes/services/
kubectl apply -f kubernetes/ingress/
```

## Server Configuration with Ansible

```bash
cd ansible

# Run initial server setup
ansible-playbook -i inventory/hosts.ini playbooks/setup.yml

# Deploy application
ansible-playbook -i inventory/hosts.ini playbooks/deploy.yml
```

## Environment Variables

See the `.env.example` files in `backend/` and `frontend/` for all available configuration options.

Key variables:

| Variable       | Default          | Description                  |
|----------------|------------------|------------------------------|
| `APP_ENV`      | `development`    | Application environment      |
| `DB_PASSWORD`  | `changeme`       | PostgreSQL password          |
| `SECRET_KEY`   | *(change this)*  | Flask secret key             |
| `CORS_ORIGINS` | `*`              | Allowed CORS origins         |

> ⚠️ **Never commit `.env` files with real secrets to version control.**
