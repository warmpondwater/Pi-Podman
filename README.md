# 🛡️ Pi-Podman: The "Anti-Wipe" Coding Sandbox

Run the [Pi-Coding-Agent](https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent) with total peace of mind. This setup uses Podman on macOS to create an air-gapped "clean room" for your AI agent. 

## 🚀 The Three-Layer Safety Model
This architecture ensures that even a total "hallucination" by the AI cannot cause permanent data loss.

1.  **Layer 1: The Project (The Sandbox):** The agent works here. It can write code and run builds, but it is physically trapped in this folder.
2.  **Layer 2: The Vault (The Local Safe):** A hidden, bare Git repository at `~/.pi/vaults/`. The agent **cannot** see or touch this. Every session starts and ends with an automatic backup to this safe.
3.  **Layer 3: GitHub (The Cloud Vault):** Your original remote. The agent's connection to this is "Ghosted" (removed) while it's working, making it impossible for the AI to push code or delete remote branches.

## 🏗️ Architecture
*   **The Sandbox (Podman):** A Linux container containing Node:20-slim & Pi-Coding-Agent with no access to your host system files.
*   **The Guard (Node.js):** A wrapper script (`pi-podman`) that manages snapshots, ghosting, and disaster recovery.
*   **The Bridge (Node.js):** A utility (`pi-sync`) that allows you to squirrel away vault data to GitHub in real-time.

## 🛠️ Setup

### 1. Prerequisites
Ensure you have the following installed on your host system:
*   **Podman:** [Install Podman](https://podman.io/docs/installation) (on macOS, run `brew install podman`)
*   **Git:** For version control and vaulting.
*   **Ollama:** To access the AGENT/LLM.
*   **Node.js:** To run Pi-Podman scripts.

### 2. Build the Image
The Node.js 20 environment for the agent is contained entirely within this sandbox image.
```bash
podman build -t pi-coding-agent-image -f Dockerfile .
```

> [!TIP]
> **Updating the Agent:** If you see an "Update Available" message in your terminal during a session, you must rebuild the image using the command above to apply the update. Running the suggested `npm install` command inside the session will not persist.

### 3. Install the CLI Tools
The wrapper scripts (`pi-podman` and `pi-sync`) require **Node.js** on your host system.

Make the scripts executable and link them globally:
```bash
chmod +x pi-podman pi-sync
sudo ln -s "$PWD/pi-podman" /usr/local/bin/pi-podman
sudo ln -s "$PWD/pi-sync" /usr/local/bin/pi-sync
```

## ⌨️ Usage

### Start a Session
Go to any project folder and run:
```bash
pi-podman "Refactor the login logic"
```
*The script will automatically start Podman, ghost your remotes, and back up your code to the Vault.*

### Real-Time "Squirreling" (Cloud Sync)
To back up the agent's work to GitHub **without stopping the session**, open a second terminal and run:
```bash
pi-sync "Milestone: Finished refactoring login"
```
*This pushes the current Vault state to GitHub via a "backdoor" the agent cannot see. This makes it easy to track milestones in your GitHub history without interrupting the agent's session. If you don't provide a message, it will simply push the latest snapshot.*

### Key Defenses
*   **Ghosting:** ALL git remotes are removed during the session. The AI never sees your GitHub URLs.
*   **Air-Gap:** The Vault folder is not mounted into Podman. The AI cannot delete your local backups.
*   **Disaster Recovery:** If the agent deletes your `.git` folder, `pi-podman` will automatically restore it from the Vault upon exit.
*   **Privilege Isolation:** The container runs with `--security-opt no-new-privileges`.

### Maintenance
Run `./podman-cleanup.sh` to reclaim disk space from old images, dangling volumes, and orphaned vaults.

📄 *Keep your code safe and your agents productive.*
