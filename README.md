# ☁️ Cloud Infrastructure Template

A **production-ready, full-stack cloud infrastructure template** featuring a Python Flask REST API backend, a React frontend, Docker Compose for local development, and Kubernetes manifests for cloud deployment.

> Perfect for learning modern DevOps and cloud engineering practices — or as a starting point for a real project.

---

## 📁 Project Structure

```
.
├── backend/                # Python Flask REST API
│   ├── app.py              # Application entry point & routes
│   ├── requirements.txt    # Python dependencies
│   ├── Dockerfile          # Container image (Gunicorn + Python 3.12)
│   └── .dockerignore
│
├── frontend/               # React web application
│   ├── src/
│   │   ├── App.js          # Main React component
│   │   ├── App.css         # Styles
│   │   └── index.js        # React DOM entry point
│   ├── public/
│   │   └── index.html      # HTML template
│   ├── nginx.conf          # Nginx config (serves SPA + proxies /api)
│   ├── package.json        # Node dependencies & scripts
│   ├── Dockerfile          # Multi-stage build (Node → Nginx)
│   └── .dockerignore
│
├── k8s/                    # Kubernetes manifests
│   ├── backend-deployment.yaml
│   ├── backend-service.yaml
│   ├── frontend-deployment.yaml
│   ├── frontend-service.yaml
│   └── ingress.yaml
│
├── docker-compose.yml      # Local development orchestration
├── .gitignore
├── LEARN.md                # Deep-dive learning guide
└── README.md               # This file
```

---

## 🚀 Quick Start — Docker Compose (Recommended)

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/) ≥ 24
- [Docker Compose](https://docs.docker.com/compose/install/) ≥ 2

### 1. Clone the repository
```bash
git clone https://github.com/3Byaxy/could-infrastructure-.git
cd could-infrastructure-
```

### 2. Start all services
```bash
docker compose up --build
```

### 3. Open the app
| Service  | URL                          |
|----------|------------------------------|
| Frontend | http://localhost:3000        |
| Backend API | http://localhost:5000/api |

### 4. Stop the stack
```bash
docker compose down
```

---

## 🔌 Backend API Reference

Base URL: `http://localhost:5000/api`

| Method | Endpoint          | Description             |
|--------|-------------------|-------------------------|
| GET    | `/health`         | Health check            |
| GET    | `/items`          | List all items          |
| GET    | `/items/:id`      | Get a single item       |
| POST   | `/items`          | Create a new item       |
| DELETE | `/items/:id`      | Delete an item          |

### Example requests (curl)

```bash
# Health check
curl http://localhost:5000/api/health

# List items
curl http://localhost:5000/api/items

# Create an item
curl -X POST http://localhost:5000/api/items \
  -H "Content-Type: application/json" \
  -d '{"name": "Load Balancer", "description": "Distributes traffic"}'

# Delete an item
curl -X DELETE http://localhost:5000/api/items/<id>
```

---

## 🛠️ Local Development (Without Docker)

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py              # Runs on http://localhost:5000
```

### Frontend

```bash
cd frontend
npm install
npm start                  # Runs on http://localhost:3000
```

> The React dev server proxies `/api` calls to `http://backend:5000` (configured in `package.json`).  
> For local-only development update the proxy to `http://localhost:5000`.

---

## ☸️ Kubernetes Deployment

### Prerequisites
- A running Kubernetes cluster (local: [minikube](https://minikube.sigs.k8s.io/) or [kind](https://kind.sigs.k8s.io/), cloud: GKE / EKS / AKS)
- `kubectl` configured to point at your cluster
- Images pushed to a container registry

### 1. Build and push images

```bash
# Replace <registry> with your registry (e.g. docker.io/yourusername)
REGISTRY=<registry>

docker build -t $REGISTRY/cloud-backend:latest ./backend
docker build -t $REGISTRY/cloud-frontend:latest ./frontend

docker push $REGISTRY/cloud-backend:latest
docker push $REGISTRY/cloud-frontend:latest
```

### 2. Update image references in manifests

Edit `k8s/backend-deployment.yaml` and `k8s/frontend-deployment.yaml` to replace `cloud-backend:latest` / `cloud-frontend:latest` with your full registry path.

### 3. Apply manifests

```bash
kubectl apply -f k8s/
```

### 4. Check status

```bash
kubectl get pods
kubectl get services
kubectl get ingress
```

### 5. Access the app

If using **minikube**:
```bash
minikube addons enable ingress
minikube tunnel
```
Then add `127.0.0.1 cloud.example.com` to `/etc/hosts` and open http://cloud.example.com.

For cloud providers, the Ingress controller will assign a public IP automatically.

---

## 🏗️ Architecture Overview

```
Internet
    │
    ▼
┌─────────────────────────────────────────┐
│  Nginx Ingress / Docker Compose proxy   │
└───────────┬──────────────┬──────────────┘
            │              │
      GET / ...       GET /api/...
            │              │
    ┌───────▼──────┐  ┌────▼──────────┐
    │   Frontend   │  │    Backend    │
    │  React SPA   │  │  Flask API   │
    │  (Nginx)     │  │  (Gunicorn)  │
    └──────────────┘  └───────────────┘
```

The frontend Nginx container proxies all `/api/*` requests to the backend service, so the browser only ever talks to one host.

---

## 📦 Environment Variables

### Backend
| Variable    | Default      | Description         |
|-------------|--------------|---------------------|
| `FLASK_ENV` | `production` | Flask environment   |

### Frontend
| Variable             | Default | Description                        |
|----------------------|---------|------------------------------------|
| `REACT_APP_API_URL`  | `/api`  | Override backend URL for local dev |

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m "feat: add my feature"`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a Pull Request

---

## 📄 License

MIT — see [LICENSE](LICENSE) for details.

---

> 📚 Want to learn the concepts behind this stack? Read **[LEARN.md](LEARN.md)**.