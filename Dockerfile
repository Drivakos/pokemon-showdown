FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Copy source code (needed for build script)
COPY . .

# Install dependencies (including dev dependencies for building)
RUN npm ci --include=dev

# Build the application (already built during postinstall, but ensure it's complete)
RUN npm run build

# Production stage
FROM node:18-alpine AS production

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S pokemonshowdown -u 1001

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production && npm cache clean --force

# Copy built application from builder stage
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/pokemon-showdown ./pokemon-showdown

# Copy configuration and data files
COPY --from=builder /app/config ./config
COPY --from=builder /app/data ./data
COPY --from=builder /app/databases ./databases

# Create necessary directories
RUN mkdir -p logs && \
    chown -R pokemonshowdown:nodejs /app

# Switch to non-root user
USER pokemonshowdown

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8000 || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Default command
CMD ["node", "pokemon-showdown", "start"]
