# 🤝 Contributing to Cloud Infrastructure

Thank you for taking the time to contribute! This guide will walk you through the process of forking the repository, making changes, and opening a pull request.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
  - [1. Fork the Repository](#1-fork-the-repository)
  - [2. Clone Your Fork](#2-clone-your-fork)
  - [3. Create a Branch](#3-create-a-branch)
  - [4. Make Your Changes](#4-make-your-changes)
  - [5. Commit Your Changes](#5-commit-your-changes)
  - [6. Push Your Branch](#6-push-your-branch)
  - [7. Open a Pull Request](#7-open-a-pull-request)
- [Pull Request Guidelines](#pull-request-guidelines)
- [Reporting Issues](#reporting-issues)

---

## 📜 Code of Conduct

By participating in this project you agree to maintain a respectful, inclusive, and collaborative environment. Please be kind and constructive in all interactions.

---

## 🛠 How to Contribute

### 1. Fork the Repository

Click the **Fork** button at the top-right of the repository page on GitHub. This creates a personal copy of the project under your own GitHub account.

### 2. Clone Your Fork

```bash
git clone https://github.com/<your-username>/could-infrastructure-.git
cd could-infrastructure-
```

Add the upstream remote so you can pull future changes from the original repository:

```bash
git remote add upstream https://github.com/3Byaxy/could-infrastructure-.git
```

### 3. Create a Branch

Always create a new branch for your work — **never commit directly to `main`**.

Use a descriptive name that reflects your change:

```bash
# Feature branch
git checkout -b feature/add-eks-module

# Bug fix branch
git checkout -b fix/terraform-variable-typo

# Documentation branch
git checkout -b docs/update-readme
```

### 4. Make Your Changes

- Follow the existing code style and folder conventions.
- Add comments to explain non-obvious logic.
- Ensure your changes do not break existing configurations.
- Update documentation if your change affects usage.

### 5. Commit Your Changes

Write clear, concise commit messages that explain **what** changed and **why**:

```bash
# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "feat: add EKS cluster Terraform module"
```

**Commit message conventions:**

| Prefix | When to use |
|--------|-------------|
| `feat:` | A new feature or configuration |
| `fix:` | A bug fix |
| `docs:` | Documentation changes only |
| `chore:` | Maintenance tasks (formatting, dependency updates) |
| `refactor:` | Code restructuring without behaviour change |

### 6. Push Your Branch

```bash
git push origin feature/add-eks-module
```

### 7. Open a Pull Request

1. Go to your fork on GitHub.
2. Click **Compare & pull request** (GitHub usually shows this automatically after a push).
3. Set the **base repository** to `3Byaxy/could-infrastructure-` and **base branch** to `main`.
4. Fill in the pull request template:
   - **Title**: Short description of the change.
   - **Description**: What was changed, why, and how to test it.
5. Click **Create pull request**.

A maintainer will review your PR and may request changes before merging.

---

## ✅ Pull Request Guidelines

- Keep pull requests focused — one change per PR when possible.
- Make sure your branch is up to date with `upstream/main` before opening a PR:

  ```bash
  git fetch upstream
  git rebase upstream/main
  ```

- Resolve any merge conflicts before requesting a review.
- Respond promptly to review comments.

---

## 🐛 Reporting Issues

Found a bug or have a feature request? Please [open an issue](https://github.com/3Byaxy/could-infrastructure-/issues) and include:

- A clear description of the problem or request.
- Steps to reproduce (for bugs).
- Expected vs. actual behaviour.
- Relevant logs or error messages.

---

Thank you for contributing! 🙌
