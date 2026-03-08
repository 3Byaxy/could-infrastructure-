# Docker Starter Guide

Welcome to the **Docker** section of this cloud infrastructure project! 🐳

Docker lets you package your application and all its dependencies into a portable container that runs the same way everywhere.

---

## 📋 What's in This Folder

| File | Purpose |
|------|---------|
| `Dockerfile` | Instructions to build the Docker image |
| `docker-compose.yml` | Multi-container application setup |
| `nginx.conf` | Custom Nginx web server configuration |
| `html/index.html` | Sample web page served by the container |

---

## 🚦 Getting Started

### Step 1: Install Docker

Download from https://docs.docker.com/get-docker/

Codespaces users — Docker is already installed! ✅

### Step 2: Build the Docker image

```bash
cd docker/
docker build -t cloud-infra-app .
```

### Step 3: Run the container

```bash
docker run -d -p 8080:80 --name my-app cloud-infra-app
```

Open http://localhost:8080 in your browser. 🎉

### Step 4: Use Docker Compose (recommended)

```bash
# Start all services
docker compose up -d

# View running containers
docker compose ps

# View logs
docker compose logs -f

# Stop everything
docker compose down
```

### Step 5: Start with developer tools (pgAdmin)

```bash
docker compose --profile dev up -d
# pgAdmin is at http://localhost:5050
```

---

## 🧠 Key Concepts

| Concept | What it means |
|---------|--------------|
| **Image** | A blueprint for a container (built from Dockerfile) |
| **Container** | A running instance of an image |
| **Dockerfile** | Instructions to build an image |
| **Docker Compose** | Tool to run multiple containers as a service |
| **Volume** | Persistent storage for containers |
| **Network** | Virtual network connecting containers |
| **Port** | `host:container` mapping (e.g., `8080:80`) |

---

## 💡 Useful Docker Commands

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View container logs
docker logs my-app
docker logs -f my-app  # follow

# Execute command inside container
docker exec -it my-app /bin/sh

# Stop and remove container
docker stop my-app && docker rm my-app

# List images
docker images

# Remove an image
docker rmi cloud-infra-app

# Remove all stopped containers and unused images
docker system prune
```

---

## 📚 Learn More

- [Docker Getting Started](https://docs.docker.com/get-started/)
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
- [Docker Compose Reference](https://docs.docker.com/compose/reference/)
- [Play with Docker (free browser lab)](https://labs.play-with-docker.com/)
