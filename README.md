# OpenClaw - Secure AI Gateway

Production-ready AI gateway with nginx reverse proxy, featuring security hardening and rate limiting for AI APIs (OpenAI, Anthropic, Google).

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/openclaw/main/run.sh | bash -s start
```

Or with API key:
```bash
OPENAI_API_KEY=sk-... \
ANTHROPIC_API_KEY=sk-ant-... \
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/openclaw/main/run.sh | bash -s start
```

Access at http://localhost:80

## Manual Setup

```bash
git clone <repo>
cd openclaw
cp .env.example .env
# Edit .env with your API keys
./run.sh start
```

## One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/openclaw/main/install.sh | bash
```

## Commands

| Command | Description |
|---------|-------------|
| `./run.sh start` | Build & Start |
| `./run.sh down` | Stop |
| `./run.sh restart` | Restart |
| `./run.sh logs` | View logs |
| `./run.sh status` | Show status |
| `./run.sh build` | Build image |
| `./run.sh clean` | Clean volumes |

## Environment Variables

```bash
OPENAI_API_KEY=sk-...        # OpenAI API key
ANTHROPIC_API_KEY=sk-ant-... # Anthropic API key  
GOOGLE_API_KEY=...           # Google AI API key
NODE_ENV=production          # Environment
LOG_LEVEL=info               # Log level
```

## Security Features

### Nginx Layer
- Rate limiting (10r/s general, 5r/s API, 1r/s auth)
- Prompt injection pattern blocking
- SQL injection/XSS protection
- Security headers (CSP, HSTS, X-Frame-Options, etc.)
- DDoS protection (20 conn/IP, 100 conn/server)

### Container Security
- Non-root user (nginx/node)
- `read_only: true` filesystem
- `no-new-privileges: true`
- Capability dropping (ALL except NET_BIND_SERVICE, SYS_RESOURCE)
- Resource limits (CPU/memory)

### AI-Specific
- Prompt injection detection at nginx level
- Suspicious query string blocking
- Custom CSP for AI API domains

## Endpoints

| Endpoint | Description |
|----------|-------------|
| `/` | Root (static) |
| `/health` | Health check |
| `/api/` | OpenClaw gateway (port 18789) |
| `/ws` | WebSocket support |
| `/ui/` | OpenClaw UI (port 18790) |

## Project Structure

```
.
├── docker-compose.yml    # Docker compose
├── podman-compose.yml    # Podman compose
├── Dockerfile           # OpenClaw image
├── run.sh              # Runner script
├── nginx/
│   ├── nginx.conf      # Main nginx config
│   ├── default.conf    # Server config
│   └── html/           # Error pages
├── .env.example        # Env template
├── .gitignore
└── .dockerignore
```

## Error Pages

| Code | Description |
|------|-------------|
| 400 | Bad Request |
| 403 | Access Denied |
| 404 | Not Found |
| 429 | Rate Limited |
| 444 | Security Block |
| 50x | Server Error |

## Requirements

- Docker OR Podman
- API keys for at least one AI provider

## Maintainer

**IRWINREX**

## License

MIT
