# CONTRIBUTING.md - Developer Guide

We are thrilled that you're interested in contributing to OpenClaw! As a production-grade AI gateway, we value engineering excellence, security, and clear documentation.

## 🛠️ Local Development Setup

1. **Environment**:
   - Ensure you have Docker or Podman installed.
   - Node.js (v20+) is recommended for local scripting, though most work is container-based.
2. **Bootstrap**:
   ```bash
   cp .env.example .env
   # Add your API keys for testing
   ```
3. **Execution**:
   ```bash
   ./run.sh start
   ```

## 📐 Engineering Standards

- **Clean Code**: Follow the DRY and KISS principles outlined in [SOUL.md](./SOUL.md).
- **Surgical Updates**: When modifying existing code, keep your changes focused and minimal.
- **Security**: Never introduce code that logs sensitive data or bypasses authentication.
- **Verification**: Every PR must include a description of how the changes were verified.

## 🤝 Branching Strategy

- **main**: The stable, production-ready branch.
- **feature/<name>**: For new features or significant improvements.
- **fix/<name>**: For bug fixes.
- **docs/<name>**: For documentation-only updates.

## 📝 Pull Request Process

1. **Verify**: Run `openclaw doctor` inside the container to ensure your changes didn't break core configuration.
2. **Document**: Update `PLAYBOOK.md` or `MEMORY.md` if your change introduces new operations or architectural decisions.
3. **Check DoD**: Ensure your PR meets the **Definition of Done** in [GEMINI.md](./GEMINI.md).
4. **Submit**: Provide a clear, concise description of your changes and why they are necessary.

## 🤖 AI-Assisted Contributions

If you are using an AI agent (like Gemini CLI) to contribute:
- Ensure the agent has read [SOUL.md](./SOUL.md) and [GEMINI.md](./GEMINI.md).
- The agent must verify its changes using the project's orchestration tools.
- Never let the AI commit or push without explicit review.

## 📄 Code of Conduct

Be respectful, professional, and focus on technical excellence. We value diverse perspectives and collaborative problem-solving.
