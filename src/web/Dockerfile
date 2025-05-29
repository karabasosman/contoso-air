# Use official Node.js 22 slim image for smaller attack surface
FROM node:22-slim

# Set working directory
WORKDIR /app

# Install dependencies first for better layer caching
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Copy application source code
COPY . .

# Set environment variables for production
ENV NODE_ENV=production

# Expose the port the app runs on
EXPOSE 3000

# Use a non-root user for security
RUN useradd --user-group --create-home --shell /bin/false appuser
USER appuser

# Healthcheck for container reliability
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3000/ || exit 1

# Start the application
CMD ["npm", "start"]

# Notes:
# - Azure CosmosDB connection is managed via environment variables (see README)
# - Managed Identity is supported via @azure/identity
# - For Azure Container Apps or App Service, configure environment variables in the deployment settings
# - For local development, use a .env file or export variables before running the container
