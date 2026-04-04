#!/bin/bash
# OpenClaw Runner Script - Auto-detects Docker or Podman

set -e

PROJECT_NAME="openclaw"
COMPOSE_FILE="docker-compose.yml"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

detect_runtime() {
    if command -v podman &> /dev/null; then
        RUNTIME="podman"
        COMPOSE_FILE="podman-compose.yml"
        if podman compose version &> /dev/null; then
            COMPOSE_CMD="podman compose"
        else
            COMPOSE_CMD="podman-compose"
        fi
        log_info "Detected: Podman"
    elif command -v docker &> /dev/null; then
        RUNTIME="docker"
        COMPOSE_FILE="docker-compose.yml"
        COMPOSE_CMD="docker-compose"
        log_info "Detected: Docker"
    else
        log_error "Neither Docker nor Podman found!"
        exit 1
    fi
}

check_env() {
    if [ ! -f .env ]; then
        if [ -f .env.example ]; then
            cp .env.example .env
            log_warn ".env created from .env.example"
            log_warn "Edit .env with your API keys"
        fi
    fi
}

case "${1:-help}" in
    start|install)
        detect_runtime
        check_env
        log_info "Building OpenClaw..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" build
        log_info "Starting OpenClaw..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" up -d
        log_info "OpenClaw started!"
        log_info "Access: http://localhost:80"
        ;;
    down|stop)
        detect_runtime
        log_info "Stopping OpenClaw..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" down
        ;;
    restart)
        detect_runtime
        $0 down
        sleep 1
        $0 start
        ;;
    logs)
        detect_runtime
        $COMPOSE_CMD -f "$COMPOSE_FILE" logs -f
        ;;
    status|ps)
        detect_runtime
        $COMPOSE_CMD -f "$COMPOSE_FILE" ps
        ;;
    build)
        detect_runtime
        log_info "Building OpenClaw..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" build
        ;;
    clean)
        detect_runtime
        log_warn "Cleaning up..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" down -v --remove-orphans 2>/dev/null || true
        ;;
    pull)
        detect_runtime
        log_info "Pulling images..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" pull
        ;;
    help|--help|-h|"")
        echo ""
        echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║         OpenClaw Runner Help          ║${NC}"
        echo -e "${CYAN}╠══════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  ${GREEN}./run.sh start${NC}    Build & Start"
        echo -e "${CYAN}║${NC}  ${GREEN}./run.sh down${NC}     Stop OpenClaw"
        echo -e "${CYAN}║${NC}  ${GREEN}./run.sh restart${NC}  Restart"
        echo -e "${CYAN}║${NC}  ${GREEN}./run.sh logs${NC}     View logs"
        echo -e "${CYAN}║${NC}  ${GREEN}./run.sh status${NC}  Show status"
        echo -e "${CYAN}║${NC}  ${GREEN}./run.sh build${NC}    Build image"
        echo -e "${CYAN}║${NC}  ${GREEN}./run.sh clean${NC}    Clean volumes"
        echo -e "${CYAN}║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
        echo ""
        ;;
    *)
        log_error "Unknown command: $1"
        $0 help
        exit 1
        ;;
esac
