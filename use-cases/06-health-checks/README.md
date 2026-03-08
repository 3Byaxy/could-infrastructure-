# Use Case 6: Cloud Infrastructure Health Checks

Use **Python** and the `boto3` AWS SDK to verify that your AWS resources (EC2 instances and S3 buckets) are healthy and accessible. Generate periodic health reports.

---

## 📁 Directory Structure

```
06-health-checks/
├── scripts/
│   ├── health_check.py   # Main health check script (EC2 + S3)
│   └── requirements.txt  # Python dependencies
└── README.md
```

---

## Prerequisites

- Python >= 3.10
- AWS CLI configured (`aws configure`)
- Install dependencies:
  ```bash
  pip install -r scripts/requirements.txt
  ```

---

## Usage

### Check All Resources

```bash
cd scripts
python health_check.py
```

### Check Only EC2 Instances

```bash
python health_check.py --ec2-only
```

### Check Only S3 Buckets

```bash
python health_check.py --s3-only
```

### Specify a Region

```bash
python health_check.py --region us-west-2
```

### Save Report to a File

```bash
python health_check.py --output report.json
```

---

## Sample Output

```
══════════════════════════════════════════════════════════
  ☁️  Cloud Infrastructure Health Report
  Region: us-east-1 | Time: 2024-01-15 10:30:00 UTC
══════════════════════════════════════════════════════════

📦 EC2 Instances
────────────────────────────────────────────────────────
  ✅ i-0abc123def456   web-server      running   t3.micro
  ✅ i-0def456abc789   db-server       running   t3.small
  ⚠️  i-0ghi789jkl012  batch-worker    stopped   t3.micro

📂 S3 Buckets
────────────────────────────────────────────────────────
  ✅ my-static-website    (accessible)   Objects: 12
  ✅ my-backup-bucket     (accessible)   Objects: 47
  ❌ old-bucket-xyz       (access denied)

══════════════════════════════════════════════════════════
  Summary: 2/3 EC2 healthy | 2/3 S3 accessible
══════════════════════════════════════════════════════════
```

---

## What You'll Learn

- Using the `boto3` Python library to interact with AWS
- Checking EC2 instance states and S3 bucket accessibility
- Building health check scripts with command-line arguments
- Generating structured reports from AWS API responses
- Automating periodic checks with cron or AWS EventBridge
