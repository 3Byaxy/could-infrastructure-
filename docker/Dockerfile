# =============================================================================
# Dockerfile — Base Application Image
# =============================================================================
# This Dockerfile builds a lightweight production-ready image using a
# multi-stage build pattern. Replace the build and runtime sections with your
# own application logic.
#
# Build:
#   docker build -t cloud-infra-app:latest .
# Run:
#   docker run -p 8080:80 cloud-infra-app:latest
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Build stage (optional — include if you have a build step)
# -----------------------------------------------------------------------------
FROM node:20-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy dependency manifests first to leverage Docker layer caching
COPY package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev

# Copy the rest of the application source code
COPY . .

# -----------------------------------------------------------------------------
# Stage 2: Runtime stage — create a minimal final image
# -----------------------------------------------------------------------------
FROM nginx:1.25-alpine AS runtime

# Remove default Nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy built artefacts from the builder stage (adjust path as needed)
COPY --from=builder /app /usr/share/nginx/html

# Expose the port the application listens on
EXPOSE 80

# Health check so Docker (and Kubernetes) know when the app is ready
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost/ || exit 1

# Default command — start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
