# 🛡️ Pi-Podman: The "Anti-Wipe" Coding Sandbox

> **Welcome Back!** If it's been 6 months and you've forgotten how this works, start reading here.

This project is a protective wrapper around the [Pi-Coding-Agent](https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent). AI agents are powerful, but they can hallucinate and run destructive commands (like `rm -rf` or `git push --force`). 

This setup uses **Podman** on macOS to create an air-gapped "clean room" for the AI, ensuring that **even a total hallucination cannot cause permanent data loss or cloud corruption.**

---

## 🧠 How It Works Under The Hood

When you run `pi-podman` in a project folder, here is exactly what happens behind the scenes:

1. **The Ghosting:** The script temporarily deletes all your Git remotes (`origin`, etc.). The AI never sees your GitHub URLs and therefore cannot push to them or delete your cloud branches.
2. **The Vault Backup:** The script creates a hidden, bare Git repository at `~/.pi/vaults/` (The Vault). It takes a snapshot of your code and pushes it to this Vault. The AI has **zero access** to this directory.
3. **The Sandbox (Podman):** A Linux container is launched. It mounts **only** your current project folder, blocking the AI from seeing your host system (`~`, `/Documents`, etc.). The AI runs entirely inside this isolated container.
4. **The Bridge:** While the AI works, you can open another terminal and run `pi-sync`. This bypasses the container and pushes the code from your Vault directly to GitHub, letting you safely back up milestones.
5. **Disaster Recovery:** When you close the AI session, the script wakes up. It restores your Git remotes. If the AI maliciously deleted your `.git` folder, the script automatically reconstructs it by pulling from the hidden Vault.

---

## 🛠️ Re-Commissioning Guide (Setting it up from scratch)

If you are setting this up on a new Mac or returning after a long break, follow these steps in order.

### 1. Re-install Prerequisites
Ensure you have the core tools running on your host Mac:
*   **Podman:** Runs the containers. (`brew install podman` then `podman machine init` and `podman machine start`)
*   **Node.js:** Runs the `pi-podman` wrapper scripts.
*   **Ollama:** Runs the LLMs locally on your Mac GPU.
*   **Git:** Required for the Vault system.

### 2. Configure the Agent's "Brain"
The AI running inside the container needs to know where your host's Ollama is. 
Ensure you have a configuration file at `~/.pi/agent/models.json` looking like this:

```json
{
  "defaultModel": "qwen2.5:latest",
  "defaultProvider": "ollama",
  "packages": [
    "npm:@ollama/pi-web-search",
    "npm:pi-mcp-adapter"
  ],
  "providers": {
    "ollama": {
      "baseUrl": "http://host.containers.internal:11434/v1",
      "api": "openai-completions",
      "apiKey": "ollama",
      "models": [
        { "id": "qwen2.5:latest", "reasoning": true }
      ]
    }
  }
}
```
*(Note: `host.containers.internal` is the magic URL that lets the Podman container talk to your Mac's native Ollama).*

### 3. Build the Sandbox Image
We need to bake the actual `pi-coding-agent` into a Podman image. Open a terminal in this repo's folder and run:

```bash
podman build --no-cache -t pi-coding-agent-image -f Dockerfile .
```

> [!TIP]
> **Updating the Agent:** If you see an "Update Available" message in your terminal during a session, you must close the session and run the `--no-cache` build command above. Running `npm install` inside the container won't persist!

### 4. Link the CLI Scripts
Make the local scripts executable and link them so you can run them from anywhere:

```bash
chmod +x pi-podman pi-sync
sudo ln -s "$PWD/pi-podman" /usr/local/bin/pi-podman
sudo ln -s "$PWD/pi-sync" /usr/local/bin/pi-sync
```

---

## ⌨️ Daily Usage

### Start an AI Session
Navigate to the project you want the AI to work on and run:
```bash
pi-podman "Refactor the login logic"
```

### Safely Save to Cloud
While the AI is running (or after), open a second terminal and push the work to GitHub safely:
```bash
pi-sync "Milestone: Finished refactoring login"
```

### Reclaim Disk Space
Podman eats disk space over time. If your Mac is filling up, run the included cleanup script from this repo:
```bash
./podman-cleanup.sh
```

📄 *Keep your code safe and your agents productive.*
