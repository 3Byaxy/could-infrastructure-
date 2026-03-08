"""
Simple Flask web application for cloud infrastructure demonstration.
Use Case 3: Kubernetes App Deployment
"""

import os
import socket
from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def index():
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Cloud Infra App</title>
  <style>
    body {{ font-family: 'Segoe UI', sans-serif; background: #0f3460;
           color: #e0e0e0; display: flex; align-items: center;
           justify-content: center; min-height: 100vh; margin: 0;
           text-align: center; }}
    .card {{ background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1);
             border-radius: 12px; padding: 3rem 2rem; max-width: 500px; }}
    h1 {{ font-size: 2rem; }} span {{ color: #e94560; }}
    p {{ color: #a0aec0; line-height: 1.8; }}
    .badge {{ background: #e94560; color: white; padding: 0.3rem 1rem;
              border-radius: 20px; font-size: 0.8rem; font-weight: 600; }}
  </style>
</head>
<body>
  <div class="card">
    <div class="badge">☸️ Running on Kubernetes</div>
    <h1>Hello from <span>Pod</span></h1>
    <p>Hostname: <strong>{socket.gethostname()}</strong></p>
    <p>This containerized app is deployed with Kubernetes
       across multiple replicas for high availability.</p>
  </div>
</body>
</html>"""


@app.route("/health")
def health():
    """Health check endpoint used by Kubernetes liveness/readiness probes."""
    return jsonify({"status": "healthy", "hostname": socket.gethostname()}), 200


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
