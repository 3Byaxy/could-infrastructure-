# Kubernetes Starter Guide

Welcome to the **Kubernetes** section of this cloud infrastructure project! ⚓

Kubernetes (K8s) is an open-source system for automating deployment, scaling, and management of containerised applications.

---

## 📋 What's in This Folder

| File | Purpose |
|------|---------|
| `deployment.yaml` | Runs and manages your application Pods |
| `service.yaml` | Exposes your application to traffic |

---

## 🚦 Getting Started

### Step 1: Get a Kubernetes cluster

**Local options (free!):**

- [minikube](https://minikube.sigs.k8s.io/docs/start/) — run K8s on your laptop
- [kind](https://kind.sigs.k8s.io/) — K8s in Docker
- [k3s](https://k3s.io/) — lightweight K8s for Raspberry Pi and VMs

```bash
# Start a local cluster with minikube
minikube start

# Or with kind
kind create cluster
```

Codespaces users — minikube is already installed! Run `minikube start`. ✅

### Step 2: Check your cluster is working

```bash
kubectl cluster-info
kubectl get nodes
```

### Step 3: Deploy the application

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### Step 4: Check everything is running

```bash
# Check Pods
kubectl get pods

# Check Deployments
kubectl get deployments

# Check Services
kubectl get services
```

### Step 5: Access the application

```bash
# Port-forward to access locally
kubectl port-forward service/web-app-service 8080:80

# Then open: http://localhost:8080
```

### Step 6: Clean up

```bash
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
```

---

## 🧠 Key Concepts

| Concept | What it means |
|---------|--------------|
| **Pod** | The smallest unit — one or more containers sharing resources |
| **Deployment** | Manages multiple identical Pods, handles updates |
| **Service** | Stable network endpoint to reach your Pods |
| **ConfigMap** | Store non-sensitive configuration data |
| **Secret** | Store sensitive data (passwords, tokens) |
| **Namespace** | Logical grouping of resources |
| **Node** | A physical or virtual machine running Pods |
| **Cluster** | A set of Nodes managed by Kubernetes |

---

## 💡 Useful kubectl Commands

```bash
# Watch Pods in real time
kubectl get pods -w

# View Pod logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # follow (like tail -f)

# Execute a command inside a Pod
kubectl exec -it <pod-name> -- /bin/sh

# Describe a resource (great for debugging!)
kubectl describe pod <pod-name>
kubectl describe deployment web-app

# Scale up/down
kubectl scale deployment web-app --replicas=3

# View resource usage
kubectl top pods
kubectl top nodes
```

---

## 📚 Learn More

- [Kubernetes Basics (interactive tutorial)](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Play with Kubernetes (free browser lab)](https://labs.play-with-k8s.com/)
