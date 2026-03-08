from flask import Flask, jsonify, request
from flask_cors import CORS
import uuid

app = Flask(__name__)
CORS(app)

# In-memory store (replace with a real database in production)
items = [
    {"id": "1", "name": "Cloud Server", "description": "A virtual machine in the cloud"},
    {"id": "2", "name": "Object Storage", "description": "Scalable blob/object storage"},
    {"id": "3", "name": "Managed Database", "description": "Fully managed relational database"},
]


@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "service": "backend-api"})


@app.route("/api/items", methods=["GET"])
def get_items():
    return jsonify(items)


@app.route("/api/items/<item_id>", methods=["GET"])
def get_item(item_id):
    item = next((i for i in items if i["id"] == item_id), None)
    if item is None:
        return jsonify({"error": "Item not found"}), 404
    return jsonify(item)


@app.route("/api/items", methods=["POST"])
def create_item():
    data = request.get_json()
    if not data or "name" not in data:
        return jsonify({"error": "Field 'name' is required"}), 400
    new_item = {
        "id": str(uuid.uuid4()),
        "name": data["name"],
        "description": data.get("description", ""),
    }
    items.append(new_item)
    return jsonify(new_item), 201


@app.route("/api/items/<item_id>", methods=["DELETE"])
def delete_item(item_id):
    global items
    original_len = len(items)
    items = [i for i in items if i["id"] != item_id]
    if len(items) == original_len:
        return jsonify({"error": "Item not found"}), 404
    return jsonify({"message": "Item deleted"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
