# ── Stage 1: Build ─────────────────────────────────────────────────────────────
FROM node:18-alpine AS build

WORKDIR /app

# Install dependencies first (layer-cached unless package files change)
COPY package.json package-lock.json* ./
RUN npm ci --silent

# Copy source and build the production bundle
COPY public/ public/
COPY src/ src/

# Optional: pass backend URL at build time
# docker build --build-arg REACT_APP_API_URL=https://api.example.com .
ARG REACT_APP_API_URL=""
ENV REACT_APP_API_URL=$REACT_APP_API_URL

RUN npm run build

# ── Stage 2: Serve ─────────────────────────────────────────────────────────────
FROM nginx:1.25-alpine

# Remove the default nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy the production build from the build stage
COPY --from=build /app/build /usr/share/nginx/html

# Optional: custom nginx configuration for single-page apps (handles client-side routing)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
