#!/usr/bin/env python3
# =============================================================================
# File: scripts/check_infra.py
# Language: Python 3 (compatible with Python 3.8+)
# What it does: Connects to AWS using the boto3 library and generates a health
#               report showing all running EC2 instances and S3 buckets.
#               Beginner-friendly comments explain every step.
# Maintainer: @3Byaxy
# =============================================================================

# Import the libraries we need.
# boto3 is the official Python library for talking to AWS services.
import boto3
import sys
from datetime import datetime, timezone

# botocore handles errors from the AWS API — we use it to catch them nicely.
from botocore.exceptions import NoCredentialsError, ClientError


# =============================================================================
# HELPER: Print a horizontal divider line to separate sections
# =============================================================================
def print_divider(char="─", width=60):
    print(char * width)


# =============================================================================
# HELPER: Print a section header with a title
# =============================================================================
def print_header(title: str):
    print()
    print_divider("═")
    print(f"  {title}")
    print_divider("═")


# =============================================================================
# LIST EC2 INSTANCES
# EC2 = Elastic Compute Cloud — these are your virtual servers in the cloud.
# We look for instances that are currently "running" (not stopped or terminated).
# =============================================================================
def list_running_ec2_instances(ec2_client) -> list:
    """Return a list of currently running EC2 instances."""

    print_header("🖥️  Running EC2 Instances")

    # Use the describe_instances API to get information about all instances.
    # Filters narrow down the results to only running instances.
    response = ec2_client.describe_instances(
        Filters=[
            {
                "Name": "instance-state-name",  # Filter by the state of the instance
                "Values": ["running"],          # We only want "running" instances
            }
        ]
    )

    # The response contains "Reservations" — groups of instances launched together.
    # We loop through them to find all individual instances.
    running_instances = []
    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            running_instances.append(instance)

    if not running_instances:
        # No running instances found — this is not necessarily a problem.
        print("  ℹ️  No running EC2 instances found.")
        return running_instances

    # Print a table of each running instance with key details.
    print(f"  Found {len(running_instances)} running instance(s):\n")
    print(f"  {'Instance ID':<22} {'Type':<14} {'Public IP':<18} {'Name'}")
    print_divider()

    for instance in running_instances:
        # Get the instance ID (e.g., "i-0abc123def456789")
        instance_id = instance.get("InstanceId", "N/A")

        # Get the instance type (e.g., "t2.micro")
        instance_type = instance.get("InstanceType", "N/A")

        # Get the public IP address (may be empty for private-only instances)
        public_ip = instance.get("PublicIpAddress", "No public IP")

        # Tags are key-value pairs attached to resources for identification.
        # We look for a "Name" tag to show a human-readable name.
        tags = instance.get("Tags", [])
        name = next((t["Value"] for t in tags if t["Key"] == "Name"), "Unnamed")

        print(f"  {instance_id:<22} {instance_type:<14} {public_ip:<18} {name}")

    return running_instances


# =============================================================================
# LIST S3 BUCKETS
# S3 = Simple Storage Service — used to store files, backups, and static assets.
# =============================================================================
def list_s3_buckets(s3_client) -> list:
    """Return a list of all S3 buckets in the account."""

    print_header("🪣  S3 Buckets")

    # list_buckets returns all buckets in the AWS account (not region-specific).
    response = s3_client.list_buckets()

    # The bucket list is inside the "Buckets" key of the response.
    buckets = response.get("Buckets", [])

    if not buckets:
        print("  ℹ️  No S3 buckets found in this account.")
        return buckets

    print(f"  Found {len(buckets)} bucket(s):\n")
    print(f"  {'Bucket Name':<50} {'Creation Date'}")
    print_divider()

    for bucket in buckets:
        # Each bucket has a name and a creation date
        name = bucket.get("Name", "N/A")
        created = bucket.get("CreationDate", "Unknown")

        # Format the date nicely if it's a datetime object
        if isinstance(created, datetime):
            created = created.strftime("%Y-%m-%d %H:%M UTC")

        print(f"  {name:<50} {created}")

    return buckets


# =============================================================================
# PRINT SUMMARY REPORT
# Summarizes the overall health of the infrastructure.
# =============================================================================
def print_summary(ec2_count: int, s3_count: int):
    """Print a short health summary."""

    print_header("📊  Infrastructure Health Summary")

    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
    print(f"  Report generated at : {now}")
    print(f"  Running EC2 instances: {ec2_count}")
    print(f"  S3 buckets           : {s3_count}")

    print()
    if ec2_count == 0 and s3_count == 0:
        print("  ⚠️  Status: No resources found. Is your AWS account configured correctly?")
    else:
        print("  ✅  Status: Infrastructure is active and resources are detected.")

    print()
    print_divider("═")
    print()


# =============================================================================
# MAIN — the entry point of the script
# =============================================================================
def main():
    print()
    print("=" * 60)
    print("  Cloud Infrastructure Health Check")
    print("  Maintainer: @3Byaxy")
    print("=" * 60)
    print()
    print("  Connecting to AWS...")

    try:
        # Create boto3 clients for EC2 and S3.
        # boto3 automatically reads credentials from:
        #   1. Environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
        #   2. ~/.aws/credentials file (set up with `aws configure`)
        #   3. IAM role attached to an EC2 instance or Lambda function
        ec2_client = boto3.client("ec2", region_name="us-east-1")
        s3_client  = boto3.client("s3")

        # Run each check and collect the results
        instances = list_running_ec2_instances(ec2_client)
        buckets   = list_s3_buckets(s3_client)

        # Print the final summary
        print_summary(len(instances), len(buckets))

    except NoCredentialsError:
        # This error means boto3 could not find AWS credentials.
        print()
        print("  ❌  ERROR: AWS credentials not found.")
        print()
        print("  To fix this, do one of the following:")
        print("    1. Run 'aws configure' and enter your Access Key ID and Secret")
        print("    2. Set environment variables:")
        print("         export AWS_ACCESS_KEY_ID=your_key")
        print("         export AWS_SECRET_ACCESS_KEY=your_secret")
        print()
        sys.exit(1)

    except ClientError as error:
        # This error means the AWS API returned an error response.
        error_code = error.response["Error"]["Code"]
        error_message = error.response["Error"]["Message"]
        print()
        print(f"  ❌  AWS API Error [{error_code}]: {error_message}")
        print()
        sys.exit(1)

    except Exception as error:
        # Catch any other unexpected errors
        print()
        print(f"  ❌  Unexpected error: {error}")
        print()
        sys.exit(1)


# This block ensures main() only runs when the script is executed directly,
# not when it is imported as a module by another Python file.
if __name__ == "__main__":
    main()
