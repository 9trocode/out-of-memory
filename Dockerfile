# Use Alpine as a lightweight base image
FROM alpine:latest

# Set up build arguments (which will be mapped to secrets)
ARG API_KEY
ARG DATABASE_URL
ARG AUTH_SECRET

# Print a header
RUN echo "==== SECURITY TEST FOR ENVIRONMENT VARIABLES ===="

# Test 1: Check if ARG values are accessible as environment variables
RUN echo "Test 1: Checking ARG-mapped environment variables:"
RUN echo "API_KEY is set: $([ ! -z "$API_KEY" ] && echo "Yes (length: ${#API_KEY})" || echo "No")"
RUN echo "DATABASE_URL is set: $([ ! -z "$DATABASE_URL" ] && echo "Yes (length: ${#DATABASE_URL})" || echo "No")"
RUN echo "AUTH_SECRET is set: $([ ! -z "$AUTH_SECRET" ] && echo "Yes (first char: ${AUTH_SECRET:0:1}...)" || echo "No")"

# Test 2: Check if .env file is accessible (your code should auto-mount it)
RUN echo "Test 2: Checking .env file access:"
RUN if [ -f .env ]; then \
      echo "FOUND .env file with content:"; \
      cat .env; \
    else \
      echo "NO .env file found (this means your auto-mounting didn't work)"; \
    fi

# Test 3: Check values from .env file
RUN echo "Test 3: Checking values from .env file:"
RUN if [ -f .env ]; then \
      export $(grep -v '^#' .env | xargs) 2>/dev/null; \
      echo "APP_ENV from .env: $APP_ENV"; \
      echo "NODE_ENV from .env: $NODE_ENV"; \
    else \
      echo "No .env file to source values from"; \
    fi

# Test 4: Security check - verify .env is not in build context
RUN echo "Test 4: Security check - .env in build context:"
RUN find / -name ".env" | grep -v "proc" || echo "GOOD: No .env file found in build context"

# Test 5: Image history check (will be verified after build)
RUN echo "Test 5: Creating marker for image history check"
RUN echo "If you can see secret values in 'docker history', that's BAD"
RUN echo "HISTORY_MARKER: This line should be visible in history but no secrets should be"

# Create a simple script to run when the container starts
RUN echo '#!/bin/sh' > /entrypoint.sh
RUN echo 'echo "Container started, environment variables:"' >> /entrypoint.sh
RUN echo 'env | grep -E "API_KEY|DATABASE_URL|AUTH_SECRET|APP_|NODE_" || echo "No matching environment variables found at runtime"' >> /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to a non-root user for better security
RUN adduser -D appuser
USER appuser

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
