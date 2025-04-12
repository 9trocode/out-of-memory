# Use Node.js as the base image for testing frontend builds
FROM node:18-alpine AS build

# Set up build arguments (which will be mapped to secrets)
ARG API_KEY
ARG DATABASE_URL
ARG AUTH_SECRET

# Create a working directory
WORKDIR /app

# First, test individual secret variables
RUN echo "Testing individual secret access:"
RUN echo "API_KEY is set: $([ ! -z "$API_KEY" ] && echo "Yes" || echo "No")"
RUN echo "DATABASE_URL is set: $([ ! -z "$DATABASE_URL" ] && echo "Yes" || echo "No")"
RUN echo "AUTH_SECRET is set: $([ ! -z "$AUTH_SECRET" ] && echo "Yes" || echo "No")"

# Create a basic package.json file for testing
RUN echo '{"name":"secret-test","version":"1.0.0","scripts":{"test-env":"node test-env.js"}}' > package.json

# Create a test script to check .env file
RUN echo 'console.log("Checking for .env file:");' > test-env.js
RUN echo 'const fs = require("fs");' >> test-env.js
RUN echo 'if (fs.existsSync(".env")) {' >> test-env.js
RUN echo '  console.log("Found .env file with content:");' >> test-env.js
RUN echo '  console.log(fs.readFileSync(".env", "utf8"));' >> test-env.js
RUN echo '} else {' >> test-env.js
RUN echo '  console.log(".env file not found");' >> test-env.js
RUN echo '}' >> test-env.js

# Second, test mounting the .env file
RUN --mount=type=secret,id=env,dst=.env \
    echo "Testing .env file access:" && \
    cat .env 2>/dev/null || echo ".env file not mounted" && \
    npm run test-env

# Create a simple web app that will use environment variables
RUN echo 'console.log("Environment variables available at runtime:");' > app.js
RUN echo 'console.log(`API_KEY: ${process.env.API_KEY || "Not set"}`);' >> app.js
RUN echo 'console.log(`DATABASE_URL: ${process.env.DATABASE_URL || "Not set"}`);' >> app.js
RUN echo 'console.log(`AUTH_SECRET: ${process.env.AUTH_SECRET || "Not set"}`);' >> app.js

# Final test: see if environment variables are available at runtime
FROM node:18-alpine AS final
WORKDIR /app
COPY --from=build /app/app.js .
CMD ["node", "app.js"]
