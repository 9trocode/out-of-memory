# Simple test Dockerfile
FROM alpine:latest

# Set up args that will be mapped to secrets
ARG API_KEY
ARG DATABASE_URL
ARG JWT_SECRET

# First RUN command will be auto-modified to mount the .env file
RUN echo "===== Testing Secrets =====" && \
    echo "API_KEY is set: $([ -n "$API_KEY" ] && echo 'yes' || echo 'no')" && \
    echo "DATABASE_URL is set: $([ -n "$DATABASE_URL" ] && echo 'yes' || echo 'no')" && \
    echo "JWT_SECRET is set: $([ -n "$JWT_SECRET" ] && echo 'yes' || echo 'no')"

# Second RUN command will also get the .env mount
RUN if [ -f .env ]; then \
      echo "===== .env file found =====" && \
      cat .env | sed 's/^/  /' && \
      echo "===== End of .env =====" && \
      echo "Loading .env..." && \
      export $(grep -v '^#' .env | xargs); \
    else \
      echo "No .env file found"; \
    fi

# Test that environment variables from the .env file are accessible
RUN if [ -n "$DB_CONNECTION" ]; then \
      echo "DB_CONNECTION from .env: $DB_CONNECTION"; \
    else \
      echo "DB_CONNECTION not found in environment"; \
    fi

# This command tries to access the .env file directly (to verify it's not in the build context)
RUN if [ -f /app/.env ]; then \
      echo "WARNING: .env file found in build context at /app/.env"; \
    else \
      echo "Good: .env file is not in the build context"; \
    fi

# Create a minimal application
RUN mkdir -p /app
WORKDIR /app
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'echo "Application starting with environment variables:"' >> /app/start.sh && \
    echo 'env | sort' >> /app/start.sh && \
    chmod +x /app/start.sh

CMD ["/app/start.sh"]
