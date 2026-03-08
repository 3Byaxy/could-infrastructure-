# ☁️ Cloud Infrastructure Project

A **production-ready cloud infrastructure** reference implementation using Terraform, Ansible, Kubernetes, a Node.js/Express backend API, and a React frontend. Everything is containerised with Docker and can be run locally with a single command.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Quick Start (Local)](#quick-start-local)
- [Running with Docker Compose](#running-with-docker-compose)
- [Running in GitHub Codespaces](#running-in-github-codespaces)
- [Backend API](#backend-api)
- [Frontend](#frontend)
- [Terraform – Cloud Provisioning](#terraform--cloud-provisioning)
- [Ansible – Configuration Management](#ansible--configuration-management)
- [Kubernetes – Container Orchestration](#kubernetes--container-orchestration)
- [Scripts](#scripts)
- [Environment Variables](#environment-variables)
- [Contributing](#contributing)
- [License](#license)

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                        Browser / Client                       │
└───────────────────────────────┬──────────────────────────────┘
                                │ HTTP
                    ┌───────────▼────────────┐
                    │  Nginx (Frontend :80)  │
                    │  React SPA             │
                    └───────────┬────────────┘
                                │ /api/* proxy
                    ┌───────────▼────────────┐
                    │  Node.js API (:3000)   │
                    │  Express + REST        │
                    └───────────┬────────────┘
                                │
                    ┌───────────▼────────────┐
                    │  PostgreSQL (:5432)    │
                    └────────────────────────┘
```

In production (AWS):

```
Internet → ALB → EKS (backend + frontend pods) → RDS PostgreSQL
                 EKS managed by Terraform + Ansible
```

---

## Project Structure

```
.
├── terraform/              # AWS infrastructure (VPC, EKS, RDS, ALB)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── providers.tf
├── ansible/                # Server configuration management
│   ├── inventory/
│   │   └── hosts.yml
│   ├── playbooks/
│   │   └── site.yml
│   └── roles/
│       ├── common/         # Base system config
│       ├── webserver/      # Nginx + app setup
│       └── database/       # PostgreSQL setup
├── kubernetes/             # K8s manifests
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── backend/                # Node.js / Express REST API
│   ├── src/
│   │   ├── index.js
│   │   └── index.test.js
│   ├── Dockerfile
│   ├── package.json
│   └── .env.example
├── frontend/               # React + Vite SPA
│   ├── src/
│   │   ├── App.jsx
│   │   ├── main.jsx
│   │   └── components/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── package.json
├── scripts/
│   ├── setup.sh            # Install all dependencies
│   └── deploy.sh           # Build + push + K8s deploy
├── docker-compose.yml      # Full local stack
├── README.md
└── LEARN.md                # Step-by-step learning guide
```

---

## Quick Start (Local)

### Prerequisites

| Tool | Minimum version |
|------|----------------|
| Node.js | 18 |
| npm | 9 |
| Docker | 24 |
| Docker Compose | v2 |

### 1 – Clone & bootstrap

```bash
git clone https://github.com/3Byaxy/could-infrastructure-.git
cd could-infrastructure-
bash scripts/setup.sh
```

### 2 – Start backend (without Docker)

```bash
cd backend
cp .env.example .env   # edit values if needed
npm run dev            # http://localhost:3000
```

### 3 – Start frontend (without Docker)

```bash
cd frontend
npm run dev            # http://localhost:5173
```

The Vite dev server proxies `/api/*` and `/health` to the backend automatically.

---

## Running with Docker Compose

```bash
# Build and start the full stack (DB + backend + frontend)
cp .env.example .env        # then set POSTGRES_PASSWORD in .env
docker compose up --build

# Visit the app
open http://localhost

# Tear down (keep volumes)
docker compose down

# Tear down AND delete data
docker compose down -v
```

| Service  | URL |
|----------|-----|
| Frontend | http://localhost |
| Backend  | http://localhost:3000 |
| Database | localhost:5432 |

---

## Running in GitHub Codespaces

1. Open the repository on GitHub and click **Code → Codespaces → Create codespace on main**.
2. Once the Codespace starts, open a terminal and run:

```bash
bash scripts/setup.sh
cp .env.example .env && echo "Set POSTGRES_PASSWORD in .env then press enter" && read _
docker compose up --build -d
```

3. GitHub Codespaces will automatically forward ports. Click the **Ports** tab to find the forwarded URL for port `80` (frontend) or `3000` (backend).

---

## Backend API

**Base URL (local):** `http://localhost:3000`

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Health check |
| `GET` | `/api` | API info & available endpoints |
| `GET` | `/api/items` | List all items |
| `POST` | `/api/items` | Create a new item |
| `GET` | `/api/items/:id` | Get item by ID |

### Example requests

```bash
# Health check
curl http://localhost:3000/health

# Create an item
curl -X POST http://localhost:3000/api/items \
  -H "Content-Type: application/json" \
  -d '{"name":"My Resource","description":"A cloud resource"}'

# List items
curl http://localhost:3000/api/items
```

### Run tests

```bash
cd backend
npm test
```

---

## Frontend

Built with **React 18 + Vite**. Features:

- Real-time API health badge (auto-refreshed every 30 s)
- Item list with live updates
- Add-item form with validation

```bash
cd frontend
npm run dev      # dev server at http://localhost:5173
npm run build    # production build → dist/
npm run preview  # preview production build
```

---

## Terraform – Cloud Provisioning

> **Targets AWS.** You need AWS credentials configured (`aws configure` or env vars).

```bash
cd terraform

# Initialise providers
terraform init

# Preview changes
terraform plan -var="db_password=yourSecretPassword"

# Apply (creates VPC, EKS, RDS, ALB, …)
terraform apply -var="db_password=yourSecretPassword"

# Destroy all resources
terraform destroy
```

### Key variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | AWS region |
| `environment` | `dev` | `dev`, `staging`, or `prod` |
| `instance_type` | `t3.micro` | EC2 / node instance type |
| `db_password` | _(required)_ | RDS master password |

See `terraform/variables.tf` for the full list.

---

## Ansible – Configuration Management

```bash
# Install Ansible (if needed)
pip install ansible

# Test connectivity
ansible -i ansible/inventory/hosts.yml all -m ping

# Run full playbook
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/site.yml

# Run only webserver role
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/site.yml \
  --tags webserver
```

Update `ansible/inventory/hosts.yml` with your actual server IP addresses before running.

---

## Kubernetes – Container Orchestration

```bash
# Apply all manifests
kubectl apply -f kubernetes/

# Check pods
kubectl get pods -n cloud-infra

# View backend logs
kubectl logs -l app=backend -n cloud-infra --tail=50

# Port-forward backend locally
kubectl port-forward svc/backend 3000:80 -n cloud-infra
```

### Secret required

The backend deployment expects a `backend-secrets` Kubernetes Secret:

```bash
kubectl create secret generic backend-secrets \
  --from-literal=database-url="postgresql://user:pass@host:5432/dbname" \
  -n cloud-infra
```

---

## Scripts

| Script | Description |
|--------|-------------|
| `scripts/setup.sh` | Install Node deps for backend & frontend |
| `scripts/deploy.sh` | Build Docker images, push to registry, apply K8s manifests |

```bash
# Deploy to staging with a custom tag
bash scripts/deploy.sh --env staging --tag v1.2.3 --registry 123.dkr.ecr.us-east-1.amazonaws.com
```

---

## Environment Variables

### Backend (`backend/.env`)

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_ENV` | `development` | Node environment |
| `PORT` | `3000` | HTTP port |
| `DATABASE_URL` | _(optional)_ | PostgreSQL connection string |
| `CORS_ORIGIN` | `*` | Allowed CORS origins |
| `LOG_LEVEL` | `info` | Log level |

Copy `backend/.env.example` → `backend/.env` and edit before starting.

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Commit your changes: `git commit -m "feat: add my feature"`
4. Push the branch: `git push origin feat/my-feature`
5. Open a Pull Request

Please follow [Conventional Commits](https://www.conventionalcommits.org/).

---

## License

MIT © 2024 Cloud Infrastructure Project
