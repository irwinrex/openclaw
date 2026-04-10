# PLAYBOOK.md - OpenClaw Operational Excellence (Gemma 4 8B)

## 🚀 Rapid Deployment

```bash
# Bootstrap environment
cp .env.example .env
# Edit .env with OPENCLAW_GATEWAY_TOKEN

# Orchestrate services
./run.sh start

# Verify Readiness
./run.sh status
curl -f http://localhost:18789/healthz || echo "Deployment failed"
```

---

## 🛠️ Core Operations

### Runtime Introspection
Access the containerized environment for deep diagnostics.

```bash
# Interactive Shell
./run.sh exec sh

# Log Aggregation (Follow)
./run.sh logs -f

# Resource Monitoring
podman stats openclaw-openclaw-1
```

### Advanced Configuration (CLI)
Configure the gateway and agents at runtime.

```bash
# Set Gateway mode & bind
./run.sh exec openclaw config set gateway.mode local
./run.sh exec openclaw config set gateway.bind lan

# Security: Rotate Gateway Token
./run.sh exec openclaw config set gateway.auth.token "NEW_SECURE_TOKEN"

# Model Selection
./run.sh exec openclaw config set agents.defaults.model '{"primary": "ollama/gemma4:8b"}'
```

### Provider Onboarding (Auth)
```bash
# Interactive Onboarding (Recommended for first setup)
./run.sh exec openclaw onboard

# Non-Interactive (CI/CD / Automation)
./run.sh exec openclaw onboard --non-interactive \
  --accept-risk \
  --auth-choice ollama \
  --custom-base-url "http://ollama:11434"
```

---

## 🛡️ Security Hardening

- **Runtime Constraints**: Use `no-new-privileges` and `security_opt` (enabled by default in compose).
- **Network Isolation**: Ensure `gateway.bind` is only set to `lan` if necessary. Default is `loopback` for maximum security.
- **Secrets Management**: Rotate `OPENCLAW_GATEWAY_TOKEN` quarterly.
- **Audit**: Regularly inspect `auth-profiles.json` for unauthorized provider entries.

---

## 📊 Observability & QA

### Health Diagnostics
```bash
# Application-level check
curl http://localhost:18789/healthz

# Integrated Doctor (Diagnostic Suite)
./run.sh exec openclaw doctor

# Log Inspection for Errors
./run.sh logs | grep -iE "error|warn|fail"
```

### Performance Benchmarking
Monitor request latency and memory usage during heavy model inference.

```bash
# Check container memory consumption
podman stats --no-stream openclaw-openclaw-1
```

---

## 💾 Backup & Disaster Recovery (DR)

### Backup State
```bash
# Create a snapshot of current configuration and agent state
./run.sh exec openclaw backup create

# List backups
./run.sh exec ls -lh /home/node/.openclaw/backups
```

### Restore / Disaster Recovery
```bash
# Clean reset (Wipes volumes, use with caution)
./run.sh clean
./run.sh start

# Restore from backup (Implementation dependent on openclaw CLI version)
# ./run.sh exec openclaw backup restore <backup-id>
```

---

## 🔧 Troubleshooting

| Symptom | Root Cause | Resolution |
|---------|------------|------------|
| `Connection Refused` | Gateway not bound to correct IP | Check `gateway.bind` and `gateway.port` |
| `401 Unauthorized` | Invalid Gateway Token | Verify `OPENCLAW_GATEWAY_TOKEN` in `.env` |
| `Model Not Found` | Auth failure or scan missing | Run `openclaw onboard` and `openclaw models scan` |
| `OOMKilled` | Insufficient memory limits | Increase `mem_limit` in compose files |

---

## 🔄 Maintenance Cycle

1. **Daily**: Monitor logs for anomalies.
2. **Weekly**: Check for model updates (`openclaw models scan`).
3. **Monthly**: Pull latest images (`./run.sh pull`) and restart services.
4. **Quarterly**: Audit configuration and rotate secrets.