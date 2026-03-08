# syntax=docker/dockerfile:1

FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM base AS final
COPY src/ ./src/
EXPOSE 3000
USER node
CMD ["node", "src/index.js"]
