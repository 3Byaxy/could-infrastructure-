<div align="center">

# ☁️ Cloud Infrastructure

**A beginner-friendly, professional cloud infrastructure project**

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/3Byaxy/could-infrastructure-)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-v1.0+-7B42BC?logo=terraform)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?logo=ansible)](https://www.ansible.com/)
[![Docker](https://img.shields.io/badge/Docker-Container-2496ED?logo=docker)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-326CE5?logo=kubernetes)](https://kubernetes.io/)

</div>

---

## 🌟 What is Cloud Infrastructure?

> **In plain English:** Cloud infrastructure is all the computers, networks, and storage that live in giant data centers (buildings full of servers) around the world. Instead of buying your own physical computers, you rent them from companies like Amazon (AWS), Google, or Microsoft — and you only pay for what you use!

Think of it like renting an apartment instead of buying a house. You get all the benefits (electricity, water, maintenance) without owning the hardware yourself.

This project teaches you how to **manage cloud infrastructure using code** — which means you can create and configure entire cloud environments just by running scripts!

---

## 🖥️ What is a GitHub Codespace?

> **In plain English:** A Codespace is a computer in the cloud that runs your code editor (VS Code) inside your web browser. It already has all the tools you need pre-installed. No setup required on your own laptop!

Think of it like borrowing a perfectly set-up computer from GitHub. When you click "Open in Codespaces" above, GitHub spins up a fresh environment with everything ready to go in about 60 seconds. 🚀

---

## 🗂️ Project Structure

Here's what each folder does, explained simply:

```
could-infrastructure-/
│
├── 🏗️  terraform/          → Blueprint for cloud servers (like architectural plans)
│   ├── main.tf             → The main configuration file
│   ├── variables.tf        → Settings you can customize (region, server size, etc.)
│   └── outputs.tf          → Results printed after building (IP addresses, etc.)
│
├── ⚙️  ansible/            → Automatic server setup (like a to-do list for servers)
│   └── playbook.yml        → Instructions for configuring servers
│
├── ☸️  kubernetes/         → Manages running containers at scale (like a restaurant manager)
│   ├── deployment.yaml     → How many copies of the app to run
│   └── service.yaml        → How to reach the app from the internet
│
├── 🐳  docker/             → Packages the app into a portable container (like a lunchbox)
│   ├── Dockerfile          → Recipe for building the container
│   └── docker-compose.yml  → Runs multiple containers together
│
├── 📜  scripts/            → Helper scripts that automate tasks
│   └── setup.sh            → Installs all required tools automatically
│
└── 🔧  .devcontainer/      → Tells GitHub Codespaces how to set up this project
    ├── devcontainer.json   → Codespace configuration
    └── Dockerfile          → Container image for the dev environment
```

### 📖 Folder Explanations (Beginner Style!)

| Folder | Analogy | What it does |
|--------|---------|-------------|
| 🏗️ **terraform/** | Architect's blueprints | Defines what cloud servers to create |
| ⚙️ **ansible/** | A robot assistant's to-do list | Automatically sets up and configures servers |
| 🐳 **docker/** | A packed lunchbox | Wraps your app so it runs the same everywhere |
| ☸️ **kubernetes/** | A restaurant manager | Runs many copies of your app and handles failures |
| 📜 **scripts/** | Cheat codes | Automates repetitive tasks |

---

## 🚀 Quick Start

### Option 1: GitHub Codespaces (Easiest — Recommended for Beginners!) ✨

1. Click the **"Open in GitHub Codespaces"** badge at the top of this page
2. Wait about 60 seconds for the environment to set up
3. All tools (Terraform, Ansible, Docker, kubectl, AWS CLI) will be installed automatically!
4. Start exploring the files and learning 🎉

### Option 2: Run Locally

**Prerequisites:** Git, Bash, and internet access.

```bash
# 1. Clone the repository
git clone https://github.com/3Byaxy/could-infrastructure-.git
cd could-infrastructure-

# 2. Run the setup script to install all tools
bash scripts/setup.sh

# 3. Verify everything is installed
terraform version
ansible --version
docker --version
kubectl version --client
aws --version
```

---

## 🏗️ Using Terraform

```bash
# Go to the terraform folder
cd terraform

# Initialize Terraform (downloads required plugins)
terraform init

# Preview what will be created (safe — doesn't actually build anything)
terraform plan

# Actually create the infrastructure (requires AWS credentials)
terraform apply

# Destroy everything when you're done
terraform destroy
```

> 💡 **Tip for beginners:** Always run `terraform plan` before `terraform apply` to see what will change!

---

## ⚙️ Using Ansible

```bash
# Run the playbook on your servers (replace with your server IP)
ansible-playbook ansible/playbook.yml -i "YOUR_SERVER_IP,"

# Dry run (check mode — no changes are made)
ansible-playbook ansible/playbook.yml -i "YOUR_SERVER_IP," --check
```

---

## 🐳 Using Docker

```bash
# Go to the docker folder
cd docker

# Build and start all containers
docker compose up --build

# Start in background (detached mode)
docker compose up -d

# Stop everything
docker compose down
```

After running `docker compose up`, visit **http://localhost:8080** in your browser!

---

## ☸️ Using Kubernetes

```bash
# Deploy the app to Kubernetes
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml

# Check the status of your deployment
kubectl get deployments
kubectl get pods
kubectl get services
```

---

## 🛠️ Tools Used

| Tool | What it does | Learn more |
|------|-------------|-----------|
| **Terraform** | Creates cloud resources with code | [terraform.io](https://www.terraform.io/) |
| **Ansible** | Configures servers automatically | [ansible.com](https://www.ansible.com/) |
| **Docker** | Packages apps into containers | [docker.com](https://www.docker.com/) |
| **Kubernetes** | Manages containers at scale | [kubernetes.io](https://kubernetes.io/) |
| **AWS CLI** | Controls Amazon Web Services | [aws.amazon.com](https://aws.amazon.com/cli/) |

---

## 📚 New to Cloud? Start Here!

Check out our **[LEARN.md](LEARN.md)** file for a beginner-friendly guide that explains every tool in simple terms, with links to free learning resources!

---

## 🤝 Contributing

1. Fork this repository
2. Create a new branch: `git checkout -b feature/my-improvement`
3. Make your changes and add comments explaining what you did
4. Open a Pull Request — see our [PR template](.github/pull_request_template.md)

---

## 📄 License

This project is open source under the [MIT License](LICENSE). That means you can use, copy, and modify it freely!

---

<div align="center">
  Made with ❤️ by <a href="https://github.com/3Byaxy">3Byaxy</a> · 
  ⭐ Star this repo if you found it helpful!
</div>
