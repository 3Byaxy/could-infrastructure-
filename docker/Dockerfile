# =============================================================================
# Cloud Infrastructure - Dockerfile
# =============================================================================
# A Dockerfile defines how to build a Docker image for your application.
#
# BEGINNER TIP: Each line creates a "layer" in the image. Layers are cached,
# so put things that change rarely (like dependencies) near the top.
# =============================================================================

# ---- Stage 1: Builder ----
# Use a full Node.js image to install dependencies and build assets
# (Remove this stage if you are not using a build step)
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files first (better layer caching)
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production 2>/dev/null || echo "No package.json found, skipping"

# ---- Stage 2: Production image ----
# Use a minimal Nginx image for serving
FROM nginx:1.25-alpine

# Add metadata labels (best practice)
LABEL maintainer="cloud-infra-project"
LABEL description="Cloud Infrastructure sample web application"
LABEL version="1.0"

# Remove the default Nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the web application files
# In a real project, you'd copy your built app here:
# COPY --from=builder /app/dist /usr/share/nginx/html
COPY html/ /usr/share/nginx/html/

# Nginx runs on port 80
EXPOSE 80

# Healthcheck so Docker (and Kubernetes) can detect unhealthy containers
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost/ || exit 1

# Run Nginx in the foreground (Docker requires this)
CMD ["nginx", "-g", "daemon off;"]
