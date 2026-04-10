# TESTING.md - QA & Validation Guide

Quality Assurance is a core pillar of OpenClaw. This guide outlines how to verify the system's integrity, performance, and security.

---

## 🧪 Verification Levels

### 1. Smoke Tests (Readiness)
Verify that the services are up and responding to basic requests.

```bash
# Verify orchestration
./run.sh status

# Verify Gateway API
curl -f http://localhost:18789/healthz
```

### 2. Functional Verification
Confirm that the gateway can interact with AI providers and models.

```bash
# Check provider auth status
./run.sh exec openclaw doctor

# Verify model availability
./run.sh exec openclaw models list
```

### 3. Integration Testing (WebSocket)
OpenClaw is a WebSocket-first gateway. Test connectivity using a tool like `wscat` or a simple script.

```bash
# Example test (requires wscat)
wscat -c ws://localhost:18789 -H "Authorization: Bearer YOUR_GATEWAY_TOKEN"
```

---

## 🛡️ Security Auditing

- **Input Validation**: Attempt to send malformed JSON or excessively large payloads to the gateway.
- **Auth Enforcement**: Ensure that requests without a valid `OPENCLAW_GATEWAY_TOKEN` are rejected with a 401/403.
- **Container Isolation**: Verify that the container cannot access the host filesystem outside of the defined volumes.

---

## 📊 Performance Benchmarking

### Model Latency
Monitor the Time to First Token (TTFT) for both local and cloud models.
```bash
# Check logs for request processing time
./run.sh logs | grep "Request processed in"
```

### Resource Utilization
Ensure containers stay within their memory envelopes.
```bash
# Monitor during heavy inference
podman stats openclaw-openclaw-1
```

---

## ✅ Definition of Done (QA Perspective)

A feature is validated only if:
1. It passes all **Smoke Tests**.
2. It handles **Edge Cases** (e.g., provider timeout, invalid API key).
3. It does not regress **Security** (e.g., no new exposed ports).
4. It is documented in the **Playbook**.
