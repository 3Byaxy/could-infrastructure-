# 📚 LEARN.md — Cloud Infrastructure Learning Guide

This guide walks you through every component of the project to help you understand modern cloud infrastructure patterns.

---

## Table of Contents

1. [Overview & Architecture](#1-overview--architecture)
2. [Terraform — Infrastructure as Code](#2-terraform--infrastructure-as-code)
3. [Ansible — Configuration Management](#3-ansible--configuration-management)
4. [Docker — Containerisation](#4-docker--containerisation)
5. [Kubernetes — Container Orchestration](#5-kubernetes--container-orchestration)
6. [Backend API — Node.js / Express](#6-backend-api--nodejs--express)
7. [Frontend — React](#7-frontend--react)
8. [CI/CD Concepts](#8-cicd-concepts)
9. [Next Steps](#9-next-steps)

---

## 1. Overview & Architecture

```
User Browser
     │
     ▼
  Ingress (Nginx)
     │
     ├──► Frontend Service  ──► React Pods
     │
     └──► Backend Service   ──► Node.js Pods
                                    │
                                    ▼
                               PostgreSQL (RDS)
```

The application is split into:
- **Frontend**: A React SPA served by Nginx.
- **Backend**: A RESTful Node.js/Express API.
- **Database**: PostgreSQL.

All three are containerised with Docker and orchestrated with Kubernetes. The underlying cloud infrastructure (VPC, subnets, load balancers, database, Kubernetes cluster) is provisioned with Terraform and configured with Ansible.

---

## 2. Terraform — Infrastructure as Code

### What is Terraform?

Terraform lets you define cloud infrastructure in declarative HCL (HashiCorp Configuration Language) files. Instead of clicking through the AWS console, you write code that Terraform converts into API calls.

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Provider** | Plugin that talks to a cloud API (e.g., `hashicorp/aws`) |
| **Resource** | A piece of infrastructure (e.g., `aws_vpc`, `aws_instance`) |
| **Variable** | Parameterise your configs to avoid hard-coding values |
| **Output** | Expose values from resources for use elsewhere |
| **State** | Terraform tracks what it has created in a state file |

### Walkthrough

```hcl
# terraform/provider.tf
terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
}
```

- `required_providers` pins the version so upgrades don't break your config.
- `default_tags` ensures every AWS resource gets the same metadata tags.

```hcl
# terraform/main.tf (excerpt)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}
```

- A **VPC** is your private network in AWS.
- Public subnets have a route to the internet gateway.
- Private subnets use NAT gateways so containers can reach the internet without being publicly reachable.

### Try It

```bash
cd terraform
terraform init          # Download providers
terraform validate      # Check syntax
terraform plan          # Preview changes (safe — no changes made)
```

---

## 3. Ansible — Configuration Management

### What is Ansible?

Once Terraform provisions servers, Ansible configures them. It connects over SSH and runs tasks defined in YAML **playbooks**.

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Inventory** | List of servers to manage |
| **Playbook** | Ordered list of plays (tasks to run on hosts) |
| **Role** | Reusable collection of tasks, handlers, and templates |
| **Handler** | Task that runs only when notified (e.g., restart Nginx) |
| **Template** | Jinja2 file rendered with variables at deploy time |

### Walkthrough

```yaml
# ansible/playbooks/setup.yml (excerpt)
- name: Install Docker
  ansible.builtin.shell: |
    curl -fsSL https://get.docker.com | sh
  args:
    creates: /usr/bin/docker   # Idempotent: skip if already installed
```

- **Idempotency** is a core principle: running the same playbook twice produces the same result.
- `creates:` makes a task a no-op if the file already exists.

```yaml
# ansible/roles/webserver/tasks/main.yml
- name: Deploy Nginx configuration
  ansible.builtin.template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: Reload nginx    # triggers the handler
```

### Try It

```bash
cd ansible
# Test connectivity (ping all servers)
ansible all -i inventory/hosts -m ping

# Dry run a playbook
ansible-playbook -i inventory/hosts playbooks/setup.yml --check
```

---

## 4. Docker — Containerisation

### What is Docker?

Docker packages your application and all its dependencies into a portable **image**. A running image is a **container**.

### Multi-Stage Builds

Both Dockerfiles use multi-stage builds to keep production images small:

```dockerfile
# backend/Dockerfile
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production   # Install only production deps

FROM base AS final
COPY src/ ./src/
EXPOSE 3000
USER node                      # Run as non-root for security
CMD ["node", "src/index.js"]
```

```dockerfile
# frontend/Dockerfile
FROM node:20-alpine AS build
RUN npm ci && npm run build    # Compile React → static files

FROM nginx:1.25-alpine AS final
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
```

The `build` stage is discarded; only the compiled output is copied into the final Nginx image.

### Docker Compose

`docker-compose.yml` links all three services together for local development:

```yaml
services:
  backend:
    build: ./backend
    depends_on:
      postgres:
        condition: service_healthy  # Wait until DB is ready
  frontend:
    build: ./frontend
    depends_on:
      - backend
  postgres:
    image: postgres:15-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U admin"]
```

### Try It

```bash
docker compose up -d --build   # Build images & start containers
docker compose logs -f backend # Stream backend logs
docker compose down            # Stop and remove containers
```

---

## 5. Kubernetes — Container Orchestration

### What is Kubernetes?

Kubernetes (K8s) automatically schedules containers across a cluster of machines, handles failures, scales workloads, and manages networking.

### Key Concepts

| Object | Description |
|--------|-------------|
| **Pod** | Smallest deployable unit — one or more containers |
| **Deployment** | Manages a set of identical Pods; handles rolling updates |
| **Service** | Stable network endpoint in front of Pods |
| **Ingress** | HTTP routing rules — maps URLs to Services |
| **Namespace** | Logical isolation within a cluster |

### Walkthrough

```yaml
# kubernetes/deployments/backend-deployment.yaml (excerpt)
spec:
  replicas: 2                      # Run 2 copies for availability
  strategy:
    type: RollingUpdate            # Update one pod at a time
  template:
    spec:
      containers:
        - name: backend
          resources:
            requests:
              cpu: 100m            # 0.1 CPU cores
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
          livenessProbe:
            httpGet:
              path: /health        # Restart pod if this fails
              port: 3000
```

- **Requests** = guaranteed resources; **Limits** = maximum allowed.
- **Liveness probe** restarts unhealthy pods automatically.
- **Readiness probe** stops traffic to pods that aren't ready yet.

```yaml
# kubernetes/ingress/ingress.yaml
rules:
  - host: app.example.com
    http:
      paths:
        - path: /api    → backend-service:3000
        - path: /       → frontend-service:80
```

### Try It

```bash
# Apply all manifests
kubectl apply -f kubernetes/

# Check everything is running
kubectl get all -n cloud-infra

# View pod logs
kubectl logs -l app=backend -n cloud-infra

# Scale a deployment
kubectl scale deployment/backend --replicas=3 -n cloud-infra
```

---

## 6. Backend API — Node.js / Express

### Structure

```
backend/
├── src/
│   ├── index.js   # HTTP server — listens on $PORT
│   └── app.js     # Express app — middleware & routes
├── Dockerfile
├── package.json
└── .env.example
```

### Key Middleware

```js
app.use(helmet());   // Sets secure HTTP headers
app.use(cors());     // Allows cross-origin requests from the frontend
app.use(morgan());   // Logs every HTTP request
```

### Try It

```bash
cd backend
npm install
cp .env.example .env
npm run dev

# Test endpoints
curl http://localhost:3000/health
curl http://localhost:3000/api/items
curl -X POST http://localhost:3000/api/items \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","description":"Hello!"}'
```

---

## 7. Frontend — React

### Structure

```
frontend/
├── src/
│   ├── App.js      # Main component — fetches & displays items
│   ├── App.css     # Component styles
│   ├── index.js    # React DOM entry point
│   └── index.css   # Global styles
├── public/index.html
├── Dockerfile
├── nginx.conf
└── package.json
```

### Key Patterns

- **`useState`** manages local component state (items list, form inputs, loading).
- **`useEffect`** fetches data from the API when the component mounts.
- The `proxy` field in `package.json` forwards `/api` calls to the backend during development.

### Try It

```bash
cd frontend
npm install
npm start    # Opens http://localhost:3001
```

---

## 8. CI/CD Concepts

A typical CI/CD pipeline for this project would look like:

```
Push to GitHub
      │
      ▼
  GitHub Actions / Jenkins / GitLab CI
      │
      ├── Lint & Test (npm test, terraform validate)
      ├── Build Docker images
      ├── Push images to registry (ECR, Docker Hub)
      └── Deploy to Kubernetes (kubectl / Helm)
```

The `scripts/deploy.sh` script automates the build → push → deploy flow. In production, this script would be called by a CI/CD system on every merge to `main`.

---

## 9. Next Steps

Once you're comfortable with this project, explore:

- 🔒 **Secrets management** — AWS Secrets Manager, HashiCorp Vault, or Kubernetes Secrets
- 📊 **Observability** — Prometheus + Grafana for metrics, Loki for logs, Jaeger for tracing
- 🔄 **GitOps** — ArgoCD or Flux to automatically sync Kubernetes from Git
- 🌐 **Service mesh** — Istio or Linkerd for mTLS and traffic management
- ♻️ **Helm** — Package Kubernetes manifests as reusable charts
- 🚀 **Horizontal Pod Autoscaler** — Scale pods based on CPU/memory metrics

---

Happy building! ☁️
