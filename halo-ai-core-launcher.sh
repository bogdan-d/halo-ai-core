#!/bin/bash
# ============================================================
# Halo AI Core — Flatpak Launcher
# Designed and built by the architect
#
# "I'm gonna make him an offer he can't refuse." — The Godfather
#
# This wrapper copies the installer to the host and runs it.
# The Flatpak is a delivery mechanism — the real work happens
# on bare metal where it belongs.
# ============================================================

set -e

VERSION="0.9.0"
INSTALL_DIR="${HOME}/halo-ai-core"
SOURCE_DIR="/app/share/halo-ai-core"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}  ██╗  ██╗ █████╗ ██╗      ██████╗        █████╗ ██╗${NC}"
echo -e "${BLUE}  ██║  ██║██╔══██╗██║     ██╔═══██╗      ██╔══██╗██║${NC}"
echo -e "${BLUE}  ███████║███████║██║     ██║   ██║█████╗███████║██║${NC}"
echo -e "${BLUE}  ██╔══██║██╔══██║██║     ██║   ██║╚════╝██╔══██║██║${NC}"
echo -e "${BLUE}  ██║  ██║██║  ██║███████╗╚██████╔╝      ██║  ██║██║${NC}"
echo -e "${BLUE}  ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝       ╚═╝  ╚═╝╚═╝${NC}"
echo ""
echo -e "${GREEN}  Halo AI Core v${VERSION} — Flatpak Installer${NC}"
echo -e "  Designed and built by the architect"
echo ""

# Check if running inside Flatpak sandbox
if [ -f "/.flatpak-info" ]; then
    echo -e "${YELLOW}  Flatpak detected. Deploying installer to host...${NC}"
    echo ""

    # Create install directory on host filesystem
    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "  ${BLUE}Creating ${INSTALL_DIR}...${NC}"
        mkdir -p "$INSTALL_DIR"
    fi

    # Copy all files to host
    echo -e "  ${BLUE}Copying halo-ai-core files...${NC}"
    cp -r "${SOURCE_DIR}/"* "$INSTALL_DIR/"
    chmod +x "${INSTALL_DIR}/install.sh"

    echo ""
    echo -e "${GREEN}  Files deployed to: ${INSTALL_DIR}${NC}"
    echo ""
    echo -e "  ${YELLOW}The installer needs bare-metal access (pacman, systemd, ROCm).${NC}"
    echo -e "  ${YELLOW}Run the installer directly on your host:${NC}"
    echo ""
    echo -e "  ${GREEN}  cd ${INSTALL_DIR}${NC}"
    echo -e "  ${GREEN}  sudo ./install.sh${NC}"
    echo ""
    echo -e "  Or do a dry run first:"
    echo -e "  ${GREEN}  ./install.sh --dry-run${NC}"
    echo ""
    echo -e "  Pass ${GREEN}--help${NC} for all options."
    echo ""
else
    # Running outside Flatpak — execute installer directly
    echo -e "  ${BLUE}Running installer directly...${NC}"
    echo ""
    exec "${SOURCE_DIR}/install.sh" "$@"
fi
