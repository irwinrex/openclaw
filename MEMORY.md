# MEMORY.md - Project History & ADRs

## 🧠 Project Context
OpenClaw is an evolving AI gateway. This file serves as the long-term memory for architectural decisions, lessons learned, and the future roadmap.

---

## 🏗️ Architecture Decision Records (ADRs)

### ADR 001: Unified Orchestration via `run.sh`
- **Context**: Users have varied preferences for Docker vs. Podman.
- **Decision**: Implement a unified `run.sh` script that auto-detects the runtime and provides a consistent CLI across environments.
- **Impact**: Simplified DX; users don't need to know which container engine is running.

### ADR 002: Local Model Defaults (Gemma 4 8B)
- **Context**: A self-hosted gateway needs a high-quality local model for offline use.
- **Decision**: Standardize on **Gemma 4 (8B)** via Ollama due to its balance of performance and resource requirements (12GB+ RAM).
- **Impact**: Provides a robust out-of-the-box experience for private AI.

### ADR 003: Privacy-First Bound (Loopback by default)
- **Context**: Security of AI interactions is paramount.
- **Decision**: Gateway binds to `127.0.0.1` by default. External access requires explicit configuration (`gateway.bind: lan`).
- **Impact**: Prevents accidental exposure of the AI gateway to the public internet.

---

## 📅 Roadmap

### Q2 2026: Performance & Scale
- [ ] Optimize container startup times.
- [ ] Implement advanced caching for provider model lists.
- [ ] Add support for multiple Ollama backends (Horizontal scaling).

### Q3 2026: Advanced Agentics
- [ ] Deepen MCP integration for file-system and git tools.
- [ ] Implement built-in "Canvas" for collaborative AI coding.
- [ ] Add support for vision-based models (Ollama/API).

### Q4 2026: Enterprise Readiness
- [ ] Role-Based Access Control (RBAC) for the gateway.
- [ ] Detailed audit logs and request tracing (OpenTelemetry).
- [ ] Native support for Kubernetes (Helm/Kustomize).

---

## 🎓 Lessons Learned
- **Volume Persistence**: Ensure that `.openclaw` directory is consistently mapped across all compose files to prevent state loss during restarts.
- **Resource Limits**: 4GB for the gateway is plenty, but Ollama requires careful tuning depending on the model size (Gemma 4 8B needs 12GB+ for smooth inference).
