# Use Case 3: Kubernetes Application Deployment

Deploy a containerized web application to a **Kubernetes** cluster using manifests, and test it locally with **Docker Compose**.

---

## 📁 Directory Structure

```
03-kubernetes-deployment/
├── manifests/
│   ├── namespace.yaml    # Kubernetes namespace
│   ├── deployment.yaml   # App deployment (3 replicas)
│   └── service.yaml      # LoadBalancer service to expose the app
├── app/
│   ├── app.py            # Simple Python Flask web app
│   └── Dockerfile        # Container image definition
├── docker-compose.yml    # Local multi-service testing
└── README.md
```

---

## Option A: Deploy to Kubernetes

### Prerequisites
- A running Kubernetes cluster (e.g. minikube, kind, or a cloud cluster)
- `kubectl` configured to point at your cluster
- Docker (to build the image)
- A container registry (Docker Hub, ECR, etc.)

### Steps

1. **Build and push the Docker image:**
   ```bash
   docker build -t YOUR_DOCKERHUB_USERNAME/cloud-infra-app:latest ./app
   docker push YOUR_DOCKERHUB_USERNAME/cloud-infra-app:latest
   ```

2. **Update the image reference** in `manifests/deployment.yaml`:
   ```yaml
   image: YOUR_DOCKERHUB_USERNAME/cloud-infra-app:latest
   ```

3. **Apply the Kubernetes manifests:**
   ```bash
   kubectl apply -f manifests/namespace.yaml
   kubectl apply -f manifests/deployment.yaml
   kubectl apply -f manifests/service.yaml
   ```

4. **Check the deployment:**
   ```bash
   kubectl get all -n cloud-infra
   ```

5. **Access the app:**
   - If using minikube: `minikube service webapp-service -n cloud-infra --url`
   - If using a cloud cluster: use the `EXTERNAL-IP` from `kubectl get svc -n cloud-infra`

6. **Clean up:**
   ```bash
   kubectl delete namespace cloud-infra
   ```

---

## Option B: Test Locally with Docker Compose

### Prerequisites
- Docker >= 24.0
- Docker Compose >= 2.0

### Steps

1. **Start the services:**
   ```bash
   docker compose up --build
   ```

2. **Open in browser:** [http://localhost:5000](http://localhost:5000)

3. **Stop the services:**
   ```bash
   docker compose down
   ```

---

## What You'll Learn

- Writing Kubernetes `Deployment`, `Service`, and `Namespace` manifests
- Rolling updates and replica scaling in Kubernetes
- Building and pushing Docker images to a registry
- Local multi-service testing with Docker Compose
- `kubectl` commands for managing workloads
