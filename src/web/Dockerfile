# syntax=docker/dockerfile:1

# Development stage
FROM node:22-alpine AS development
LABEL stage=development
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci
COPY . .
CMD ["npm", "start"]

# Production build stage  
FROM node:22-alpine AS build
LABEL stage=build
WORKDIR /usr/src/app

# Copy package files and install only production dependencies
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copy source code
COPY . .

# Production runtime stage
FROM node:22-alpine AS production

# Add metadata
LABEL maintainer="Contoso Air Team" \
      description="Contoso Air booking application" \
      version="1.0" \
      stage=production

WORKDIR /usr/src/app

# Create non-root user early for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only production node_modules and application files from build stage
COPY --from=build --chown=appuser:appgroup /usr/src/app/node_modules ./node_modules
COPY --from=build --chown=appuser:appgroup /usr/src/app/package*.json ./
COPY --from=build --chown=appuser:appgroup /usr/src/app/app.js ./
COPY --from=build --chown=appuser:appgroup /usr/src/app/bin ./bin
COPY --from=build --chown=appuser:appgroup /usr/src/app/config ./config
COPY --from=build --chown=appuser:appgroup /usr/src/app/data ./data
COPY --from=build --chown=appuser:appgroup /usr/src/app/locales ./locales
COPY --from=build --chown=appuser:appgroup /usr/src/app/public ./public
COPY --from=build --chown=appuser:appgroup /usr/src/app/repositories ./repositories
COPY --from=build --chown=appuser:appgroup /usr/src/app/routes ./routes
COPY --from=build --chown=appuser:appgroup /usr/src/app/services ./services
COPY --from=build --chown=appuser:appgroup /usr/src/app/views ./views

# Copy health check script
COPY --chown=appuser:appgroup healthcheck.js ./

# Set production environment
ENV NODE_ENV=production

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3000

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1

# Use exec form for proper signal handling
CMD ["node", "./bin/www"]
