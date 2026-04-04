# ============================================================
# Secure OpenClaw Dockerfile — Production-Hardened
# Based on: https://github.com/openclaw/openclaw
# ============================================================

# ── Pinned base images (digest-locked for supply-chain safety) ──────────────
ARG OPENCLAW_NODE_BOOKWORM_IMAGE="node:24-bookworm@sha256:3a09aa6354567619221ef6c45a5051b671f953f0a1924d1f819ffb236e520e6b"
ARG OPENCLAW_NODE_BOOKWORM_SLIM_IMAGE="node:24-bookworm-slim@sha256:e8e2e91b1378f83c5b2dd15f0247f34110e2fe895f6ca7719dbb780f929368eb"

# ── Build-time arguments ─────────────────────────────────────────────────────
ARG OPENCLAW_BUNDLED_PLUGIN_DIR=".plugins"
ARG OPENCLAW_INSTALL_DOCKER_CLI=0
ARG OPENCLAW_DOCKER_APT_PACKAGES=""


# ════════════════════════════════════════════════════════════
# Stage 1: Base — shared toolchain setup
# ════════════════════════════════════════════════════════════
FROM ${OPENCLAW_NODE_BOOKWORM_IMAGE} AS base

# Install security patches and minimal deps only; no extras
RUN apt-get update && \
  apt-get upgrade -y --no-install-recommends && \
  apt-get install -y --no-install-recommends \
  ca-certificates \
  dumb-init && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Bun with retry logic; verify it landed
RUN curl --version | grep -q "curl" && \
  curl --retry 5 --retry-all-errors --retry-delay 2 -fsSL https://bun.sh/install | bash && \
  echo "Bun installed OK" || { echo "Bun install failed" >&2; exit 1; }
ENV PATH="/root/.bun/bin:${PATH}"

# Enable corepack (pnpm) and activate the version declared in package.json
RUN corepack enable && \
  corepack prepare --activate 2>/dev/null || true

WORKDIR /app


# ════════════════════════════════════════════════════════════
# Stage 2: Build — compile source; never ships to runtime
# ════════════════════════════════════════════════════════════
FROM base AS builder

# Copy only manifests first → layer-cached unless lockfile changes
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY ui/package.json ./ui/package.json
COPY scripts ./scripts

# Frozen install: fails on lockfile drift (prevents silent dep upgrades)
RUN pnpm install --frozen-lockfile

# Copy the rest of the source and compile
COPY . .
RUN pnpm build && \
  pnpm ui:install && \
  pnpm ui:build

# Strip source maps and type declarations to reduce attack surface
RUN find dist -type f \( \
  -name '*.d.ts' \
  -o -name '*.d.mts' \
  -o -name '*.d.cts' \
  -o -name '*.map' \
  \) -delete


# ════════════════════════════════════════════════════════════
# Stage 3: Runtime assets — only what the gateway needs
# ════════════════════════════════════════════════════════════
FROM builder AS runtime-assets

# Nothing extra — just a named alias for the COPY --from targets below


# ════════════════════════════════════════════════════════════
# Stage 4: Final — minimal, non-root, hardened runtime image
# ════════════════════════════════════════════════════════════
FROM ${OPENCLAW_NODE_BOOKWORM_SLIM_IMAGE} AS final

# ── Maintainer ──────────────────────────────────────────────
LABEL maintainer="IRWINREX"

# Re-declare ARGs (ARGs don't cross stage boundaries)
ARG OPENCLAW_BUNDLED_PLUGIN_DIR=".plugins"
ARG OPENCLAW_INSTALL_DOCKER_CLI=0
ARG OPENCLAW_DOCKER_APT_PACKAGES=""

# ── Security: apply OS updates, install minimal runtime deps ────────────────
RUN apt-get update && \
  apt-get upgrade -y --no-install-recommends && \
  apt-get install -y --no-install-recommends \
  ca-certificates \
  dumb-init && \
  # Optionally install Docker CLI for sandbox isolation
  if [ "${OPENCLAW_INSTALL_DOCKER_CLI}" = "1" ]; then \
  apt-get install -y --no-install-recommends docker.io; \
  fi && \
  # Install any user-supplied APT packages (baked in, not at startup)
  if [ -n "${OPENCLAW_DOCKER_APT_PACKAGES}" ]; then \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  ${OPENCLAW_DOCKER_APT_PACKAGES}; \
  fi && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

# ── Copy only compiled artefacts; chown to non-root 'node' user ─────────────
COPY --from=runtime-assets --chown=node:node /app/dist                        ./dist
COPY --from=runtime-assets --chown=node:node /app/node_modules                ./node_modules
COPY --from=runtime-assets --chown=node:node /app/package.json                ./package.json
COPY --from=runtime-assets --chown=node:node /app/${OPENCLAW_BUNDLED_PLUGIN_DIR} ./${OPENCLAW_BUNDLED_PLUGIN_DIR}
COPY --from=runtime-assets --chown=node:node /app/skills                      ./skills
COPY --from=runtime-assets --chown=node:node /app/docs                        ./docs

# ── Drop to non-root for all subsequent instructions ────────────────────────
USER node

# ── Runtime environment ──────────────────────────────────────────────────────
ENV NODE_ENV=production \
  HOME=/home/node \
  TERM=xterm-256color \
  NODE_OPTIONS="--max-old-space-size=512 --enable-source-maps=off"

# ── Health check — liveness probe via the gateway's /healthz endpoint ────────
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=5 \
  CMD node -e \
  "fetch('http://127.0.0.1:18789/healthz').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

# ── Expose only the ports the gateway actually uses ──────────────────────────
EXPOSE 18789
EXPOSE 18790

# ── Use dumb-init as PID 1 to handle signals correctly ──────────────────────
# This ensures graceful shutdown and prevents zombie processes
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# ── Default command: run the gateway in production mode ─────────────────────
CMD ["node", "dist/index.js", "gateway", "--bind", "lan", "--port", "18789"]

# ── Security: explicitly set user again as a safeguard ──────────────────────
USER node
