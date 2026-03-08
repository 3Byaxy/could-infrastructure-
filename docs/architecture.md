# Architecture Overview

## System Architecture

```
                          ┌─────────────────────────────────────────────┐
                          │                  Internet                    │
                          └──────────────────────┬──────────────────────┘
                                                 │
                          ┌──────────────────────▼──────────────────────┐
                          │         AWS Application Load Balancer        │
                          │         (or Nginx Ingress on K8s)            │
                          └───────────────┬──────────────┬──────────────┘
                                          │              │
              ┌───────────────────────────▼──┐    ┌──────▼────────────────────────┐
              │       Frontend Service        │    │       Backend Service          │
              │  (React / Nginx, port 80)     │    │  (Flask / Gunicorn, port 5000) │
              └───────────────────────────────┘    └──────┬─────────────────┬──────┘
                                                          │                 │
                          ┌───────────────────────────────▼──┐    ┌────────▼──────────┐
                          │         PostgreSQL 16             │    │     Redis 7        │
                          │         (Database)                │    │     (Cache)        │
                          └──────────────────────────────────┘    └────────────────────┘
```

## Components

### Frontend

- **Technology**: React 18 (single-page application)
- **Web Server**: Nginx 1.27 (production), React dev server (development)
- **Container Port**: 80
- **Key features**: Responsive dashboard, REST API consumption, health-aware rendering

### Backend

- **Technology**: Python 3.12, Flask 3.0, Gunicorn
- **Container Port**: 5000
- **Key endpoints**:
  - `GET /health` — liveness probe
  - `GET /ready` — readiness probe
  - `GET /api/v1/info` — application metadata
  - `GET /api/v1/items` — item listing
  - `GET /api/v1/items/:id` — item detail

### Database

- **Technology**: PostgreSQL 16
- **Usage**: Persistent application data
- **Port**: 5432 (internal only)

### Cache

- **Technology**: Redis 7
- **Usage**: Session storage, rate limiting, caching
- **Port**: 6379 (internal only)

## Infrastructure Layers

### Layer 1 – Cloud Infrastructure (Terraform)

Provisions AWS resources:

| Resource       | Module  | Purpose                                    |
|----------------|---------|--------------------------------------------|
| VPC            | `vpc`   | Isolated network with public/private subnets |
| NAT Gateways   | `vpc`   | Outbound internet for private subnets      |
| EKS Cluster    | `eks`   | Managed Kubernetes control plane           |
| EKS Node Group | `eks`   | Worker nodes (EC2 Auto Scaling group)      |

### Layer 2 – Server Configuration (Ansible)

Configures servers using roles:

| Role     | Purpose                              |
|----------|--------------------------------------|
| `common` | OS hardening, package installation   |
| `docker` | Docker Engine installation           |
| `nginx`  | Nginx reverse proxy configuration    |

### Layer 3 – Container Orchestration (Kubernetes)

Deploys workloads via manifests:

| Resource   | File                                    | Purpose                    |
|------------|-----------------------------------------|----------------------------|
| Namespace  | `namespaces/namespace.yaml`             | Isolation boundary         |
| ConfigMap  | `configmaps/app-config.yaml`            | Non-secret configuration   |
| Deployment | `deployments/backend-deployment.yaml`   | Backend replica set        |
| Deployment | `deployments/frontend-deployment.yaml`  | Frontend replica set       |
| Service    | `services/backend-service.yaml`         | Internal backend routing   |
| Service    | `services/frontend-service.yaml`        | Internal frontend routing  |
| Ingress    | `ingress/ingress.yaml`                  | External TLS termination   |

## Environments

| Environment | Nodes      | Instance Type | VPC CIDR    |
|-------------|------------|---------------|-------------|
| dev         | 1–4        | t3.medium     | 10.0.0.0/16 |
| prod        | 2–10       | t3.large      | 10.1.0.0/16 |

## Security

- All worker nodes run in **private subnets** — no direct internet access
- EKS API server accessible via **private endpoint** (public endpoint enabled for admin access)
- Application secrets stored in **Kubernetes Secrets** (not ConfigMaps)
- Docker images run as **non-root users**
- Nginx enforces **TLS** via cert-manager + Let's Encrypt
