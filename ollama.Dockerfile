FROM ollama/ollama:latest

RUN apt-get update && apt-get install -y --no-install-recommends curl bash && rm -rf /var/lib/apt/lists/*

EXPOSE 11434

ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_KEEP_ALIVE=24h

HEALTHCHECK --interval=15s --timeout=10s --retries=5 --start-period=60s \
  CMD curl -sf http://localhost:11434/api/tags || exit 1

CMD ["serve"]