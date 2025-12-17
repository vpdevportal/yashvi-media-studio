# Stage 1: Turborepo base with Node
FROM node:20-alpine AS turbo-base
RUN npm install -g pnpm turbo
WORKDIR /app
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml turbo.json ./
COPY apps/backend/package.json ./apps/backend/
COPY apps/frontend/package.json ./apps/frontend/
RUN pnpm install --frozen-lockfile

# Stage 2: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS flutter-build
WORKDIR /app/frontend
COPY apps/frontend/ .
RUN flutter pub get
RUN flutter build web --release

# Stage 3: Production - Python Backend + Nginx for Flutter
FROM python:3.11-slim AS production
WORKDIR /app

# Install nginx
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

# Copy backend
COPY apps/backend/ ./backend/
RUN pip install --no-cache-dir -r backend/requirements.txt

# Copy Flutter web build
COPY --from=flutter-build /app/frontend/build/web /var/www/html

# Copy turbo config for reference/scripts
COPY --from=turbo-base /app/package.json /app/turbo.json ./

# Nginx config to serve Flutter and proxy API
RUN echo 'server { \
    listen 80; \
    root /var/www/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    location /api/ { \
        proxy_pass http://127.0.0.1:8000/; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
    } \
    location /ping { \
        proxy_pass http://127.0.0.1:8000/ping; \
    } \
    location /health { \
        proxy_pass http://127.0.0.1:8000/health; \
    } \
    location /docs { \
        proxy_pass http://127.0.0.1:8000/docs; \
    } \
    location /openapi.json { \
        proxy_pass http://127.0.0.1:8000/openapi.json; \
    } \
}' > /etc/nginx/sites-available/default

# Start script
RUN echo '#!/bin/bash\n\
cd /app/backend && uvicorn main:app --host 0.0.0.0 --port 8000 &\n\
nginx -g "daemon off;"' > /start.sh && chmod +x /start.sh

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/health || exit 1

CMD ["/start.sh"]
