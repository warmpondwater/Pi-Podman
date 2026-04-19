# Pi Configuration Overview

To ensure the scripts in this repository function correctly, 
you must have a valid configuration directory located at $HOME/.pi/. 
This acts as the "brain" for the agent, telling the podman container
which models to use and where to find them.

## 1. Global Agent Settings File Path: $HOME/.pi/agent/models.json

This file defines your default preferences and any external packages
(like web search) that the agent should load.

```JSON
{ 
	"defaultModel": "gemma4:e4b", 
	"defaultProvider": "ollama",
	"packages":[
	"npm:@ollama/pi-web-search"
	],
	"lastChangelogVersion":"0.66.1"
} 
```

## 2. Provider & Model Definitions File Path: $HOME/.pi/agent/providers.json
(Note: In many Pi setups, provider details are often split into a
providers.json or appended to the main config. Based on your repo's
requirements, ensure the following structure is present.)

This configuration points the Pi agent to your Ollama instance,
specifically using the Podman-friendly host.containers.internal address
to bridge the container-to-host gap.

```JSON
{
 "providers":{ 
  "ollama": { 
	"baseUrl":
	 "http://host.containers.internal:11434/v1",
	 "api": "openai-completions",
	 "apiKey": "ollama",
	 "models": [
	 {"id": "gemma4:latest", "reasoning": true },
	 {"id": "gemma4:e4b", "reasoning": true },
	 {"id": "qwen2.5-coder:14b", "reasoning": true }
   ] 
  }
 }
} 
```
## Key Integration Notes
Networking: The baseUrl using host.containers.internal is critical. It allows the Pi agent running inside a Podman container to resolve the Ollama service running on your host machine.

Model IDs: Ensure the id strings match exactly what is returned by ollama list on your system.

## Reasoning:
The "reasoning": true flag enables advanced chain-of-thought processing for models that support it (like the Gemma 4 or Qwen 2.5
series).

## Pro Tip: 
If you are troubleshooting connection issues, verify that your
Ollama environment variable OLLAMA_HOST is set to 0.0.0.0 to allow
connections from the Podman network bridge.