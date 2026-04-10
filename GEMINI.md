# OpenClaw - Secure AI Gateway (Gemma 4 8B)

OpenClaw is a production-grade, self-hosted AI gateway engineered for privacy, security, and low-latency orchestration. It provides a unified, zero-trust interface for 50+ AI providers and supports the Model Context Protocol (MCP) for complex agentic workflows.

## Project Vision
- **Privacy First**: Absolute control over data residency and model interactions.
- **Unified Interface**: A single API surface for all LLMs, local or cloud-based.
- **Agentic Power**: Built-in support for tools, browser automation, and multi-step reasoning.

## Engineering Standards

### 1. Code Quality & Consistency
- **Surgical Updates**: Prefer precise, context-aware changes over large, monolithic edits.
- **Idiomatic Code**: Follow the established patterns and naming conventions of the codebase.
- **No Suppression**: Never suppress linter warnings or bypass type safety (no `any` in TS, no `unsafe` without justification).

### 2. DevOps & Infrastructure
- **IaC First**: All infrastructure (Docker, Podman) must be defined as code.
- **Statelessness**: The gateway should be as stateless as possible, persisting only essential data to volumes.
- **Resource Constraints**: Always define and respect memory/CPU limits (4GB for OpenClaw, 12GB+ for Ollama).

### 3. QA & Verification (Definition of Done)
A task is considered **DONE** only when:
- [ ] Implementation satisfies the core requirement.
- [ ] Code is idiomatic, well-documented, and passes all linters/type checks.
- [ ] **Verification**: Behavioral correctness is confirmed via manual testing or automated scripts.
- [ ] **Regression**: No breaking changes introduced to existing features.
- [ ] **Documentation**: Related `.md` files (README, PLAYBOOK, SOUL) are updated if needed.

## Architecture Overview

- **Service Layer**: Node.js-based gateway (OpenClaw) on port `18789`.
- **Local Model Layer**: Ollama on port `11434` for self-hosted Gemma 4 (8B).
- **Data Layer**: Persistent storage via Docker/Podman volumes (`openclaw_data`, `ollama_data`).
- **Control Plane**: Unified `run.sh` script for orchestration across runtimes.

## Key Operational Files
- `run.sh`: Main entry point (Orchestration).
- `docker-compose.yml` / `podman-compose.yml`: Deployment definitions.
- `SOUL.md`: Agent identity and core values.
- `PLAYBOOK.md`: Operational guide and troubleshooting.
- `USER.md`: Target audience profiles and UX requirements.
- `MEMORY.md`: (NEW) Long-term project memory and ADRs.

## Initial Deployment Workflow
1. **Bootstrap**: `cp .env.example .env`
2. **Configure**: Set `OPENCLAW_GATEWAY_TOKEN`.
3. **Provision**: `./run.sh start`
4. **Onboard**: `podman exec -it openclaw-openclaw-1 openclaw onboard ...`
5. **Validate**: Check `http://localhost:18789/healthz`.

## Security Mandates
- **Credential Protection**: Never log, print, or commit API keys or secrets.
- **Least Privilege**: Containers run with `no-new-privileges` and limited resource access.
- **Audit Trails**: Maintain clear logs for all configuration changes.
