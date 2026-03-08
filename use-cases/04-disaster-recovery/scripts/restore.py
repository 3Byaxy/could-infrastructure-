#!/usr/bin/env python3
"""
restore.py — Restore an EC2 instance from an AMI, or list available backups.

Usage:
    # List available backups
    python restore.py --list

    # Restore from a specific AMI
    python restore.py --ami-id ami-0123456789abcdef0 \
                      --instance-type t3.micro \
                      --key-name my-ssh-key \
                      --subnet-id subnet-abc123

Environment variables (or .env file):
    AWS_REGION     — AWS region (default: us-east-1)
    BACKUP_BUCKET  — S3 bucket name for backup metadata
"""

import argparse
import json
import os
import sys

import boto3
from botocore.exceptions import BotoCoreError, ClientError

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass


def get_clients(region: str):
    ec2 = boto3.client("ec2", region_name=region)
    s3 = boto3.client("s3", region_name=region)
    return ec2, s3


def list_backups(s3_client, bucket: str):
    """List all backup metadata files stored in S3."""
    print(f"\n📦 Available backups in s3://{bucket}/backups/\n")
    paginator = s3_client.get_paginator("list_objects_v2")
    pages = paginator.paginate(Bucket=bucket, Prefix="backups/")

    found = False
    for page in pages:
        for obj in page.get("Contents", []):
            found = True
            key = obj["Key"]
            # Download and display each metadata file
            response = s3_client.get_object(Bucket=bucket, Key=key)
            metadata = json.loads(response["Body"].read())
            print(f"  📄 {key}")
            print(f"     AMI ID:   {metadata.get('ami_id', 'N/A')}")
            print(f"     Source:   {metadata.get('source_instance', 'N/A')}")
            print(f"     Created:  {metadata.get('created_at', 'N/A')}")
            print(f"     Region:   {metadata.get('region', 'N/A')}")
            print()

    if not found:
        print("  No backups found. Run backup.py first.")


def restore_instance(ec2_client, ami_id: str, instance_type: str,
                     key_name: str, subnet_id: str) -> str:
    """Launch a new EC2 instance from the given AMI."""
    print(f"\n[restore] Launching instance from AMI {ami_id} ...")

    response = ec2_client.run_instances(
        ImageId=ami_id,
        MinCount=1,
        MaxCount=1,
        InstanceType=instance_type,
        KeyName=key_name,
        SubnetId=subnet_id,
        TagSpecifications=[
            {
                "ResourceType": "instance",
                "Tags": [
                    {"Key": "Name", "Value": f"restored-from-{ami_id}"},
                    {"Key": "RestoredFrom", "Value": ami_id},
                    {"Key": "ManagedBy", "Value": "cloud-infra-restore-script"},
                ],
            }
        ],
    )

    instance_id = response["Instances"][0]["InstanceId"]
    print(f"[restore] ✅ Instance launched: {instance_id}")
    print(f"[restore] Use `aws ec2 describe-instances --instance-ids {instance_id}` to check status.")
    return instance_id


def main():
    parser = argparse.ArgumentParser(description="Restore EC2 infrastructure from an AMI backup.")
    parser.add_argument("--list", action="store_true", help="List available backups in S3")
    parser.add_argument("--ami-id", help="AMI ID to restore from")
    parser.add_argument("--instance-type", default="t3.micro", help="EC2 instance type (default: t3.micro)")
    parser.add_argument("--key-name", help="SSH key pair name")
    parser.add_argument("--subnet-id", help="VPC subnet ID for the restored instance")
    args = parser.parse_args()

    region = os.environ.get("AWS_REGION", "us-east-1")
    bucket = os.environ.get("BACKUP_BUCKET", "")

    if not bucket:
        print("Error: BACKUP_BUCKET environment variable is not set.", file=sys.stderr)
        sys.exit(1)

    try:
        ec2, s3 = get_clients(region)

        if args.list:
            list_backups(s3, bucket)
        elif args.ami_id:
            if not args.key_name or not args.subnet_id:
                parser.error("--key-name and --subnet-id are required when restoring.")
            restore_instance(ec2, args.ami_id, args.instance_type, args.key_name, args.subnet_id)
        else:
            parser.print_help()
    except (BotoCoreError, ClientError) as exc:
        print(f"[restore] ❌ AWS error: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
