from flask import Flask, jsonify, request
from flask_cors import CORS
import os
import logging

app = Flask(__name__)
CORS(app, origins=os.getenv("CORS_ORIGINS", "*").split(","))

logging.basicConfig(
    level=getattr(logging, os.getenv("LOG_LEVEL", "INFO").upper()),
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
logger = logging.getLogger(__name__)


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy", "service": "backend"}), 200


@app.route("/ready", methods=["GET"])
def ready():
    return jsonify({"status": "ready", "service": "backend"}), 200


@app.route("/api/v1/info", methods=["GET"])
def info():
    return jsonify(
        {
            "app": "Cloud Infrastructure Backend",
            "version": "1.0.0",
            "environment": os.getenv("APP_ENV", "development"),
        }
    ), 200


@app.route("/api/v1/items", methods=["GET"])
def get_items():
    items = [
        {"id": 1, "name": "Item One", "description": "First item"},
        {"id": 2, "name": "Item Two", "description": "Second item"},
    ]
    return jsonify({"items": items, "total": len(items)}), 200


@app.route("/api/v1/items/<int:item_id>", methods=["GET"])
def get_item(item_id):
    items = {
        1: {"id": 1, "name": "Item One", "description": "First item"},
        2: {"id": 2, "name": "Item Two", "description": "Second item"},
    }
    item = items.get(item_id)
    if not item:
        return jsonify({"error": "Item not found"}), 404
    return jsonify(item), 200


if __name__ == "__main__":
    port = int(os.getenv("APP_PORT", 5000))
    debug = os.getenv("APP_ENV", "production") == "development"
    logger.info("Starting backend server on port %d", port)
    app.run(host="0.0.0.0", port=port, debug=debug)
