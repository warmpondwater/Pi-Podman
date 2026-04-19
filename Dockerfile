#podman build -t pi-coding-agent-image -f Dockerfile .

# Use a lightweight Node.js base
FROM node:20-slim

RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Update npm and install the pi-coding-agent globally
RUN npm install -g npm@latest && npm install -g @mariozechner/pi-coding-agent

# Set working directory
WORKDIR /app

# The command to run when the container starts
ENTRYPOINT ["pi"]

# Create the config directory
RUN mkdir -p /root/.pi/agent
