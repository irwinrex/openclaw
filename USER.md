# USER.md - OpenClaw Personas & DX

## 👤 The User Profile

### The Privacy Advocate (Home User)
- **Goal**: Run a private AI assistant without cloud dependencies.
- **Needs**: Simple installation, local model support (Ollama), and a clear UI.

### The Full-Stack Developer
- **Goal**: Integrate AI into their own applications via a unified API.
- **Needs**: Standardized WebSocket/REST interface, MCP support for tool calling, and stable endpoints.

### The SysAdmin / DevOps Engineer
- **Goal**: Deploy a secure, scalable AI gateway for a team.
- **Needs**: Infrastructure-as-Code (Compose), resource limits, health checks, and observability.

---

## 🛠️ Developer Experience (DX)

OpenClaw is designed with a "Developer First" mindset:
- **Consistent Tooling**: A single `run.sh` script manages the entire lifecycle across Docker and Podman.
- **Transparent Config**: Environment-based configuration combined with a powerful runtime CLI.
- **Standardized API**: Unified model access regardless of the underlying provider (OpenAI, Google, etc.).
- **Diagnostic-Ready**: Built-in `doctor` and `healthz` endpoints for rapid debugging.

---

## 🤝 Contributor Profile

We welcome contributors who value:
1. **Security**: Understanding of zero-trust and secure coding practices.
2. **Performance**: Ability to optimize Node.js applications and container resource usage.
3. **Documentation**: Commitment to keeping READMEs and Playbooks in sync with code changes.
4. **Reliability**: A "Verification-First" approach to new features.

### Contribution Workflow
1. **Fork & Branch**: Create a feature branch from `main`.
2. **Implement & Test**: Verify changes manually or with scripts.
3. **Update Docs**: Ensure `SOUL.md` and `PLAYBOOK.md` reflect any logic changes.
4. **PR Review**: Submit for review, ensuring the "Definition of Done" in `GEMINI.md` is met.

---

## 🎯 Success Criteria

- **Zero-Touch Setup**: `./run.sh start` works out of the box with minimal configuration.
- **High Availability**: Containers restart automatically on failure.
- **Secure by Default**: External access requires explicit token authentication.
- **Predictable Performance**: Model inference stays within defined memory limits.