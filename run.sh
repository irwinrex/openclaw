#!/bin/bash
# OpenClaw Runner Script - User chooses Docker or Podman

set -e

PROJECT_NAME="openclaw"
COMPOSE_FILE="docker-compose.yml"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

wait_for_health() {
    local service=$1
    local url=$2
    local max_attempts=${3:-30}
    local attempt=1
    
    echo -n "  Waiting for $service..."
    while [ $attempt -le $max_attempts ]; do
        if curl -sf "$url" >/dev/null 2>&1; then
            echo -e " ${GREEN}✓${NC}"
            return 0
        fi
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    echo -e " ${RED}✗${NC} Timeout waiting for $service"
    return 1
}

install_podman() {
    log_step "Installing Podman..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            log_info "Installing Podman via Homebrew..."
            brew install podman
            log_info "Initializing Podman machine..."
            podman machine init
            podman machine start
        else
            log_error "Homebrew not found. Install Homebrew first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            log_info "Installing Podman via apt..."
            sudo apt-get update
            sudo apt-get install -y podman
        elif command -v dnf &> /dev/null; then
            log_info "Installing Podman via dnf..."
            sudo dnf install -y podman
        elif command -v yum &> /dev/null; then
            log_info "Installing Podman via yum..."
            sudo yum install -y podman
        else
            log_error "Unsupported package manager. Install Podman manually."
            exit 1
        fi
    else
        log_error "Unsupported OS. Install Podman manually from: https://podman.io/getting-started/installation"
        exit 1
    fi

    log_info "Podman installed successfully!"
}

detect_runtime() {
    RUNTIME=""
    COMPOSE_FILE="docker-compose.yml"

    if command -v podman &> /dev/null; then
        RUNTIME="podman"
        COMPOSE_FILE="podman-compose.yml"
        if podman compose version &> /dev/null; then
            COMPOSE_CMD="podman compose"
        else
            COMPOSE_CMD="podman-compose"
        fi
    elif command -v docker &> /dev/null; then
        RUNTIME="docker"
        COMPOSE_FILE="docker-compose.yml"
        COMPOSE_CMD="docker compose"
    fi
}

choose_runtime() {
    if [ -n "$RUNTIME" ]; then
        case "$RUNTIME" in
            podman)
                COMPOSE_FILE="podman-compose.yml"
                if podman compose version &> /dev/null; then
                    COMPOSE_CMD="podman compose"
                else
                    COMPOSE_CMD="podman-compose"
                fi
                log_info "Using Podman"
                ;;
            docker)
                COMPOSE_FILE="docker-compose.yml"
                COMPOSE_CMD="docker compose"
                log_info "Using Docker"
                ;;
        esac
        return
    fi

    if command -v podman &> /dev/null; then
        RUNTIME="podman"
        COMPOSE_FILE="podman-compose.yml"
        if podman compose version &> /dev/null; then
            COMPOSE_CMD="podman compose"
        else
            COMPOSE_CMD="podman-compose"
        fi
        log_info "Using Podman (auto-detected)"
        return
    elif command -v docker &> /dev/null; then
        RUNTIME="docker"
        COMPOSE_FILE="docker-compose.yml"
        COMPOSE_CMD="docker compose"
        log_info "Using Docker (auto-detected)"
        return
    fi

    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     Choose Container Runtime             ║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   1) Podman (Recommended - Free, native)"
    echo -e "${CYAN}║${NC}   2) Docker (Requires installation)"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
    echo ""

    read -p "Enter your choice [1-2]: " choice

    case $choice in
        1)
            if command -v podman &> /dev/null; then
                RUNTIME="podman"
                COMPOSE_FILE="podman-compose.yml"
                if podman compose version &> /dev/null; then
                    COMPOSE_CMD="podman compose"
                else
                    COMPOSE_CMD="podman-compose"
                fi
                log_info "Using Podman"
            else
                log_warn "Podman not installed"
                read -p "Install Podman now? [y/n]: " install_choice
                if [[ "$install_choice" == "y" || "$install_choice" == "Y" ]]; then
                    install_podman
                    RUNTIME="podman"
                    COMPOSE_FILE="podman-compose.yml"
                    if podman compose version &> /dev/null; then
                        COMPOSE_CMD="podman compose"
                    else
                        COMPOSE_CMD="podman-compose"
                    fi
                else
                    log_error "Podman is required to run OpenClaw"
                    exit 1
                fi
            fi
            ;;
        2)
            if command -v docker &> /dev/null; then
                RUNTIME="docker"
                COMPOSE_FILE="docker-compose.yml"
                COMPOSE_CMD="docker compose"
                log_info "Using Docker"
            else
                log_error "Docker is not installed!"
                echo ""
                echo -e "${YELLOW}Please install Docker Desktop:${NC}"
                echo "  macOS:  https://www.docker.com/products/docker-desktop"
                echo "  Linux:  https://docs.docker.com/engine/install/"
                echo ""
                exit 1
            fi
            ;;
        *)
            log_error "Invalid choice. Please enter 1 or 2"
            exit 1
            ;;
    esac

    echo ""
    log_info "Runtime: $RUNTIME"
    log_info "Config: $COMPOSE_FILE"
    echo ""
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

require_runtime() {
    if [ -z "$RUNTIME" ]; then
        choose_runtime
    else
        choose_runtime
    fi
}

case "${1:-help}" in
    start|install)
        detect_runtime
        require_runtime
        check_env
        log_info "Building custom Ollama image..."
        podman build -t openclaw-ollama:latest -f ollama.Dockerfile . 2>/dev/null || log_warn "Image build skipped (already exists)"
        log_info "Pulling OpenClaw image..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" pull openclaw
        log_info "Starting services..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" up -d
        
        wait_for_health "Ollama" "http://localhost:11434/api/tags" 60
        
        log_info "Pulling Gemma 4 (8B) model to Ollama..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" exec -T ollama ollama pull gemma4:8b 2>&1 || log_warn "Model pull may take time, continuing..."
        
        wait_for_health "OpenClaw" "http://localhost:18789/healthz" 30
        
        log_info "Configuring Ollama as OpenClaw provider..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" exec -T openclaw sh -c 'openclaw onboard --non-interactive --auth-choice ollama --custom-base-url "http://ollama:11434" --accept-risk' 2>/dev/null || true
        $COMPOSE_CMD -f "$COMPOSE_FILE" exec -T openclaw sh -c 'openclaw config set gateway.bind lan' 2>/dev/null || true
        $COMPOSE_CMD -f "$COMPOSE_FILE" exec -T openclaw sh -c "openclaw config set agents.defaults.model '{\"primary\": \"ollama/gemma4:8b\"}'" 2>/dev/null || true
        log_info "Restarting OpenClaw..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" restart openclaw
        sleep 5
        log_info "OpenClaw started!"
        log_info "Gateway: http://localhost:18789"
        log_info "Ollama: http://localhost:11434"
        log_info "Model: ollama/gemma4:8b"
        ;;
    down|stop)
        detect_runtime
        require_runtime
        log_info "Stopping OpenClaw..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" down
        ;;
    restart)
        detect_runtime
        require_runtime
        $0 down
        sleep 1
        $0 start
        ;;
    logs)
        detect_runtime
        require_runtime
        $COMPOSE_CMD -f "$COMPOSE_FILE" logs -f
        ;;
    status|ps)
        detect_runtime
        require_runtime
        echo ""
        echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║         OpenClaw Status               ║${NC}"
        echo -e "${CYAN}╠══════════════════════════════════════════╣${NC}"
        echo ""
        $COMPOSE_CMD -f "$COMPOSE_FILE" ps
        echo ""
        echo -e "${CYAN}╠══════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║         Health Checks                   ║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
        echo ""
        
        # Check Ollama
        if curl -sf http://localhost:11434/api/tags >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} Ollama (localhost:11434)    - Running"
        else
            echo -e "  ${RED}✗${NC} Ollama (localhost:11434)    - Not responding"
        fi
        
        # Check OpenClaw
        if curl -sf http://localhost:18789/healthz >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} OpenClaw (localhost:18789)  - Running"
        else
            echo -e "  ${RED}✗${NC} OpenClaw (localhost:18789)  - Not responding"
        fi
        
        echo ""
        ;;
    build)
        detect_runtime
        require_runtime
        log_info "Pulling OpenClaw image..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" pull
        ;;
    clean)
        detect_runtime
        require_runtime
        log_warn "Cleaning up..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" down -v --remove-orphans 2>/dev/null || true
        ;;
    pull)
        detect_runtime
        require_runtime
        log_info "Pulling images..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" pull
        ;;
    choose)
        choose_runtime
        echo ""
        log_info "Runtime set to: $RUNTIME"
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
        echo -e "${CYAN}║${NC}  ${GREEN}./run.sh choose${NC}   Choose runtime (podman/docker)"
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