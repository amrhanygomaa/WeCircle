# ── Stage 1: build (all deps, TypeScript compile, Prisma generate) ──────────
FROM node:24-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
# prisma generate must run while the prisma CLI (dev dep) is available.
RUN npx prisma generate && npm run build

# ── Stage 2: lean production image ──────────────────────────────────────────
FROM node:24-alpine AS runner
WORKDIR /app

# Run as non-root for security.
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

# Copy the generated Prisma client (native binaries + JS) from the build stage.
# The prisma CLI is not available here, so we can't re-run prisma generate.
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/node_modules/@prisma/client ./node_modules/@prisma/client

USER nodejs
EXPOSE 5001

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:5001/ || exit 1

CMD ["node", "dist/server.js"]
