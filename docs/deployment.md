# Deployment Guide

This guide covers deploying the Cloud Infrastructure project to production environments.

## Deployment Methods

| Method         | Use Case                          | Tool         |
|----------------|-----------------------------------|--------------|
| Docker Compose | Local dev / single-host staging   | `docker compose` |
| Kubernetes     | Production / multi-node           | `kubectl`    |
| Ansible        | Bare-metal / VM server config     | `ansible-playbook` |

---

## Docker Compose Deployment

### Start

```bash
docker compose up -d --build
```

### Update (rolling)

```bash
docker compose pull
docker compose up -d --no-deps --build backend frontend
```

### Stop

```bash
docker compose down
```

### Remove everything (including volumes)

```bash
TARGET=compose PRUNE_VOLUMES=true bash scripts/cleanup.sh
```

---

## Kubernetes Deployment

### Prerequisites

- EKS cluster provisioned (see [Getting Started](getting-started.md))
- `kubectl` configured for the cluster
- Container images pushed to a registry

### Step 1 – Create Kubernetes Secret

```bash
kubectl create secret generic app-secrets \
  --namespace cloud-infra \
  --from-literal=db-password='YOUR_DB_PASSWORD' \
  --from-literal=secret-key='YOUR_SECRET_KEY'
```

### Step 2 – Update Image References

Edit the deployment manifests to point to your registry:

```yaml
# kubernetes/deployments/backend-deployment.yaml
image: your-registry.example.com/cloud-infra/backend:v1.0.0
```

### Step 3 – Apply Manifests

```bash
kubectl apply -f kubernetes/namespaces/
kubectl apply -f kubernetes/configmaps/
kubectl apply -f kubernetes/deployments/
kubectl apply -f kubernetes/services/
kubectl apply -f kubernetes/ingress/
```

Or use the deploy script:

```bash
DEPLOY_TARGET=kubernetes IMAGE_TAG=v1.0.0 bash scripts/deploy.sh
```

### Step 4 – Verify

```bash
kubectl get pods -n cloud-infra
kubectl get services -n cloud-infra
kubectl get ingress -n cloud-infra
```

### Rolling Update

```bash
kubectl set image deployment/backend backend=your-registry/backend:v1.1.0 -n cloud-infra
kubectl rollout status deployment/backend -n cloud-infra
```

### Rollback

```bash
kubectl rollout undo deployment/backend -n cloud-infra
```

---

## CI/CD Pipeline (Recommended)

Recommended pipeline stages:

```
1. Test         → Run unit/integration tests
2. Build        → docker build + tag
3. Push         → docker push to registry
4. Deploy Dev   → kubectl apply (dev environment)
5. Smoke Test   → curl health endpoints
6. Deploy Prod  → kubectl apply (prod, manual approval gate)
```

Example GitHub Actions trigger:

```yaml
on:
  push:
    branches: [main]
```

---

## Health Checks

| Endpoint                  | Expected Response                    |
|---------------------------|--------------------------------------|
| `GET /health`             | `{"status": "healthy"}`              |
| `GET /ready`              | `{"status": "ready"}`                |
| `GET /api/v1/info`        | App metadata JSON                    |

---

## Monitoring

Recommended tooling:
- **Prometheus + Grafana** — metrics and dashboards
- **Loki** — log aggregation
- **Alertmanager** — alert routing

Install with the Prometheus community Helm chart:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
```
