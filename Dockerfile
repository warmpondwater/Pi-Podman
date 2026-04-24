#podman build -t pi-coding-agent-image -f Dockerfile .
FROM node:20-slim
RUN apt-get update && apt-get install -y \
    git \
    curl \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*
# Install pi agent
RUN npm install -g npm@latest && npm install -g @mariozechner/pi-coding-agent
# --- ADD DENDRITE HERE ---
# Create directory for Dendrite
WORKDIR /opt/Dendrite-MCP
# Copy your local built project into the image
COPY Dendrite-MCP .
# Clean and install dependencies to ensure native modules match the container architecture
RUN rm -rf node_modules && npm install --legacy-peer-deps && npm run build
# -------------------------
WORKDIR /app
ENTRYPOINT ["pi"]
# Update your .mcp.json to point to the INTERNAL path
#The path will be: /opt/dendrite/build/index.js
