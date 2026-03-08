# Shell Scripts Starter Guide

Welcome to the **scripts** section of this cloud infrastructure project! 🐚

Bash scripts automate repetitive tasks — from setting up a new server to deploying your application in a single command.

---

## 📋 What's in This Folder

| Script | Purpose |
|--------|---------|
| `setup.sh` | Install all tools needed for this project (Docker, kubectl, Terraform, Ansible) |
| `deploy.sh` | Build, push, and deploy the application to Kubernetes |

---

## 🚦 Getting Started

### Make scripts executable

```bash
chmod +x scripts/*.sh
```

### Run the setup script

```bash
./scripts/setup.sh --env dev
```

### Run the deploy script

```bash
./scripts/deploy.sh --env dev --tag v1.0.0
```

---

## 🧠 Bash Concepts Used in These Scripts

| Concept | Example | What it does |
|---------|---------|-------------|
| `set -euo pipefail` | At top of script | Exit on any error |
| `$?` | Check exit code | 0 = success, non-zero = failure |
| `$#` | Count args | Number of arguments passed |
| `$@` | All args | All arguments as an array |
| `$1`, `$2`... | Positional | First, second argument, etc. |
| `command_exists()` | Custom function | Check if a command is available |
| `read -rp` | User prompt | Safely read user input |
| `>&2` | Redirect stderr | Send error messages to stderr |

---

## 💡 Useful Bash Tips

```bash
# Check if a command exists
command -v docker &>/dev/null && echo "Docker is installed"

# Loop over files
for file in *.yaml; do
  echo "Processing $file"
done

# Error handling
if ! terraform apply; then
  echo "Terraform failed!" >&2
  exit 1
fi

# Read a file line by line
while IFS= read -r line; do
  echo "$line"
done < servers.txt

# Get script directory (useful for relative paths)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

---

## 📚 Learn More

- [Bash Guide for Beginners](https://tldp.org/LDP/Bash-Beginners-Guide/html/)
- [ShellCheck — Bash linter](https://www.shellcheck.net/)
- [Explain Shell commands](https://explainshell.com/)
