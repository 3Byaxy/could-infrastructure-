# ── Stage 1: Build the React app ────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies (cached layer)
COPY package.json .
RUN npm install --legacy-peer-deps

# Copy source and build
COPY public/ public/
COPY src/ src/
RUN npm run build

# ── Stage 2: Serve with Nginx ────────────────────────────────────────────────
FROM nginx:1.27-alpine

# Copy compiled assets
COPY --from=builder /app/build /usr/share/nginx/html

# Replace default Nginx config with our custom one
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
