# =============================================================================
# File: docker/Dockerfile
# Language: Dockerfile (Docker DSL)
# What it does: Multi-stage build that first assembles static web content,
#               then packages it into a lightweight Nginx production image.
# Maintainer: @3Byaxy
# =============================================================================

# =============================================================================
# STAGE 1 — Build Stage
# Use a full Node.js image to install dependencies and build the app.
# This stage is only used during the build process — it does NOT end up in
# the final image, which keeps the production image small and secure.
# =============================================================================
FROM node:20-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package files first (Docker caches layers, so this speeds up rebuilds
# when only source files change, not dependencies).
COPY package*.json ./

# Install dependencies — if package.json doesn't exist, skip gracefully
RUN if [ -f package.json ]; then npm ci --omit=dev; fi

# Copy the rest of the application source files
COPY . .

# Build the application (e.g., compile TypeScript, bundle React, etc.)
# If no build script exists, create a simple HTML file as a placeholder.
RUN if [ -f package.json ] && grep -q '"build"' package.json; then \
      npm run build; \
    else \
      mkdir -p /app/dist && \
      echo '<!DOCTYPE html><html><head><title>Cloud Infra</title></head><body><h1>Cloud Infrastructure App</h1><p>Deployed with Docker &amp; Nginx</p></body></html>' > /app/dist/index.html; \
    fi

# =============================================================================
# STAGE 2 — Production Stage
# Use the lightweight nginx:alpine image to serve the built static files.
# Alpine Linux is a tiny, security-focused Linux distribution.
# Only the files we explicitly copy from Stage 1 make it into this image.
# =============================================================================
FROM nginx:alpine AS production

# Add metadata labels to the image
LABEL maintainer="@3Byaxy"
LABEL description="Cloud Infrastructure web server"
LABEL version="1.0"

# Copy the built static files from Stage 1 into Nginx's serving directory.
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy a custom Nginx configuration file for fine-tuned settings.
# The default config is used if this file doesn't exist.
COPY nginx.conf /etc/nginx/nginx.conf 2>/dev/null || true

# Expose port 80 so Docker knows the container listens on this port.
EXPOSE 80

# Health check — Docker periodically runs this command to verify the container
# is healthy. If it fails repeatedly, Docker marks the container as unhealthy.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

# Start Nginx in the foreground (daemon off) so Docker can manage the process.
CMD ["nginx", "-g", "daemon off;"]
