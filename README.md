# Cloud Infrastructure

A cloud-ready project with a React frontend, Docker support, and beginner-friendly documentation.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Repository Structure](#repository-structure)
3. [Frontend Application](#frontend-application)
   - [Prerequisites](#prerequisites)
   - [Local Development](#local-development)
   - [Connecting to a Backend Service](#connecting-to-a-backend-service)
   - [Running Tests](#running-tests)
   - [Production Build](#production-build)
4. [Docker / Containerisation](#docker--containerisation)
   - [Build the Docker Image](#build-the-docker-image)
   - [Run the Container Locally](#run-the-container-locally)
   - [Passing a Backend URL at Build Time](#passing-a-backend-url-at-build-time)
5. [Cloud Deployment](#cloud-deployment)
   - [General Steps](#general-steps)
   - [AWS (ECS / Fargate)](#aws-ecs--fargate)
   - [Google Cloud Run](#google-cloud-run)
   - [Azure Container Instances](#azure-container-instances)
6. [Contributing](#contributing)

---

## Project Overview

This repository contains the infrastructure and application code needed to run a cloud-hosted web application.  The frontend is a [React](https://react.dev/) single-page application (SPA) that can be deployed as a Docker container to any container-hosting platform.

---

## Repository Structure

```
cloud-infrastructure-/
├── frontend/               # React frontend application
│   ├── public/
│   │   └── index.html      # HTML entry point
│   ├── src/
│   │   ├── index.js        # React DOM entry point
│   │   ├── index.css       # Global styles
│   │   ├── App.js          # Root application component
│   │   └── App.css         # Application styles
│   ├── Dockerfile          # Multi-stage Docker build
│   ├── nginx.conf          # nginx configuration for serving the SPA
│   └── package.json        # Node.js dependencies and scripts
└── README.md               # This file
```

---

## Frontend Application

### Prerequisites

| Tool | Version | Install guide |
|------|---------|---------------|
| Node.js | ≥ 18 | https://nodejs.org |
| npm | ≥ 9 (bundled with Node.js) | – |
| Docker | ≥ 24 (optional, for containerisation) | https://docs.docker.com/get-docker/ |

### Local Development

```bash
# 1. Move into the frontend directory
cd frontend

# 2. Install dependencies
npm install

# 3. Start the development server (hot-reload enabled)
npm start
```

The app will open automatically at **http://localhost:3000**.

### Connecting to a Backend Service

The frontend can communicate with any backend API.  Set the `REACT_APP_API_URL` environment variable before starting the dev server:

```bash
# Linux / macOS
REACT_APP_API_URL=http://localhost:5000 npm start

# Windows (PowerShell)
$env:REACT_APP_API_URL="http://localhost:5000"; npm start
```

The app will display the backend's `/health` endpoint response on the home page.  If no URL is configured the app runs in *standalone mode*.

### Running Tests

```bash
cd frontend
npm test
```

### Production Build

```bash
cd frontend
npm run build
```

A minified, optimised build is written to `frontend/build/`.  Serve it with any static file server or via the included Docker image.

---

## Docker / Containerisation

The `frontend/Dockerfile` uses a **two-stage build**:

1. **Build stage** – uses a Node.js image to install dependencies and run `npm run build`.
2. **Serve stage** – copies the static build into a lightweight **nginx** image.

This keeps the final image small (no Node.js runtime in production).

### Build the Docker Image

```bash
cd frontend
docker build -t cloud-infrastructure-frontend .
```

### Run the Container Locally

```bash
docker run -p 8080:80 cloud-infrastructure-frontend
```

Visit **http://localhost:8080** in your browser.

### Passing a Backend URL at Build Time

React environment variables are baked into the bundle at build time.  Pass the URL as a Docker build argument:

```bash
docker build \
  --build-arg REACT_APP_API_URL=https://api.example.com \
  -t cloud-infrastructure-frontend .
```

---

## Cloud Deployment

### General Steps

1. Build and tag the Docker image.
2. Push it to a container registry (Docker Hub, ECR, GCR, ACR, etc.).
3. Deploy the image to a container service on your cloud provider.
4. Expose port **80** (or map it to HTTPS via a load balancer / ingress).

### AWS (ECS / Fargate)

```bash
# Authenticate with ECR
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Tag and push
docker tag cloud-infrastructure-frontend \
  <account-id>.dkr.ecr.us-east-1.amazonaws.com/cloud-infrastructure-frontend:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/cloud-infrastructure-frontend:latest
```

Then create an ECS task definition pointing to the image and expose it via an Application Load Balancer.

### Google Cloud Run

```bash
# Tag for Google Artifact Registry
docker tag cloud-infrastructure-frontend \
  gcr.io/<project-id>/cloud-infrastructure-frontend:latest

# Push
docker push gcr.io/<project-id>/cloud-infrastructure-frontend:latest

# Deploy
gcloud run deploy cloud-infrastructure-frontend \
  --image gcr.io/<project-id>/cloud-infrastructure-frontend:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 80
```

### Azure Container Instances

```bash
# Push to Azure Container Registry
az acr login --name <registry-name>
docker tag cloud-infrastructure-frontend \
  <registry-name>.azurecr.io/cloud-infrastructure-frontend:latest
docker push <registry-name>.azurecr.io/cloud-infrastructure-frontend:latest

# Deploy
az container create \
  --resource-group <resource-group> \
  --name cloud-infrastructure-frontend \
  --image <registry-name>.azurecr.io/cloud-infrastructure-frontend:latest \
  --dns-name-label cloud-infra-frontend \
  --ports 80
```

---

## Contributing

1. Fork this repository.
2. Create a feature branch: `git checkout -b feature/my-feature`.
3. Commit your changes: `git commit -m "feat: add my feature"`.
4. Push to your fork: `git push origin feature/my-feature`.
5. Open a pull request.
