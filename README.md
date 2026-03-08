# ☁️ Cloud Infrastructure

A full-stack cloud infrastructure project demonstrating real-world DevOps practices using **Terraform**, **Ansible**, **Kubernetes**, **Docker**, and a **Node.js/React** application.

---

## 📁 Project Structure

```
could-infrastructure-/
├── terraform/               # Infrastructure as Code (AWS)
│   ├── provider.tf          # AWS provider & Terraform settings
│   ├── main.tf              # VPC, subnets, ALB, RDS, EKS resources
│   ├── variables.tf         # Input variables
│   └── outputs.tf           # Output values
│
├── ansible/                 # Configuration Management
│   ├── inventory/hosts      # Server inventory
│   ├── playbooks/
│   │   ├── site.yml         # Main playbook
│   │   └── setup.yml        # Initial server setup
│   └── roles/
│       ├── common/          # Base configuration for all servers
│       └── webserver/       # Nginx web server role
│
├── kubernetes/              # Kubernetes Manifests
│   ├── namespaces/          # Namespace definitions
│   ├── deployments/         # Backend and frontend deployments
│   ├── services/            # ClusterIP services
│   └── ingress/             # Nginx ingress rules
│
├── backend/                 # Node.js / Express API
│   ├── src/
│   │   ├── index.js         # Entry point
│   │   └── app.js           # Express app & routes
│   ├── Dockerfile           # Multi-stage production build
│   ├── package.json
│   └── .env.example
│
├── frontend/                # React Application
│   ├── src/
│   │   ├── App.js           # Main React component
│   │   ├── App.css          # Component styles
│   │   ├── index.js         # React entry point
│   │   └── index.css        # Global styles
│   ├── public/index.html
│   ├── Dockerfile           # Multi-stage build with Nginx
│   ├── nginx.conf           # Nginx config for SPA + API proxy
│   └── package.json
│
├── scripts/
│   ├── setup.sh             # Bootstrap local development
│   └── deploy.sh            # Deploy to Kubernetes
│
├── docker-compose.yml       # Local development stack
├── README.md
└── LEARN.md                 # Guided learning walkthrough
```

---

## 🚀 Quick Start

### Prerequisites

| Tool | Version |
|------|---------|
| Docker & Docker Compose | ≥ 24.x |
| Node.js | ≥ 18.x |
| Terraform | ≥ 1.3 |
| kubectl | ≥ 1.28 |
| Ansible | ≥ 2.14 |

### Local Development (Docker Compose)

```bash
# 1. Clone the repository
git clone https://github.com/3Byaxy/could-infrastructure-.git
cd could-infrastructure-

# 2. Run the automated setup script
chmod +x scripts/setup.sh
./scripts/setup.sh
```

Or manually:

```bash
# Copy environment variables
cp backend/.env.example backend/.env

# Start all services
docker compose up -d --build

# Check running containers
docker compose ps
```

**Services:**
- Frontend: http://localhost
- Backend API: http://localhost:3000
- PostgreSQL: localhost:5432

---

## 🏗️ Infrastructure Deployment (AWS)

### 1. Terraform – Provision AWS Resources

```bash
cd terraform

# Initialise providers
terraform init

# Preview changes
terraform plan -var="db_password=YOUR_SECURE_PASSWORD"

# Apply
terraform apply -var="db_password=YOUR_SECURE_PASSWORD"
```

This provisions:
- **VPC** with public & private subnets across 2 AZs
- **NAT Gateways** for private subnet egress
- **Application Load Balancer**
- **RDS PostgreSQL** in private subnets
- **EKS Cluster** with a managed node group

### 2. Ansible – Configure Servers

```bash
cd ansible

# Update inventory/hosts with your server IPs

# Run full configuration
ansible-playbook -i inventory/hosts playbooks/site.yml

# Or run initial setup only
ansible-playbook -i inventory/hosts playbooks/setup.yml
```

### 3. Kubernetes – Deploy the Application

```bash
# Deploy to the cluster
./scripts/deploy.sh --env prod --image-tag v1.0.0

# Or apply manifests manually
kubectl apply -f kubernetes/namespaces/
kubectl apply -f kubernetes/deployments/
kubectl apply -f kubernetes/services/
kubectl apply -f kubernetes/ingress/

# Check status
kubectl get all -n cloud-infra
```

---

## 🔧 Development

### Backend

```bash
cd backend
npm install
cp .env.example .env
npm run dev    # Starts with nodemon (hot reload)
```

API endpoints:
| Method | Path | Description |
|--------|------|-------------|
| GET | /health | Health check |
| GET | /api | API info |
| GET | /api/items | List all items |
| POST | /api/items | Create an item |

### Frontend

```bash
cd frontend
npm install
npm start      # React dev server on http://localhost:3001
```

---

## 🐳 Docker

Build individual images:

```bash
# Backend
docker build -t cloud-infra-backend ./backend

# Frontend
docker build -t cloud-infra-frontend ./frontend
```

---

## 📖 Learning Guide

See **[LEARN.md](./LEARN.md)** for a step-by-step walkthrough of every component.

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes
4. Push to the branch and open a Pull Request

---

## 📄 License

MIT — see [LICENSE](LICENSE) for details.
