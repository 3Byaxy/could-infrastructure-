# Use Case 2: Automated Server Provisioning

Launch an **EC2 instance** on AWS using Terraform, then configure it automatically with **Ansible** — installing Nginx, configuring a firewall, and deploying your application.

---

## 📁 Directory Structure

```
02-server-provisioning/
├── terraform/
│   ├── main.tf          # EC2 instance + security group + key pair
│   ├── variables.tf     # Input variables
│   └── outputs.tf       # Public IP and instance ID
├── ansible/
│   ├── playbook.yml     # Ansible playbook (Nginx + firewall + app deploy)
│   └── inventory.ini    # Ansible inventory (hosts file)
└── README.md
```

---

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.5
- Ansible >= 2.14
- An SSH key pair (see Step 1 below)

---

## Steps

### Step 1 — Generate an SSH Key Pair

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/cloud-infra-key -N ""
```

### Step 2 — Provision the EC2 Instance with Terraform

```bash
cd terraform
terraform init
terraform apply -var="public_key_path=~/.ssh/cloud-infra-key.pub"
```

Take note of the output `public_ip`.

### Step 3 — Update the Ansible Inventory

Edit `ansible/inventory.ini` and replace `<EC2_PUBLIC_IP>` with the IP address from Step 2:

```ini
[webservers]
<EC2_PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/cloud-infra-key
```

### Step 4 — Run the Ansible Playbook

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

### Step 5 — Verify the Deployment

Open a browser and navigate to `http://<EC2_PUBLIC_IP>` — you should see the Nginx welcome page with your app running.

### Step 6 — Clean Up

```bash
cd terraform
terraform destroy
```

---

## What You'll Learn

- Provisioning EC2 instances with Terraform
- Creating and attaching security groups (SSH + HTTP)
- Managing SSH key pairs in AWS
- Writing Ansible playbooks for configuration management
- Installing and configuring Nginx as a reverse proxy
- Deploying a simple web app from an Ansible task
