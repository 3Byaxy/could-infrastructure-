# Ansible Starter Guide

Welcome to the **Ansible** section of this cloud infrastructure project! ⚙️

Ansible automates server configuration and application deployment. Write your tasks once, run them on any number of servers.

---

## 📋 What's in This Folder

| File | Purpose |
|------|---------|
| `playbook.yml` | Main automation playbook (installs & configures Nginx) |
| `inventory.ini` | List of servers Ansible will manage |

---

## 🚦 Getting Started

### Step 1: Install Ansible

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y ansible

# macOS
brew install ansible

# pip (works everywhere)
pip install ansible
```

Codespaces users — Ansible is already installed! ✅

### Step 2: Update the inventory

Edit `inventory.ini` and replace the example server details with your own:

```ini
[webservers]
192.168.1.10 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/my-key.pem
```

### Step 3: Test connectivity

```bash
ansible all -i inventory.ini -m ping
```

You should see `"ping": "pong"` for each server. ✅

### Step 4: Run the playbook

```bash
ansible-playbook -i inventory.ini playbook.yml
```

To do a dry run (no changes made):

```bash
ansible-playbook -i inventory.ini playbook.yml --check
```

### Step 5: Run with extra variables

```bash
ansible-playbook -i inventory.ini playbook.yml -e "app_name=my-app app_port=8080"
```

---

## 🧠 Key Concepts

| Concept | What it means |
|---------|--------------|
| **Playbook** | A YAML file describing automation tasks |
| **Inventory** | A list of servers to manage |
| **Task** | A single action (install a package, copy a file, etc.) |
| **Handler** | A task triggered only when notified (e.g., restart on config change) |
| **Module** | A built-in Ansible function (apt, copy, service, etc.) |
| **Variable** | A reusable value in your playbook |
| **become** | Run as a privileged user (like `sudo`) |

---

## 💡 Useful Commands

```bash
# List all hosts
ansible all -i inventory.ini --list-hosts

# Run a single ad-hoc command on all servers
ansible all -i inventory.ini -m shell -a "uptime"

# Check syntax without running
ansible-playbook playbook.yml --syntax-check

# Verbose mode (shows more detail)
ansible-playbook -i inventory.ini playbook.yml -v
```

---

## 📚 Learn More

- [Ansible Getting Started](https://docs.ansible.com/ansible/latest/getting_started/)
- [Ansible Module Index](https://docs.ansible.com/ansible/latest/collections/index_module.html)
