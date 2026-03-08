# Use Case 7: Containerized App Deployment

Package a **Python web app** with a **PostgreSQL database** and **Redis cache** using Docker and Docker Compose for local development and testing.

---

## 📁 Directory Structure

```
07-containerized-app/
├── app/
│   ├── app.py            # Flask web app (connects to Postgres + Redis)
│   ├── Dockerfile        # Container image for the web app
│   └── requirements.txt  # Python dependencies
├── docker-compose.yml    # Multi-service environment (web + db + cache)
└── README.md
```

---

## Architecture

```
┌──────────────────────────────────────────────────────┐
│                  Docker Network                       │
│                                                      │
│  ┌──────────┐    ┌──────────────┐    ┌───────────┐  │
│  │  Web App │───▶│  PostgreSQL  │    │   Redis   │  │
│  │ (Flask)  │    │  (db:5432)   │    │ (cache:6379)│ │
│  │ :5000    │◀───│              │    │           │  │
│  └──────────┘    └──────────────┘    └───────────┘  │
│       │                                    │         │
└───────┼────────────────────────────────────┼─────────┘
        │                                    │
   localhost:5000                     (internal only)
```

---

## Prerequisites

- Docker >= 24.0
- Docker Compose >= 2.0

---

## Steps

### Step 1 — Start All Services

```bash
docker compose up --build
```

This will start:
- **web** — Flask app on port `5000`
- **db** — PostgreSQL 16 on port `5432`
- **cache** — Redis 7 on port `6379`

### Step 2 — Verify the App

Open [http://localhost:5000](http://localhost:5000) in your browser.

You should see:
- A page showing database connection status
- A page visit counter powered by Redis

### Step 3 — Run in Detached Mode

```bash
docker compose up -d
```

### Step 4 — View Logs

```bash
docker compose logs -f web
```

### Step 5 — Stop and Clean Up

```bash
# Stop containers
docker compose down

# Stop and remove volumes (deletes database data)
docker compose down -v
```

---

## What You'll Learn

- Writing multi-stage Dockerfiles for Python web apps
- Defining multi-service environments with Docker Compose
- Connecting a Flask app to PostgreSQL and Redis
- Using Docker volumes for database persistence
- Health checks and service dependencies in Compose
