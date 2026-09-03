#!/bin/bash

# Installation script for upsun-db-dump
# This script installs upsun-db-dump globally on your system

set -e  # Exit on error

COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_RESET='\033[0m'

INSTALL_DIR="/usr/local/bin"
COMMAND_NAME="upsun-db-dump"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "${COLOR_BLUE}╔═══════════════════════════════════════════════════════╗${COLOR_RESET}"
echo -e "${COLOR_BLUE}║                                                       ║${COLOR_RESET}"
echo -e "${COLOR_BLUE}║           💾  upsun-db-dump installer  ✨             ║${COLOR_RESET}"
echo -e "${COLOR_BLUE}║                                                       ║${COLOR_RESET}"
echo -e "${COLOR_BLUE}╚═══════════════════════════════════════════════════════╝${COLOR_RESET}"
echo ""

# Check if we need sudo
if [[ ! -w "$INSTALL_DIR" ]]; then
  echo -e "${COLOR_YELLOW}⚠️  Installing to ${INSTALL_DIR} requires elevated privileges${COLOR_RESET}"
  echo -e "   You may be prompted for your password...\n"
  USE_SUDO="sudo"
else
  USE_SUDO=""
fi

# Check if already installed
if [[ -f "${INSTALL_DIR}/${COMMAND_NAME}" ]]; then
  echo -e "${COLOR_YELLOW}⚠️  ${COMMAND_NAME} is already installed${COLOR_RESET}"
  read -p "   Do you want to reinstall/update it? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n${COLOR_BLUE}Installation cancelled.${COLOR_RESET}\n"
    exit 0
  fi
  echo ""
fi

# Install the script
echo -e "${COLOR_BLUE}📦 Installing ${COMMAND_NAME}...${COLOR_RESET}"
$USE_SUDO cp "${SCRIPT_DIR}/src/${COMMAND_NAME}" "${INSTALL_DIR}/${COMMAND_NAME}"
$USE_SUDO chmod +x "${INSTALL_DIR}/${COMMAND_NAME}"
echo -e "${COLOR_GREEN}✓ Installed to ${INSTALL_DIR}/${COMMAND_NAME}${COLOR_RESET}"
echo ""

# Warn if Upsun CLI is missing (the dump command needs it)
if ! command -v upsun >/dev/null 2>&1; then
  echo -e "${COLOR_YELLOW}⚠️  Upsun CLI not found in PATH${COLOR_RESET}"
  echo -e "   ${COMMAND_NAME} needs it to dump databases."
  echo -e "   Install: ${COLOR_BLUE}https://docs.upsun.com/administration/cli/${COLOR_RESET}"
  echo ""
fi

echo -e "${COLOR_GREEN}╔═══════════════════════════════════════════════════════╗${COLOR_RESET}"
echo -e "${COLOR_GREEN}║                                                       ║${COLOR_RESET}"
echo -e "${COLOR_GREEN}║           ✅  Installation complete! 🎉               ║${COLOR_RESET}"
echo -e "${COLOR_GREEN}║                                                       ║${COLOR_RESET}"
echo -e "${COLOR_GREEN}╚═══════════════════════════════════════════════════════╝${COLOR_RESET}"
echo ""

echo -e "${COLOR_BLUE}You're all set! From any Upsun project:${COLOR_RESET}"
echo -e "  ${COLOR_GREEN}${COMMAND_NAME}${COLOR_RESET}"
echo ""
echo -e "${COLOR_BLUE}💡 Note:${COLOR_RESET} If the command isn't found, run: ${COLOR_GREEN}hash -r${COLOR_RESET}"
echo -e "   (This refreshes your shell's command cache)"
echo ""
echo -e "${COLOR_BLUE}To uninstall:${COLOR_RESET}"
echo -e "  cd ${SCRIPT_DIR}"
echo -e "  ./uninstall.sh"
echo ""
