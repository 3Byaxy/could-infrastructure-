#!/usr/bin/env python3
"""
health_check.py — Cloud Infrastructure Health Checker
======================================================
Checks the health of one or more services by making HTTP requests
and reporting their status.

Usage:
    python3 python/health_check.py
    python3 python/health_check.py --urls http://localhost:8080 https://example.com
    python3 python/health_check.py --timeout 10 --retries 5

BEGINNER TIP: Read each function to learn Python patterns used in cloud tooling.
"""

import argparse
import json
import sys
import time
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Optional

try:
    import requests
except ImportError:
    print("ERROR: 'requests' library not installed. Run: pip install requests", file=sys.stderr)
    sys.exit(1)


# =============================================================================
# Data structures
# =============================================================================

@dataclass
class HealthResult:
    """Stores the result of a single health check."""
    url: str
    status_code: Optional[int] = None
    response_time_ms: Optional[float] = None
    healthy: bool = False
    error: Optional[str] = None
    checked_at: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

    def to_dict(self) -> dict:
        return {
            "url": self.url,
            "healthy": self.healthy,
            "status_code": self.status_code,
            "response_time_ms": round(self.response_time_ms, 2) if self.response_time_ms else None,
            "error": self.error,
            "checked_at": self.checked_at,
        }


# =============================================================================
# Core logic
# =============================================================================

def check_url(url: str, timeout: int = 5, retries: int = 3) -> HealthResult:
    """
    Perform a health check on a single URL.

    Args:
        url:     The URL to check.
        timeout: HTTP request timeout in seconds.
        retries: Number of attempts before giving up.

    Returns:
        A HealthResult with status information.
    """
    result = HealthResult(url=url)
    last_error = None

    for attempt in range(1, retries + 1):
        try:
            start = time.monotonic()
            response = requests.get(url, timeout=timeout, allow_redirects=True)
            elapsed_ms = (time.monotonic() - start) * 1000

            result.status_code = response.status_code
            result.response_time_ms = elapsed_ms
            result.healthy = response.status_code < 400  # 2xx and 3xx are healthy
            return result

        except requests.exceptions.ConnectionError as exc:
            last_error = f"Connection refused or DNS failure: {exc}"
        except requests.exceptions.Timeout:
            last_error = f"Request timed out after {timeout}s"
        except requests.exceptions.RequestException as exc:
            last_error = f"Request failed: {exc}"

        if attempt < retries:
            time.sleep(1)  # Wait before retry

    result.error = last_error
    result.healthy = False
    return result


def check_all(urls: list[str], timeout: int = 5, retries: int = 3) -> list[HealthResult]:
    """Check health of all provided URLs."""
    results = []
    for url in urls:
        print(f"  Checking {url}...", end=" ", flush=True)
        result = check_url(url, timeout=timeout, retries=retries)
        status = "✅" if result.healthy else "❌"
        print(f"{status}", end=" ")
        if result.status_code:
            print(f"[{result.status_code}]", end=" ")
        if result.response_time_ms:
            print(f"({result.response_time_ms:.0f}ms)", end=" ")
        if result.error:
            print(f"— {result.error}", end="")
        print()
        results.append(result)
    return results


def print_summary(results: list[HealthResult]) -> None:
    """Print a human-readable summary table."""
    healthy_count = sum(1 for r in results if r.healthy)
    total = len(results)

    print()
    print("=" * 60)
    print(f"  Health Check Summary: {healthy_count}/{total} services healthy")
    print("=" * 60)
    for r in results:
        icon = "✅" if r.healthy else "❌"
        code = f"HTTP {r.status_code}" if r.status_code else "N/A"
        ms = f"{r.response_time_ms:.0f}ms" if r.response_time_ms else "N/A"
        print(f"  {icon}  {r.url:<40} {code:<10} {ms}")
    print("=" * 60)
    print()


# =============================================================================
# CLI entry point
# =============================================================================

DEFAULT_URLS = [
    "http://localhost:8080",
    "http://localhost:80",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Cloud Infrastructure Health Checker",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="Examples:\n"
               "  python3 health_check.py\n"
               "  python3 health_check.py --urls http://myserver.com https://api.example.com\n"
               "  python3 health_check.py --output json\n",
    )
    parser.add_argument(
        "--urls",
        nargs="+",
        default=DEFAULT_URLS,
        metavar="URL",
        help="One or more URLs to check (default: localhost:8080, localhost:80)",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=5,
        help="Request timeout in seconds (default: 5)",
    )
    parser.add_argument(
        "--retries",
        type=int,
        default=3,
        help="Number of retry attempts per URL (default: 3)",
    )
    parser.add_argument(
        "--output",
        choices=["text", "json"],
        default="text",
        help="Output format: text (default) or json",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    print()
    print("☁️  Cloud Infrastructure Health Checker")
    print(f"   Checking {len(args.urls)} service(s)...")
    print()

    results = check_all(args.urls, timeout=args.timeout, retries=args.retries)

    if args.output == "json":
        output = {
            "checked_at": datetime.now(timezone.utc).isoformat(),
            "results": [r.to_dict() for r in results],
            "summary": {
                "total": len(results),
                "healthy": sum(1 for r in results if r.healthy),
                "unhealthy": sum(1 for r in results if not r.healthy),
            },
        }
        print(json.dumps(output, indent=2))
    else:
        print_summary(results)

    # Exit with non-zero code if any service is unhealthy
    all_healthy = all(r.healthy for r in results)
    return 0 if all_healthy else 1


if __name__ == "__main__":
    sys.exit(main())
