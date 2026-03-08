# Use Case 4: Disaster Recovery Infrastructure

Define **backup plans**, **automated restoration scripts**, and **recovery infrastructure** using Python and Terraform.

---

## 📁 Directory Structure

```
04-disaster-recovery/
├── terraform/
│   ├── main.tf          # S3 backup bucket with versioning + lifecycle rules
│   ├── variables.tf     # Input variables
│   └── outputs.tf       # Bucket name and ARN
├── scripts/
│   ├── backup.py        # Create EC2 AMI snapshots and upload to S3
│   └── restore.py       # Restore EC2 instance from AMI / list backups
└── README.md
```

---

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.5
- Python >= 3.10
- `boto3` and `python-dotenv` Python packages:
  ```bash
  pip install boto3 python-dotenv
  ```

---

## Steps

### Step 1 — Provision the Backup Bucket with Terraform

```bash
cd terraform
terraform init
terraform apply -var="project_name=my-infra"
```

Note the `backup_bucket_name` output.

### Step 2 — Configure Environment Variables

Create a `.env` file in `scripts/` (do not commit this file):

```env
AWS_REGION=us-east-1
BACKUP_BUCKET=<backup_bucket_name from terraform output>
```

### Step 3 — Run a Backup

```bash
cd scripts
python backup.py --instance-id i-0123456789abcdef0
```

This will:
- Create an AMI of the specified EC2 instance
- Upload instance metadata as JSON to S3

### Step 4 — List Available Backups

```bash
python restore.py --list
```

### Step 5 — Restore from a Backup

```bash
python restore.py --ami-id ami-0123456789abcdef0 --instance-type t3.micro --key-name my-key --subnet-id subnet-abc123
```

### Step 6 — Clean Up

```bash
cd terraform
terraform destroy
```

---

## What You'll Learn

- Creating S3 buckets with versioning and lifecycle policies (Glacier transition)
- Programmatically creating EC2 AMI snapshots with `boto3`
- Storing and retrieving backup metadata from S3
- Launching a new EC2 instance from an AMI for restoration
- Disaster recovery planning fundamentals
