#!/usr/bin/env python3
"""
health_check.py — Check the health of AWS EC2 instances and S3 buckets.

Usage:
    python health_check.py [options]

Options:
    --region    AWS region to check (default: us-east-1)
    --ec2-only  Check only EC2 instances
    --s3-only   Check only S3 buckets
    --output    Save JSON report to a file

Environment variables (or .env file):
    AWS_REGION  — Default AWS region
"""

import argparse
import json
import os
import sys
from datetime import datetime, timezone

import boto3
from botocore.exceptions import BotoCoreError, ClientError, NoCredentialsError

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

# Health status constants
STATUS_HEALTHY = "healthy"
STATUS_WARNING = "warning"
STATUS_ERROR = "error"

EC2_HEALTHY_STATES = {"running"}
EC2_WARNING_STATES = {"stopped", "stopping", "pending", "rebooting"}


def get_ec2_health(region: str) -> list[dict]:
    """Return health status for all EC2 instances in the region."""
    ec2 = boto3.client("ec2", region_name=region)
    results = []

    try:
        paginator = ec2.get_paginator("describe_instances")
        pages = paginator.paginate()

        for page in pages:
            for reservation in page.get("Reservations", []):
                for instance in reservation.get("Instances", []):
                    instance_id = instance["InstanceId"]
                    state = instance["State"]["Name"]
                    instance_type = instance.get("InstanceType", "unknown")

                    # Get the Name tag if available
                    tags = {tag["Key"]: tag["Value"] for tag in instance.get("Tags", [])}
                    name = tags.get("Name", "(no name)")

                    if state in EC2_HEALTHY_STATES:
                        status = STATUS_HEALTHY
                    elif state in EC2_WARNING_STATES:
                        status = STATUS_WARNING
                    else:
                        status = STATUS_ERROR

                    results.append({
                        "resource_type": "ec2",
                        "id": instance_id,
                        "name": name,
                        "state": state,
                        "instance_type": instance_type,
                        "status": status,
                        "availability_zone": instance.get("Placement", {}).get("AvailabilityZone", ""),
                    })
    except (BotoCoreError, ClientError) as exc:
        print(f"  ⚠️  Could not retrieve EC2 instances: {exc}", file=sys.stderr)

    return results


def get_s3_health(region: str) -> list[dict]:
    """Return health status for all S3 buckets accessible to the caller."""
    s3 = boto3.client("s3", region_name=region)
    results = []

    try:
        buckets = s3.list_buckets().get("Buckets", [])

        for bucket in buckets:
            bucket_name = bucket["Name"]
            result = {
                "resource_type": "s3",
                "name": bucket_name,
                "created_at": bucket["CreationDate"].isoformat(),
                "object_count": None,
                "status": STATUS_HEALTHY,
                "detail": "accessible",
            }

            # Try to get object count as a health indicator
            try:
                s3_resource = boto3.resource("s3", region_name=region)
                bucket_obj = s3_resource.Bucket(bucket_name)
                result["object_count"] = sum(1 for _ in bucket_obj.objects.limit(10000))
            except ClientError as exc:
                error_code = exc.response["Error"]["Code"]
                if error_code in ("AccessDenied", "AllAccessDisabled"):
                    result["status"] = STATUS_ERROR
                    result["detail"] = "access denied"
                else:
                    result["status"] = STATUS_WARNING
                    result["detail"] = f"error: {error_code}"

            results.append(result)
    except (BotoCoreError, ClientError) as exc:
        print(f"  ⚠️  Could not retrieve S3 buckets: {exc}", file=sys.stderr)

    return results


def print_ec2_report(instances: list[dict]):
    """Print a formatted EC2 health report."""
    print("\n📦 EC2 Instances")
    print("─" * 60)

    if not instances:
        print("  No EC2 instances found.")
        return

    for inst in instances:
        icon = "✅" if inst["status"] == STATUS_HEALTHY else ("⚠️ " if inst["status"] == STATUS_WARNING else "❌")
        print(f"  {icon} {inst['id']:<22} {inst['name']:<20} {inst['state']:<12} {inst['instance_type']}")


def print_s3_report(buckets: list[dict]):
    """Print a formatted S3 health report."""
    print("\n📂 S3 Buckets")
    print("─" * 60)

    if not buckets:
        print("  No S3 buckets found.")
        return

    for bucket in buckets:
        icon = "✅" if bucket["status"] == STATUS_HEALTHY else ("⚠️ " if bucket["status"] == STATUS_WARNING else "❌")
        count_str = f"Objects: {bucket['object_count']}" if bucket["object_count"] is not None else bucket["detail"]
        print(f"  {icon} {bucket['name']:<40} ({count_str})")


def print_summary(instances: list[dict], buckets: list[dict]):
    """Print a summary line with overall health counts."""
    print("\n" + "═" * 60)
    ec2_healthy = sum(1 for i in instances if i["status"] == STATUS_HEALTHY)
    s3_healthy = sum(1 for b in buckets if b["status"] == STATUS_HEALTHY)
    ec2_total = len(instances)
    s3_total = len(buckets)

    ec2_summary = f"{ec2_healthy}/{ec2_total} EC2 healthy" if ec2_total else "no EC2 instances"
    s3_summary = f"{s3_healthy}/{s3_total} S3 accessible" if s3_total else "no S3 buckets"

    print(f"  Summary: {ec2_summary} | {s3_summary}")
    print("═" * 60)


def main():
    parser = argparse.ArgumentParser(description="Check AWS cloud infrastructure health.")
    parser.add_argument("--region", default=os.environ.get("AWS_REGION", "us-east-1"),
                        help="AWS region to check (default: us-east-1)")
    parser.add_argument("--ec2-only", action="store_true", help="Check only EC2 instances")
    parser.add_argument("--s3-only", action="store_true", help="Check only S3 buckets")
    parser.add_argument("--output", metavar="FILE", help="Save JSON report to a file")
    args = parser.parse_args()

    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")

    print("═" * 60)
    print(f"  ☁️  Cloud Infrastructure Health Report")
    print(f"  Region: {args.region} | Time: {now}")
    print("═" * 60)

    try:
        instances: list[dict] = []
        buckets: list[dict] = []

        if not args.s3_only:
            instances = get_ec2_health(args.region)
            print_ec2_report(instances)

        if not args.ec2_only:
            buckets = get_s3_health(args.region)
            print_s3_report(buckets)

        print_summary(instances, buckets)

        if args.output:
            report = {
                "generated_at": now,
                "region": args.region,
                "ec2": instances,
                "s3": buckets,
            }
            with open(args.output, "w", encoding="utf-8") as f:
                json.dump(report, f, indent=2, default=str)
            print(f"\n📄 Report saved to: {args.output}")

    except NoCredentialsError:
        print("\n❌ AWS credentials not found. Run `aws configure` first.", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nAborted.")
        sys.exit(0)


if __name__ == "__main__":
    main()
