# 🛡️ OpenClaw - Production-Grade Secure AI Gateway

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Self-Hosted](https://img.shields.io/badge/Self--Hosted-Yes-blue)](https://openclaw.ai)
[![Ollama Support](https://img.shields.io/badge/Ollama-Native-green)](https://ollama.ai)
[![MCP Ready](https://img.shields.io/badge/MCP-Supported-orange)](https://modelcontextprotocol.io)

OpenClaw is a secure, high-performance, and self-hosted AI gateway designed for privacy-conscious developers and organizations. It acts as a unified interface for 50+ AI providers (including Google Gemini, OpenAI, and Anthropic) and supports the **Model Context Protocol (MCP)** for advanced agentic tool-calling.

---

## 🚀 Why OpenClaw?

- **Privacy First**: Absolute control over data residency. Your data stays in your infrastructure.
- **Universal LLM Access**: A single API to rule them all. Switch between 50+ cloud providers or local models with one config change.
- **Local Model Native**: Pre-configured support for **Gemma 4 (8B)** and other models via local Ollama integration.
- **Production-Ready**: Built for reliability with Docker/Podman orchestration, health checks, and resource limits.
- **Agentic Workflows**: Native MCP support enables complex reasoning and tool calling out of the box.

---

## 🏗️ Architecture Overview

OpenClaw follows a modular, containerized architecture:

1. **OpenClaw Gateway**: Node.js service (Port 18789) handling WebSocket orchestration, provider routing, and session management.
2. **Model Engine**: Integrated **Ollama** (Port 11434) for running high-performance local LLMs.
3. **Orchestration**: Unified `run.sh` script managing the lifecycle across Docker and Podman.
4. **Data Persistence**: Persistent storage volumes for configuration, agent state, and model weights.

---

## ⚡ Quick Start

```bash
# 1. Prepare environment
cp .env.example .env

# 2. Add your GOOGLE_API_KEY to .env

# 3. Launch services
./run.sh start

# 4. Verify Health
curl http://localhost:18789/healthz
```

---

## 🛠️ Essential Commands

| Command | Action |
|---------|--------|
| `./run.sh start` | Orchestrate and start services |
| `./run.sh status` | Show current service health |
| `./run.sh logs` | Aggregated log stream |
| `./run.sh exec <cmd>` | Execute a command inside the container |
| `./run.sh clean` | Full reset (Wipes volumes) |

---

## 🛡️ Security Best Practices

- **Auth**: Set a secure `OPENCLAW_GATEWAY_TOKEN` in `.env`.
- **Least Privilege**: Containers run with `no-new-privileges` and limited resources (4GB default).
- **Network**: By default, the gateway binds to `loopback`. Use `lan` only for external access.

---

## 🤝 Contributing

We value engineering excellence! Please refer to [USER.md](./USER.md) for contributor guidelines and [GEMINI.md](./GEMINI.md) for our Definition of Done.

## 📄 License

OpenClaw is open-source software licensed under the **MIT License**.