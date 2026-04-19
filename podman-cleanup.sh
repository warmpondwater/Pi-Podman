#!/bin/bash

# Podman Cleanup Utility for macOS/Linux
# This script helps reclaim disk space used by Podman.
# There may be 1.2GB being used by both Pi-Code-Agent and Node:20-slim
echo "--- 🛡️ Starting Podman Cleanup ---"

# 1. Start Podman machine if not running (macOS specific)
if [[ "$OSTYPE" == "darwin"* ]]; then
  if ! podman machine status 2>/dev/null | grep -q "Running"; then
    echo "🚀 Starting Podman machine..."
    podman machine start
    # Wait a moment for the socket to become available
    sleep 2
  fi
fi

# 2. Verify connection
if ! podman system info >/dev/null 2>&1; then
    echo "❌ Error: Could not connect to Podman. Please ensure the machine is running."
    exit 1
fi

# 3. Show current disk usage
echo "📊 Current Podman Disk Usage:"
podman system df

# 2. Prune Stopped Containers
echo -e "\n🧹 Removing stopped containers..."
podman container prune -f

# 3. Prune Dangling Images (Unnamed build artifacts)
echo -e "\n🖼️ Removing dangling images (unnamed builds)..."
podman image prune -f

# 4. Prune Unused Networks and Volumes
echo -e "\n🌐 Removing unused networks and volumes..."
podman network prune -f
podman volume prune -f

# 5. Optional: Prune ALL Unused Images (even those with names)
# Uncomment the line below if you want to remove all images not currently used by a container
# echo -e "\n🔥 Removing ALL unused images..."
# podman image prune -a -f

# 6. macOS Specific: Podman Machine Status & Disk Usage
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "\n🍎 macOS Detected: Checking Podman Machine..."
    
    # Check if a machine exists
    if podman machine list | grep -q "podman-machine-default"; then
        echo "Machine 'podman-machine-default' found."
        
        # Display VM disk usage (this is where the space is actually taken on your Mac)
        podman machine inspect --format '{{.ConfigDir.Path}}' | xargs ls -lh
        
        echo -e "\n💡 TIP: If 'podman system df' shows low usage but your Mac is still full,"
        echo "   the Podman VM disk file may have grown and won't shrink automatically."
        echo "   To truly reclaim space, you may need to recreate the machine:"
        echo "   'podman machine stop && podman machine rm && podman machine init && podman machine start'"
    else
        echo "No default Podman machine found."
    fi
fi

echo -e "\n✅ Cleanup Complete!"

# 7. Vault Audit (Orphaned Backups)
VAULT_ROOT="$HOME/.pi/vaults"
if [ -d "$VAULT_ROOT" ]; then
    echo -e "\n📦 --- 🏺 Starting Vault Audit ---"
    echo "Checking for orphaned vaults (projects that no longer exist)..."
    
    # Find all .git directories in the vault root
    for vault in "$VAULT_ROOT"/*.git; do
        [ -e "$vault" ] || continue
        
        path_file="$vault/project_path.txt"
        if [ -f "$path_file" ]; then
            original_path=$(cat "$path_file")
            if [ ! -d "$original_path" ]; then
                echo "⚠️  Orphaned Vault: $(basename "$vault")"
                echo "   Original path was: $original_path (Not Found)"
                # To be safe, we don't auto-delete. We just warn or could prompt.
                echo "   TIP: Run 'rm -rf \"$vault\"' to reclaim space."
            fi
        else
            echo "❓ Unknown Vault: $(basename "$vault") (No path tracking info)"
        fi
    done
fi

echo -e "\n📊 Final Podman Disk Usage:"
podman system df
