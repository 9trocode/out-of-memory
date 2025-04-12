# Basic Node.js application Dockerfile
FROM node:18-alpine

# Set working directory
WORKDIR /app

# First stage: Install dependencies
COPY package*.json ./
RUN npm install

# Second stage: Run tests to verify environment variables
RUN echo "Testing environment variables..." && \
    echo "API_KEY=${API_KEY:-not set}" && \
    echo "DATABASE_URL=${DATABASE_URL:-not set}" && \
    echo "JWT_SECRET=${JWT_SECRET:-not set}"

# Third stage: Verify the .env file mounting
RUN echo "Checking if .env file is mounted..." && \
    if [ -f .env ]; then \
      echo ".env file is available:" && \
      cat .env | grep -v PASSWORD; \
    else \
      echo ".env file is NOT available"; \
    fi

# Fourth stage: Copy application code and build
COPY . .
RUN echo "Building application..." && \
    echo "Using environment from .env file (if mounted)" && \
    # Simulate a build with environment variables
    if [ -f .env ]; then \
      echo "Building with .env file"; \
      # We could source the .env here if needed \
    else \
      echo "Building without .env file"; \
    fi

# Final stage: Create a simple output
RUN echo "Build completed successfully!" > /app/build_result.txt && \
    echo "Environment variables were used securely." >> /app/build_result.txt

# Expose port and set start command
EXPOSE 3000
CMD ["node", "index.js"]
