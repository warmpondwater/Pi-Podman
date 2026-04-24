#podman build -t pi-coding-agent-image -f Dockerfile .
FROM node:20-slim
RUN apt-get update && apt-get install -y \
    git \
     curl \
     && rm -rf /var/lib/apt/lists/*
# Install pi agent
RUN npm install -g npm@latest && npm install -g @mariozechner/pi-coding-agent
# --- ADD DENDRITE HERE ---
# Create directory for Dendrite
WORKDIR /opt/dendrite
# Copy your local built project into the image
15 COPY . .
# Install dependencies and build inside the container
RUN npm install && npm run build
# -------------------------
WORKDIR /app
ENTRYPOINT ["pi"]
# Update your .mcp.json to point to the INTERNAL path
# The path will be: /opt/dendrite/build/index.js
RUN mkdir -p /root/.pi/agent && \
     echo '{"mcpServers": {"dendrite": {"command": "node", "args":
      ["/opt/dendrite/build/index.js"]}}}' > /root/.pi/.mcp.json