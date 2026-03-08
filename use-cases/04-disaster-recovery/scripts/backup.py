#!/usr/bin/env python3
"""
backup.py — Create EC2 AMI snapshots and store metadata in S3.

Usage:
    python backup.py --instance-id i-0123456789abcdef0

Environment variables (or .env file):
    AWS_REGION     — AWS region (default: us-east-1)
    BACKUP_BUCKET  — S3 bucket name for backup metadata
"""

import argparse
import json
import os
import sys
from datetime import datetime, timezone

import boto3
from botocore.exceptions import BotoCoreError, ClientError

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # python-dotenv is optional


def get_clients(region: str):
    ec2 = boto3.client("ec2", region_name=region)
    s3 = boto3.client("s3", region_name=region)
    return ec2, s3


def create_ami(ec2_client, instance_id: str) -> dict:
    """Create an AMI from the given EC2 instance and return AMI details."""
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    ami_name = f"backup-{instance_id}-{timestamp}"

    print(f"[backup] Creating AMI '{ami_name}' from instance {instance_id} ...")
    response = ec2_client.create_image(
        InstanceId=instance_id,
        Name=ami_name,
        Description=f"Automated backup of {instance_id} at {timestamp}",
        NoReboot=True,
    )
    ami_id = response["ImageId"]
    print(f"[backup] AMI created: {ami_id}")

    # Tag the AMI for easy identification
    ec2_client.create_tags(
        Resources=[ami_id],
        Tags=[
            {"Key": "Name", "Value": ami_name},
            {"Key": "SourceInstance", "Value": instance_id},
            {"Key": "CreatedBy", "Value": "cloud-infra-backup-script"},
            {"Key": "BackupDate", "Value": timestamp},
        ],
    )

    return {
        "ami_id": ami_id,
        "ami_name": ami_name,
        "source_instance": instance_id,
        "created_at": timestamp,
        "region": ec2_client.meta.region_name,
    }


def upload_metadata(s3_client, bucket: str, metadata: dict) -> str:
    """Upload backup metadata JSON to S3 and return the S3 key."""
    key = f"backups/{metadata['source_instance']}/{metadata['created_at']}.json"
    s3_client.put_object(
        Bucket=bucket,
        Key=key,
        Body=json.dumps(metadata, indent=2),
        ContentType="application/json",
    )
    print(f"[backup] Metadata uploaded to s3://{bucket}/{key}")
    return key


def main():
    parser = argparse.ArgumentParser(description="Back up an EC2 instance as an AMI.")
    parser.add_argument("--instance-id", required=True, help="EC2 instance ID to back up")
    args = parser.parse_args()

    region = os.environ.get("AWS_REGION", "us-east-1")
    bucket = os.environ.get("BACKUP_BUCKET", "")

    if not bucket:
        print("Error: BACKUP_BUCKET environment variable is not set.", file=sys.stderr)
        sys.exit(1)

    try:
        ec2, s3 = get_clients(region)
        metadata = create_ami(ec2, args.instance_id)
        upload_metadata(s3, bucket, metadata)
        print(f"\n[backup] ✅ Backup complete — AMI ID: {metadata['ami_id']}")
    except (BotoCoreError, ClientError) as exc:
        print(f"[backup] ❌ AWS error: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
