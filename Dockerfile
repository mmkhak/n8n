# Dockerfile for building n8n from source
# This is a simplified version that builds the entire project

ARG NODE_VERSION=22.21.0

# ==============================================================================
# STAGE 1: Build Stage
# ==============================================================================
FROM node:${NODE_VERSION}-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git \
    bash

# Install pnpm
RUN corepack enable && corepack prepare pnpm@10.18.3 --activate

WORKDIR /build

# Copy configuration files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY tsconfig.json turbo.json ./
COPY scripts ./scripts
COPY patches ./patches

# Copy all packages
COPY packages ./packages

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build the project
RUN pnpm build:deploy

# ==============================================================================
# STAGE 2: Runtime Stage
# ==============================================================================
FROM n8nio/base:${NODE_VERSION} AS runtime

ARG N8N_VERSION=1.118.0
ARG N8N_RELEASE_TYPE=stable
ENV NODE_ENV=production
ENV N8N_RELEASE_TYPE=${N8N_RELEASE_TYPE}
ENV NODE_ICU_DATA=/usr/local/lib/node_modules/full-icu
ENV SHELL=/bin/sh

WORKDIR /home/node

# Copy built application from builder stage
COPY --from=builder /build/compiled /usr/local/lib/node_modules/n8n

# Copy docker entrypoint and config
COPY docker/images/n8n/docker-entrypoint.sh /
COPY docker/images/n8n/n8n-task-runners.json /etc/n8n-task-runners.json

# Setup n8n
RUN cd /usr/local/lib/node_modules/n8n && \
    npm rebuild sqlite3 && \
    ln -s /usr/local/lib/node_modules/n8n/bin/n8n /usr/local/bin/n8n && \
    mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node

# Install pdfjs canvas dependency
RUN cd /usr/local/lib/node_modules/n8n/node_modules/pdfjs-dist && npm install @napi-rs/canvas

EXPOSE 5678/tcp
USER node
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]

LABEL org.opencontainers.image.title="n8n" \
      org.opencontainers.image.description="Workflow Automation Tool" \
      org.opencontainers.image.source="https://github.com/n8n-io/n8n" \
      org.opencontainers.image.url="https://n8n.io" \
      org.opencontainers.image.version=${N8N_VERSION}
