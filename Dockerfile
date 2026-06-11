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
ARG CACHEBUST=1
RUN npm install -g npm@latest && npm install -g @mariozechner/pi-coding-agent@latest
WORKDIR /app
EXPOSE 3000
ENTRYPOINT ["pi"]
