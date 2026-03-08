# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --prefer-offline

COPY public/ public/
COPY src/ src/

ARG REACT_APP_API_URL
ENV REACT_APP_API_URL=${REACT_APP_API_URL}

RUN npm run build

# Production stage
FROM nginx:1.27-alpine

COPY --from=builder /app/build /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
