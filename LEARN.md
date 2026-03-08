# 📚 LEARN.md – Cloud Infrastructure Learning Guide

This guide walks you through every technology used in this project, explains **why** each tool exists, and shows you how to explore and extend the code step-by-step.

---

## Table of Contents

1. [Project Philosophy](#1-project-philosophy)
2. [Infrastructure as Code with Terraform](#2-infrastructure-as-code-with-terraform)
3. [Configuration Management with Ansible](#3-configuration-management-with-ansible)
4. [Container Orchestration with Kubernetes](#4-container-orchestration-with-kubernetes)
5. [Building a REST API with Node.js & Express](#5-building-a-rest-api-with-nodejs--express)
6. [Building a React Frontend](#6-building-a-react-frontend)
7. [Dockerising Applications](#7-dockerising-applications)
8. [Local Development with Docker Compose](#8-local-development-with-docker-compose)
9. [CI/CD Concepts](#9-cicd-concepts)
10. [Networking Fundamentals](#10-networking-fundamentals)
11. [Security Best Practices](#11-security-best-practices)
12. [Exercises & Next Steps](#12-exercises--next-steps)

---

## 1. Project Philosophy

Cloud infrastructure is the foundation that all modern applications run on. This project demonstrates a **complete, layered** approach:

```
Code (React + Node.js)
  └─ Containers (Docker)
       └─ Orchestration (Kubernetes)
            └─ Cloud Resources (Terraform → AWS)
                 └─ Configuration (Ansible)
```

Each layer is independently useful, and together they form a production-grade deployment pipeline.

---

## 2. Infrastructure as Code with Terraform

### What is Terraform?

Terraform lets you describe cloud infrastructure in **declarative HCL files** and version-control it like application code. Instead of clicking through the AWS console, you write:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
```

Run `terraform apply` and Terraform figures out what to create/update/delete.

### Core concepts

| Concept | Description |
|---------|-------------|
| **Provider** | Plugin for a cloud platform (AWS, GCP, Azure) |
| **Resource** | A piece of infrastructure (VPC, EC2, RDS) |
| **Variable** | Input parameter for reusable configs |
| **Output** | Value exported after apply (e.g. DNS name) |
| **State** | Terraform's record of what it created |
| **Module** | Reusable group of resources |

### Files in this project

```
terraform/
├── providers.tf   # AWS provider + Terraform version constraints
├── variables.tf   # All configurable inputs
├── main.tf        # VPC, subnets, ALB, RDS, EKS resources
└── outputs.tf     # Values printed after apply
```

### How to read `main.tf`

The file is organised into logical sections with comments:

1. **VPC** – the private network for all resources
2. **Subnets** – public (internet-facing) and private (internal only)
3. **NAT Gateway** – lets private resources reach the internet
4. **Security Groups** – firewall rules per service
5. **ALB** – load balancer that distributes traffic to pods
6. **RDS** – managed PostgreSQL database
7. **EKS** – Kubernetes cluster with managed node groups

### Try it yourself

```bash
cd terraform
terraform init          # download providers
terraform validate      # check HCL syntax
terraform fmt           # format files
terraform plan \
  -var="db_password=test1234" \
  -var="environment=dev"
# No changes are applied at the plan stage.
```

---

## 3. Configuration Management with Ansible

### What is Ansible?

Ansible automates the configuration of servers – installing packages, editing files, managing services – using **YAML playbooks** that describe the desired state.

### Core concepts

| Concept | Description |
|---------|-------------|
| **Inventory** | List of target hosts (`hosts.yml`) |
| **Playbook** | Ordered list of plays to run |
| **Role** | Reusable collection of tasks, handlers, templates |
| **Task** | A single action (install package, copy file) |
| **Handler** | Task triggered only when notified (e.g. restart nginx) |
| **Template** | Jinja2 file rendered with variables |

### Files in this project

```
ansible/
├── inventory/hosts.yml          # Server addresses
├── playbooks/site.yml           # Master playbook
└── roles/
    ├── common/                  # Timezone, packages, journald
    ├── webserver/               # Nginx + firewall
    │   └── templates/nginx.conf.j2
    └── database/                # PostgreSQL + pg_hba
```

### Reading a playbook

```yaml
- name: Configure web servers
  hosts: webservers       # target group from inventory
  become: true            # run as root (sudo)
  roles:
    - webserver           # apply the webserver role
```

### Key Ansible modules used

| Module | Purpose |
|--------|---------|
| `apt` | Install packages on Debian/Ubuntu |
| `service` | Start/stop/enable systemd services |
| `template` | Render Jinja2 templates to files |
| `ufw` | Manage UFW firewall rules |
| `postgresql_db` | Create a PostgreSQL database |
| `postgresql_user` | Create a PostgreSQL user |

---

## 4. Container Orchestration with Kubernetes

### What is Kubernetes?

Kubernetes (K8s) **automatically manages containerised workloads**: scheduling pods, restarting failed containers, scaling up/down, and routing traffic.

### Core concepts

| Object | Description |
|--------|-------------|
| **Namespace** | Virtual cluster for isolation |
| **Pod** | Smallest deployable unit (1+ containers) |
| **Deployment** | Manages pod replicas + rolling updates |
| **Service** | Stable network endpoint for pods |
| **Ingress** | HTTP routing rules from outside the cluster |
| **ConfigMap** | Non-secret configuration data |
| **Secret** | Sensitive configuration (base64 encoded) |

### Files in this project

```
kubernetes/
├── namespace.yaml     # cloud-infra namespace
├── configmap.yaml     # Non-secret env vars for backend
├── deployment.yaml    # backend + frontend Deployments
├── service.yaml       # ClusterIP Services
└── ingress.yaml       # Nginx Ingress rules
```

### Understanding a Deployment

```yaml
spec:
  replicas: 2                    # run 2 copies
  strategy:
    type: RollingUpdate          # update one pod at a time
  template:
    spec:
      containers:
        - name: backend
          resources:
            requests:            # minimum guaranteed
              cpu: "100m"        # 0.1 CPU core
              memory: "128Mi"
            limits:              # maximum allowed
              cpu: "500m"
              memory: "512Mi"
          livenessProbe:         # restart if this fails
            httpGet:
              path: /health
              port: 3000
          readinessProbe:        # remove from service if this fails
            httpGet:
              path: /health
              port: 3000
```

### Useful kubectl commands

```bash
kubectl get pods -n cloud-infra
kubectl describe pod <pod-name> -n cloud-infra
kubectl logs <pod-name> -n cloud-infra
kubectl exec -it <pod-name> -n cloud-infra -- sh
kubectl get events -n cloud-infra --sort-by='.lastTimestamp'
```

---

## 5. Building a REST API with Node.js & Express

### Architecture

```
backend/
├── src/
│   ├── index.js          # App entry point
│   └── index.test.js     # Jest tests
├── package.json
├── Dockerfile
└── .env.example
```

### Key middleware chain

Every incoming request flows through:

```
Request
  → helmet()          # sets security headers
  → cors()            # handles cross-origin requests
  → morgan()          # logs request details
  → express.json()    # parses JSON body
  → rateLimit()       # throttles /api/* to 100 req/15 min
  → route handler
  → error handler
```

### REST conventions followed

| Pattern | Example |
|---------|---------|
| Plural nouns for resources | `/api/items` |
| HTTP verbs for actions | `GET` list, `POST` create |
| Status codes | `200` OK, `201` Created, `400` Bad Request, `404` Not Found |
| JSON responses | `{ "data": ... }` or `{ "error": "..." }` |

### Adding a new endpoint

1. Open `backend/src/index.js`
2. Add a route after the existing ones:

```js
app.delete('/api/items/:id', (req, res) => {
  const id = parseInt(req.params.id, 10);
  const idx = items.findIndex((i) => i.id === id);
  if (idx === -1) return res.status(404).json({ error: 'Item not found' });
  items.splice(idx, 1);
  return res.status(204).send();
});
```

3. Add a test in `index.test.js`
4. Run `npm test` to verify

---

## 6. Building a React Frontend

### Architecture

```
frontend/src/
├── main.jsx              # ReactDOM.createRoot
├── App.jsx               # Root component, state, data fetching
├── index.css             # CSS custom properties (design tokens)
└── components/
    ├── ItemList.jsx       # Renders the list of items
    ├── AddItemForm.jsx    # Controlled form with validation
    └── StatusBadge.jsx    # API health indicator
```

### Data flow

```
App (state owner)
  ├─ fetches /health → health state → StatusBadge
  ├─ fetches /api/items → items state → ItemList
  └─ AddItemForm → onAdd callback → POST /api/items → refetch
```

### React patterns used

| Pattern | Where |
|---------|-------|
| `useState` | Local component state |
| `useEffect` | Side effects (fetch on mount, poll health) |
| `useCallback` | Stable function refs for effect deps |
| Lifting state up | `App` owns all data, passes down via props |
| Controlled inputs | `AddItemForm` inputs tied to state |

### Adding a new component

Create `frontend/src/components/MyComponent.jsx`:

```jsx
export default function MyComponent({ value }) {
  return <div style={{ padding: '1rem' }}>{value}</div>;
}
```

Import and use in `App.jsx`:

```jsx
import MyComponent from './components/MyComponent.jsx';
// ...
<MyComponent value="Hello!" />
```

---

## 7. Dockerising Applications

### Why Docker?

Docker packages an application with **all its dependencies** into a portable image that runs identically everywhere.

### Multi-stage builds (used in this project)

```dockerfile
# Stage 1: install dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Stage 2: lean production image
FROM node:20-alpine AS production
COPY --from=deps /app/node_modules ./node_modules
COPY src ./src
USER appuser          # never run as root
EXPOSE 3000
CMD ["node", "src/index.js"]
```

The final image only contains the runtime (no build tools), keeping it small and secure.

### Useful Docker commands

```bash
# Build backend image
docker build -t cloud-infra-backend ./backend

# Run it locally
docker run -p 3000:3000 --env-file backend/.env cloud-infra-backend

# Inspect image layers
docker history cloud-infra-backend

# Scan for vulnerabilities
docker scout cves cloud-infra-backend
```

---

## 8. Local Development with Docker Compose

Docker Compose orchestrates multiple containers on a single machine, mimicking the production topology:

```yaml
services:
  db:        # PostgreSQL
  backend:   # Node.js API (depends on db)
  frontend:  # Nginx serving React build (depends on backend)
```

### Useful compose commands

```bash
docker compose up --build      # build + start all services
docker compose logs -f backend # tail backend logs
docker compose exec db psql -U appuser -d appdb  # DB shell
docker compose restart backend # restart one service
docker compose down -v         # stop + remove volumes
```

---

## 9. CI/CD Concepts

A typical CI/CD pipeline for this project would:

1. **CI (Continuous Integration)**
   - On every push: lint, unit tests (`npm test`), build Docker images
   - Tools: GitHub Actions, GitLab CI

2. **CD (Continuous Delivery)**
   - On merge to `main`: push images to registry, run `scripts/deploy.sh`
   - Rolling update in Kubernetes with zero downtime

### Sample GitHub Actions workflow idea

```yaml
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: cd backend && npm ci && npm test
  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - run: bash scripts/deploy.sh --env prod
```

---

## 10. Networking Fundamentals

### VPC Layout

```
10.0.0.0/16  (VPC)
├── 10.0.1.0/24   Public subnet AZ-1  (ALB, NAT GW)
├── 10.0.2.0/24   Public subnet AZ-2  (ALB)
├── 10.0.10.0/24  Private subnet AZ-1 (EKS nodes, RDS)
└── 10.0.11.0/24  Private subnet AZ-2 (EKS nodes, RDS)
```

### Traffic flow

```
Internet → IGW → ALB (public subnets)
                  ↓
             EKS nodes (private subnets) via target group
                  ↓
             RDS PostgreSQL (private subnets)
```

Private resources have no public IPs. They reach the internet via **NAT Gateways** placed in the public subnets.

### Security Group rules

| SG | Inbound | From |
|----|---------|------|
| `alb-sg` | 80, 443 | 0.0.0.0/0 |
| `web-sg` | 3000 | `alb-sg` only |
| `rds-sg` | 5432 | `web-sg` only |

---

## 11. Security Best Practices

This project follows several security best practices:

| Area | Practice |
|------|---------|
| Containers | Non-root user, minimal base image (`alpine`) |
| API | Helmet (security headers), rate limiting, CORS |
| Secrets | Never in code – use `.env`, K8s Secrets, or AWS Secrets Manager |
| DB | Not publicly accessible, encrypted at rest |
| Network | Private subnets, least-privilege security groups |
| Terraform | `sensitive = true` on secret variables |
| Ansible | Passwords via Ansible Vault in production |

### What to do next for production

- Enable HTTPS on the ALB with an ACM certificate
- Use AWS Secrets Manager for `DATABASE_URL`
- Enable CloudTrail, GuardDuty, and Security Hub
- Set up VPC Flow Logs
- Scan images with `docker scout` or Trivy in CI

---

## 12. Exercises & Next Steps

### Beginner

- [ ] Add a `DELETE /api/items/:id` endpoint and a button in the UI to remove items
- [ ] Add an `updatedAt` field to items
- [ ] Change the frontend colour scheme using the CSS custom properties in `index.css`

### Intermediate

- [ ] Connect the backend to the PostgreSQL database (use the `pg` package already in `package.json`)
- [ ] Add input validation with a library like `zod` or `joi`
- [ ] Write a Terraform module for a reusable VPC
- [ ] Add a GitHub Actions CI workflow that runs `npm test` on every push

### Advanced

- [ ] Add HTTPS using AWS ACM + ALB listener on port 443
- [ ] Implement Horizontal Pod Autoscaler in Kubernetes
- [ ] Set up Prometheus + Grafana monitoring in the K8s cluster
- [ ] Add Ansible Vault to encrypt database passwords
- [ ] Implement a blue/green deployment strategy

---

*Happy building! Open an issue or PR if you find something to improve.*
