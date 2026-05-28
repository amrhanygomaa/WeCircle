# ╔══════════════════════════════════════════════════════════════╗
# ║          WeCircle Backend — Production Dockerfile           ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Stage 1: Build ──────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies first (layer cache optimization)
COPY package.json package-lock.json ./
RUN npm ci --only=production=false

# Copy source and compile TypeScript
COPY . .
RUN npm run build

# ── Stage 2: Production ─────────────────────────────────────────
FROM node:20-alpine AS production

WORKDIR /app

# Security: run as non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser  -S nodejs -u 1001

# Only copy compiled output + prod dependencies
COPY package.json package-lock.json ./
RUN npm ci --only=production && npm cache clean --force

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

# Generate Prisma client in production image
RUN npx prisma generate

USER nodejs

EXPOSE 5001

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:5001/ || exit 1

CMD ["node", "dist/server.js"]
