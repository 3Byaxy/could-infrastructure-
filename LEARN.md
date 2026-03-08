# 📚 LEARN.md — Full-Stack Cloud Infrastructure Guide

This guide explains every concept used in this project, from containers to Kubernetes, so you understand *why* things are done the way they are — not just *how*.

---

## Table of Contents

1. [What Is Cloud Infrastructure?](#1-what-is-cloud-infrastructure)
2. [The Full-Stack Architecture](#2-the-full-stack-architecture)
3. [The Backend: Python Flask REST API](#3-the-backend-python-flask-rest-api)
4. [The Frontend: React](#4-the-frontend-react)
5. [Containerisation with Docker](#5-containerisation-with-docker)
6. [Multi-Service Orchestration with Docker Compose](#6-multi-service-orchestration-with-docker-compose)
7. [Kubernetes: Production-Grade Orchestration](#7-kubernetes-production-grade-orchestration)
8. [Networking and Service Discovery](#8-networking-and-service-discovery)
9. [Health Checks and Probes](#9-health-checks-and-probes)
10. [Resource Management](#10-resource-management)
11. [Real-World Deployment Checklist](#11-real-world-deployment-checklist)
12. [Further Learning](#12-further-learning)

---

## 1. What Is Cloud Infrastructure?

Cloud infrastructure is the collection of hardware and software resources — compute, networking, storage — that applications run on. Instead of managing physical servers, you rent virtual resources from providers like AWS, Google Cloud, or Azure.

**Key ideas:**
- **Compute**: Virtual Machines (VMs) or containers that run your code
- **Networking**: Load balancers, DNS, firewalls that control traffic
- **Storage**: Databases, object stores (S3/GCS), file systems
- **Orchestration**: Tools like Kubernetes that automate deploying and scaling containers

---

## 2. The Full-Stack Architecture

This project demonstrates the most common web application pattern:

```
User's Browser
      │  HTTP
      ▼
  Nginx (frontend container)
      │ serves static React files
      │ proxies /api/* →
      ▼
  Flask (backend container)
      │ business logic
      │ (in production: talks to a database)
```

### Why separate frontend and backend?

| Concern | Frontend | Backend |
|---------|----------|---------|
| **Language** | JavaScript (React) | Python (Flask) |
| **Purpose** | User interface | Business logic & data |
| **Scaling** | Scale independently | Scale independently |
| **Caching** | Static files cached by CDN | Dynamic data |

Separating them allows teams to work independently, scale each tier differently, and swap one without touching the other.

---

## 3. The Backend: Python Flask REST API

### REST API Design

REST (Representational State Transfer) maps HTTP verbs to CRUD operations:

| HTTP Verb | CRUD Operation | Example               |
|-----------|----------------|-----------------------|
| GET       | Read           | `GET /api/items`      |
| POST      | Create         | `POST /api/items`     |
| PUT/PATCH | Update         | `PUT /api/items/:id`  |
| DELETE    | Delete         | `DELETE /api/items/:id` |

### Why Flask?

Flask is a lightweight Python web framework — minimal, flexible, and easy to learn. For production workloads, Flask runs behind **Gunicorn** (a WSGI server) which:
- Handles multiple concurrent requests
- Manages worker processes
- Provides proper HTTP handling

### CORS

Since the browser serves the frontend from one origin and the API may be on a different one, we need **Cross-Origin Resource Sharing** headers. `flask-cors` adds these automatically.

```python
from flask_cors import CORS
CORS(app)  # Allow all origins (restrict in production!)
```

In production, restrict this to your frontend's domain:
```python
CORS(app, origins=["https://your-domain.com"])
```

---

## 4. The Frontend: React

### What is React?

React is a JavaScript library for building user interfaces using **components** — reusable, self-contained pieces of UI. Each component manages its own state and re-renders when data changes.

### Key Concepts in This Project

**Hooks** — Functions that let you use React state and lifecycle in function components:
- `useState` — stores component-local data
- `useEffect` — runs side-effects (like fetching data) after render
- `useCallback` — memoises functions to avoid unnecessary re-renders

**Fetch API** — The browser's built-in way to make HTTP requests:
```js
const res = await fetch('/api/items');
const data = await res.json();
```

### The Build Process

React's source code (JSX, modern JS) can't run directly in browsers. `react-scripts build` compiles it into optimised static files (HTML, CSS, JS) that any browser understands.

```
src/ (JSX, ES2020+)
      │ npm run build
      ▼
build/ (plain HTML, CSS, JS — production-ready)
```

---

## 5. Containerisation with Docker

### Why Containers?

A container packages your application **and** all its dependencies (runtime, libraries, config) into a portable unit. It runs identically on a developer laptop, a CI pipeline, or a cloud server.

### Dockerfile Best Practices (Backend)

```dockerfile
FROM python:3.12-slim          # ① Use a specific, slim base image
WORKDIR /app
COPY requirements.txt .        # ② Copy only what's needed for dependencies first
RUN pip install -r requirements.txt  # ③ This layer is cached unless requirements change
COPY app.py .                  # ④ Copy source code last (changes most often)
CMD ["gunicorn", ...]          # ⑤ Use a production server, not flask's dev server
```

**Why copy requirements.txt before the source code?** Docker builds images in layers. If you copy source code first, every code change invalidates the dependency installation layer — making builds slow. Copying `requirements.txt` first means dependencies are re-installed only when they actually change.

### Multi-Stage Build (Frontend)

```dockerfile
# Stage 1: Build the React app (needs Node.js)
FROM node:20-alpine AS builder
COPY package.json .
RUN npm install
COPY src/ src/
COPY public/ public/
RUN npm run build

# Stage 2: Serve with Nginx (tiny image, no Node.js)
FROM nginx:1.27-alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
```

The final image only contains Nginx and the compiled static files — **no Node.js, no source code, no dev dependencies**. This keeps the image small and the attack surface minimal.

---

## 6. Multi-Service Orchestration with Docker Compose

Docker Compose lets you define and run multiple containers as a single application.

```yaml
services:
  backend:
    build: ./backend      # Build the image from ./backend/Dockerfile
    ports:
      - "5000:5000"       # host:container port mapping
    networks:
      - cloud-net         # Shared network so services can reach each other

  frontend:
    build: ./frontend
    ports:
      - "3000:80"
    depends_on:
      backend:
        condition: service_healthy   # Wait until backend is healthy
    networks:
      - cloud-net

networks:
  cloud-net:              # All services on this network can resolve each other by name
```

### Service Discovery in Docker Compose

When containers are on the same Docker network, they can reach each other using **the service name as a hostname**. That's why Nginx proxies to `http://backend:5000` — Docker's internal DNS resolves `backend` to the backend container's IP.

---

## 7. Kubernetes: Production-Grade Orchestration

Kubernetes (K8s) automates deploying, scaling, and managing containerised applications across a cluster of machines.

### Core Objects

#### Deployment
A Deployment describes the *desired state* of your application: which container to run, how many copies (replicas), and how to update them.

```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  replicas: 2          # Run 2 instances for high availability
  template:
    spec:
      containers:
        - name: backend
          image: cloud-backend:latest
          resources:
            requests:
              cpu: "100m"    # 0.1 CPU cores guaranteed
            limits:
              cpu: "500m"    # Never use more than 0.5 cores
```

#### Service
A Service provides a stable network endpoint to a set of Pods (container instances). Pods can come and go, but the Service IP/DNS stays constant.

```yaml
kind: Service
spec:
  selector:
    app: backend       # Routes to all pods with label app=backend
  ports:
    - port: 5000       # Service port (used by other services to connect)
      targetPort: 5000 # Pod port
  type: ClusterIP      # Only reachable inside the cluster
```

#### Ingress
An Ingress routes external HTTP traffic to internal Services based on URL paths or hostnames.

```yaml
kind: Ingress
spec:
  rules:
    - host: cloud.example.com
      http:
        paths:
          - path: /api    # → backend service
          - path: /       # → frontend service
```

### Why Use Kubernetes Over Docker Compose?

| Feature | Docker Compose | Kubernetes |
|---------|---------------|------------|
| **Auto-restart** | Basic | Advanced (self-healing) |
| **Scaling** | Manual | Auto-scaling |
| **Load balancing** | No | Built-in |
| **Rolling updates** | No | Zero-downtime |
| **Multi-node** | No | Yes |
| **Production use** | Development | Production |

---

## 8. Networking and Service Discovery

### Docker (Compose)
- All services on `cloud-net` communicate by **service name**
- Ports published with `ports:` are accessible from the host machine

### Kubernetes
- **ClusterIP** Services are reachable inside the cluster via `<service-name>.<namespace>.svc.cluster.local`
- **Ingress** exposes services externally on HTTP/HTTPS
- **NodePort** exposes a service on each node's IP at a static port (useful for testing)

### Why Does Nginx Proxy /api Requests?

The browser sends all requests to the frontend's URL. Nginx handles this by:
1. Serving static React files for all other paths
2. Forwarding `/api/` paths to the Flask backend

This means the browser never needs to know the backend's address — **no CORS issues in production**.

---

## 9. Health Checks and Probes

Health checks tell orchestrators whether a container is ready to serve traffic.

### Docker Compose Healthcheck
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:5000/api/health"]
  interval: 30s
  timeout: 5s
  retries: 3
```

### Kubernetes Probes

```yaml
livenessProbe:    # Is the container alive? If not, restart it.
  httpGet:
    path: /api/health
    port: 5000
  initialDelaySeconds: 10
  periodSeconds: 20

readinessProbe:   # Is the container ready to receive traffic?
  httpGet:
    path: /api/health
    port: 5000
  initialDelaySeconds: 5
  periodSeconds: 10
```

**Liveness vs Readiness:**
- **Liveness**: "Is the app crashed?" → restart the pod
- **Readiness**: "Is the app ready to serve?" → remove from load balancer rotation until ready

---

## 10. Resource Management

Always set resource requests and limits to prevent one service from starving others.

```yaml
resources:
  requests:          # Guaranteed resources (used for scheduling)
    cpu: "100m"      # 100 millicores = 0.1 CPU
    memory: "128Mi"  # 128 mebibytes
  limits:            # Hard ceiling (pod is killed/throttled if exceeded)
    cpu: "500m"
    memory: "256Mi"
```

Without limits, a misbehaving pod can consume all cluster resources and starve other services.

---

## 11. Real-World Deployment Checklist

When moving from this template to production:

- [ ] **Replace in-memory store** with a real database (PostgreSQL, MongoDB, etc.)
- [ ] **Add authentication** (JWT, OAuth2, API keys)
- [ ] **Use environment-specific config** (K8s ConfigMaps, Secrets)
- [ ] **Enable HTTPS** (cert-manager + Let's Encrypt on K8s)
- [ ] **Restrict CORS** to your frontend domain
- [ ] **Set up CI/CD** (GitHub Actions, GitLab CI) to build and push images automatically
- [ ] **Add monitoring** (Prometheus + Grafana, or a managed solution)
- [ ] **Add logging** (structured JSON logs, shipped to a log aggregator)
- [ ] **Set up HorizontalPodAutoscaler** to scale pods based on CPU/memory
- [ ] **Use image tags** instead of `latest` (e.g. `v1.2.3` or a commit SHA)
- [ ] **Implement database migrations** for schema changes

---

## 12. Further Learning

| Topic | Resource |
|-------|----------|
| Docker | [docs.docker.com](https://docs.docker.com) |
| Kubernetes | [kubernetes.io/docs](https://kubernetes.io/docs/home/) |
| Flask | [flask.palletsprojects.com](https://flask.palletsprojects.com) |
| React | [react.dev](https://react.dev) |
| Nginx | [nginx.org/en/docs](https://nginx.org/en/docs/) |
| Cloud Native patterns | [12factor.net](https://12factor.net) |
| Free K8s practice | [Play with Kubernetes](https://labs.play-with-k8s.com/) |

---

> Built with ❤️ as a learning resource. Start with `docker compose up --build` and explore from there!
