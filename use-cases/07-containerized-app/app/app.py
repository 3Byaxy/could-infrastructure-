"""
Flask web application demonstrating containerized deployment.
Connects to PostgreSQL for data persistence and Redis for caching.
Use Case 7: Containerized App Deployment
"""

import os
import time

import psycopg2
import redis
from flask import Flask, jsonify

app = Flask(__name__)

# ── Database configuration ───────────────────────────────────────────────────
DB_HOST = os.environ.get("DB_HOST", "db")
DB_PORT = int(os.environ.get("DB_PORT", 5432))
DB_NAME = os.environ.get("DB_NAME", "appdb")
DB_USER = os.environ.get("DB_USER", "appuser")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "apppassword")

# ── Redis configuration ───────────────────────────────────────────────────────
REDIS_HOST = os.environ.get("REDIS_HOST", "cache")
REDIS_PORT = int(os.environ.get("REDIS_PORT", 6379))


def get_db_status() -> tuple[bool, str]:
    """Check PostgreSQL connectivity and return (ok, message)."""
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            connect_timeout=3,
        )
        conn.close()
        return True, "Connected ✅"
    except psycopg2.OperationalError as exc:
        return False, f"Error ❌: {exc}"


def get_visit_count() -> int | str:
    """Increment and return the page visit counter from Redis."""
    try:
        r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
        return r.incr("visit_count")
    except redis.RedisError as exc:
        return f"Redis unavailable: {exc}"


@app.route("/")
def index():
    db_ok, db_msg = get_db_status()
    visits = get_visit_count()

    db_color = "#68d391" if db_ok else "#fc8181"

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Containerized App</title>
  <style>
    * {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{ font-family: 'Segoe UI', sans-serif; background: #0f3460;
           color: #e0e0e0; display: flex; align-items: center;
           justify-content: center; min-height: 100vh; }}
    .card {{ background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1);
             border-radius: 12px; padding: 2.5rem; max-width: 560px; width: 100%;
             margin: 1rem; }}
    h1 {{ font-size: 1.8rem; margin-bottom: 0.5rem; }}
    span {{ color: #e94560; }}
    p {{ color: #a0aec0; margin-bottom: 1.5rem; }}
    .service {{ background: rgba(0,0,0,0.3); border-radius: 8px; padding: 1rem;
                margin-bottom: 0.75rem; display: flex; justify-content: space-between;
                align-items: center; }}
    .label {{ font-weight: 600; font-size: 0.95rem; }}
    .value {{ font-size: 0.9rem; color: {db_color}; }}
    .visits {{ text-align: center; margin-top: 1.5rem; font-size: 2rem; font-weight: 700; }}
    .visits small {{ display: block; font-size: 0.85rem; color: #a0aec0;
                     font-weight: 400; margin-top: 0.25rem; }}
  </style>
</head>
<body>
  <div class="card">
    <h1>🐳 <span>Containerized</span> App</h1>
    <p>Running with Docker Compose — web + database + cache.</p>

    <div class="service">
      <span class="label">🐘 PostgreSQL</span>
      <span class="value">{db_msg}</span>
    </div>
    <div class="service">
      <span class="label">🔴 Redis Cache</span>
      <span class="value" style="color: #68d391;">Connected ✅</span>
    </div>

    <div class="visits">
      {visits}
      <small>total page visits (tracked by Redis)</small>
    </div>
  </div>
</body>
</html>"""


@app.route("/health")
def health():
    """Health check endpoint."""
    db_ok, _ = get_db_status()
    status = "healthy" if db_ok else "degraded"
    return jsonify({"status": status, "database": db_ok}), 200 if db_ok else 503


if __name__ == "__main__":
    # Wait briefly for dependent services to become available
    time.sleep(2)
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)
