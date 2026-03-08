# Cloud Infrastructure

A complete cloud infrastructure project with Terraform, Ansible, Kubernetes, a Python/Flask backend, and a React frontend — fully containerized and ready to deploy.

## Project Structure

```
could-infrastructure-/
├── terraform/                  # Infrastructure as Code (AWS)
│   ├── main.tf                 # Root module
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── modules/
│   │   ├── vpc/                # VPC, subnets, NAT gateways
│   │   └── eks/                # EKS cluster and node group
│   └── environments/
│       ├── dev/terraform.tfvars
│       └── prod/terraform.tfvars
├── ansible/                    # Server configuration management
│   ├── ansible.cfg
│   ├── inventory/hosts.ini
│   ├── playbooks/
│   │   ├── setup.yml           # Initial server setup
│   │   └── deploy.yml          # Application deployment
│   └── roles/
│       ├── common/             # OS hardening, packages
│       ├── docker/             # Docker Engine setup
│       └── nginx/              # Nginx reverse proxy
├── kubernetes/                 # Kubernetes manifests
│   ├── namespaces/
│   ├── deployments/
│   ├── services/
│   ├── ingress/
│   └── configmaps/
├── backend/                    # Flask REST API
│   ├── src/app.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env.example
├── frontend/                   # React dashboard
│   ├── src/
│   ├── public/
│   ├── package.json
│   ├── Dockerfile
│   ├── nginx.conf
│   └── .env.example
├── scripts/                    # Automation scripts
│   ├── setup.sh                # Bootstrap local environment
│   ├── deploy.sh               # Build and deploy
│   └── cleanup.sh              # Tear down environment
├── docs/                       # Documentation
│   ├── getting-started.md
│   ├── architecture.md
│   └── deployment.md
└── docker-compose.yml          # Local development orchestration
```

## Quick Start

```bash
# Clone the repository
git clone https://github.com/3Byaxy/could-infrastructure-.git
cd could-infrastructure-

# Start everything locally
bash scripts/setup.sh
```

| Service  | URL                          |
|----------|------------------------------|
| Frontend | http://localhost             |
| Backend  | http://localhost:5000        |
| Health   | http://localhost:5000/health |

## Documentation

- [Getting Started](docs/getting-started.md) — local setup and cloud provisioning
- [Architecture](docs/architecture.md) — system design and component overview
- [Deployment Guide](docs/deployment.md) — Compose, Kubernetes, and CI/CD

## Tech Stack

| Layer          | Technology              |
|----------------|-------------------------|
| Cloud          | AWS (EKS, VPC)          |
| IaC            | Terraform 1.5+          |
| Config Mgmt    | Ansible 2.15+           |
| Orchestration  | Kubernetes 1.29         |
| Backend        | Python 3.12 + Flask 3.0 |
| Frontend       | React 18 + Nginx        |
| Database       | PostgreSQL 16           |
| Cache          | Redis 7                 |
| Containers     | Docker / Docker Compose |

## License

MIT