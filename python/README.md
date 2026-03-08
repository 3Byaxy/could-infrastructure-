# Python Starter Guide

Welcome to the **Python** section of this cloud infrastructure project! 🐍

Python is widely used in cloud and DevOps for automation, tooling, and orchestration. AWS CLI, Ansible, and many cloud SDKs are written in Python.

---

## 📋 What's in This Folder

| File | Purpose |
|------|---------|
| `health_check.py` | Check the health of one or more services via HTTP |
| `requirements.txt` | Python package dependencies |

---

## 🚦 Getting Started

### Step 1: Install Python

```bash
# Check if Python is installed
python3 --version

# Install on Ubuntu/Debian
sudo apt install python3 python3-pip
```

Codespaces users — Python 3.11 is already installed! ✅

### Step 2: Create a virtual environment (recommended)

```bash
cd python/
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### Step 3: Install dependencies

```bash
pip install -r requirements.txt
```

### Step 4: Run the health checker

```bash
# Check default URLs (localhost:8080 and localhost:80)
python3 python/health_check.py

# Check specific URLs
python3 python/health_check.py --urls http://myserver.com https://api.example.com

# Output as JSON (great for scripts and CI pipelines)
python3 python/health_check.py --output json

# Customise timeout and retries
python3 python/health_check.py --timeout 10 --retries 5 --urls http://myserver.com
```

---

## 🧠 Python Concepts Used

| Concept | What it means |
|---------|--------------|
| `dataclass` | Auto-generated `__init__`, `__repr__` from field definitions |
| `argparse` | Built-in CLI argument parsing |
| `requests` | Third-party HTTP client library |
| `type hints` | `def fn(x: str) -> int` — document expected types |
| `f-strings` | `f"Hello {name}"` — inline string formatting |
| `sys.exit()` | Exit with a return code (0 = success) |

---

## 💡 Python for Cloud Automation

```python
# Use boto3 to list EC2 instances (requires: pip install boto3)
import boto3

ec2 = boto3.client("ec2", region_name="us-east-1")
instances = ec2.describe_instances()
for reservation in instances["Reservations"]:
    for instance in reservation["Instances"]:
        print(instance["InstanceId"], instance["State"]["Name"])
```

```python
# Use the Kubernetes Python client (requires: pip install kubernetes)
from kubernetes import client, config

config.load_kube_config()
v1 = client.CoreV1Api()
pods = v1.list_pod_for_all_namespaces()
for pod in pods.items:
    print(pod.metadata.namespace, pod.metadata.name)
```

---

## 📚 Learn More

- [Python Tutorial (official)](https://docs.python.org/3/tutorial/)
- [Real Python — Cloud Automation](https://realpython.com/python-boto3-aws-s3/)
- [boto3 Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)
- [Kubernetes Python Client](https://github.com/kubernetes-client/python)
