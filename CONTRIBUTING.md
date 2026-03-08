# Contributing to Cloud Infrastructure

Thank you for your interest in contributing! 🎉 This project welcomes contributions from everyone — including beginners.

---

## 🌟 Ways to Contribute

- 🐛 **Report bugs** — open an issue if something doesn't work
- 📖 **Improve documentation** — fix typos, add examples, or clarify explanations
- ✨ **Add features** — new scripts, modules, or cloud provider examples
- 🙋 **Help others** — answer questions in issues and discussions
- ⭐ **Star the repo** — it helps others discover this project!

---

## 🚀 Getting Started

### 1. Fork and clone the repository

```bash
# Fork on GitHub, then:
git clone https://github.com/YOUR-USERNAME/cloud-infrastructure-.git
cd could-infrastructure-
```

### 2. Open in GitHub Codespaces (recommended for beginners!)

Click the **Code** button → **Codespaces** → **Create codespace on main**.  
All tools will be installed automatically.

### 3. Create a feature branch

```bash
git checkout -b feature/my-awesome-feature
# or
git checkout -b fix/typo-in-readme
```

### 4. Make your changes

Follow the [style guide](#-style-guide) below.

### 5. Test your changes

```bash
# Test shell scripts with bash (dry run)
bash -n scripts/my-script.sh

# Test Python scripts
python3 python/health_check.py

# Validate Terraform syntax
cd terraform/ && terraform validate

# Check Kubernetes manifests
kubectl apply --dry-run=client -f kubernetes/

# Test Ansible playbook syntax
ansible-playbook ansible/playbook.yml --syntax-check
```

### 6. Commit and push

```bash
git add .
git commit -m "feat: add health check for Redis endpoints"
git push origin feature/my-awesome-feature
```

### 7. Open a Pull Request

Go to GitHub and click **Compare & pull request**.

---

## ✍️ Commit Message Style

Use [Conventional Commits](https://www.conventionalcommits.org/) for clear history:

| Prefix | Use for |
|--------|---------|
| `feat:` | New features |
| `fix:` | Bug fixes |
| `docs:` | Documentation only |
| `chore:` | Maintenance (deps, config) |
| `refactor:` | Code improvements without behaviour change |

**Examples:**
```
feat: add GCP Terraform provider example
fix: correct SSH port in security group
docs: add beginner-friendly comments to playbook.yml
```

---

## 🎨 Style Guide

### Bash Scripts
- Always start with `#!/usr/bin/env bash`
- Use `set -euo pipefail`
- Add comments explaining *why*, not just *what*
- Use descriptive function names in `snake_case`

### Terraform (HCL)
- Use 2-space indentation
- Add `description` to all variables and outputs
- Group related resources with comments

### Python
- Follow [PEP 8](https://peps.python.org/pep-0008/) style
- Add type hints to functions
- Write docstrings for every function
- Use `f-strings` for string formatting

### Kubernetes YAML
- Add comments explaining resource purpose
- Always include `resource.requests` and `resource.limits`
- Include health checks (`readinessProbe`, `livenessProbe`)

### Ansible
- Use FQCN for modules: `ansible.builtin.apt`, not just `apt`
- Add `name:` to every task
- Use `notify` + handlers for service restarts

---

## 🔒 Security Guidelines

- **Never commit secrets**, credentials, or API keys
- Use `.gitignore` — it already excludes common secret files
- Prefer environment variables or secret managers for sensitive values
- Restrict SSH access in security groups to known CIDRs

---

## 🆘 Need Help?

- Open an issue with the **question** label
- Check existing issues — your question may already be answered
- Review the `README.md` and per-folder documentation

We're here to help you learn! No question is too basic. 😊

---

## 📄 Licence

By contributing, you agree that your contributions will be licensed under the [MIT Licence](LICENSE).
