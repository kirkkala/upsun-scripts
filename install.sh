#!/bin/bash

# Installation script for upsun-scripts
# This script installs the CLI helpers globally on your system

set -e  # Exit on error

COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_RESET='\033[0m'

INSTALL_DIR="/usr/local/bin"
COMMANDS=("upsun-db-dump" "upsun-check-traffic")
COMMON_FILE="upsun-scripts-common.sh"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECKOUT=$(git -C "$SCRIPT_DIR" describe --tags --always 2>/dev/null || true)

echo ""
echo -e "${COLOR_BLUE}╔═══════════════════════════════════════════════════════╗${COLOR_RESET}"
echo -e "${COLOR_BLUE}║                                                       ║${COLOR_RESET}"
echo -e "${COLOR_BLUE}║           💾  upsun-scripts installer  ✨             ║${COLOR_RESET}"
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

already_installed=()
for command_name in "${COMMANDS[@]}"; do
  if [[ -f "${INSTALL_DIR}/${command_name}" ]]; then
    already_installed+=("$command_name")
  fi
done

if [[ ${#already_installed[@]} -gt 0 ]]; then
  echo -e "${COLOR_YELLOW}⚠️  Already installed: ${already_installed[*]}${COLOR_RESET}"
  if [[ -n "$CHECKOUT" ]]; then
    echo -e "   Running the installer again updates all commands to this checkout (${COLOR_GREEN}${CHECKOUT}${COLOR_RESET})."
  else
    echo -e "   Running the installer again updates all commands to this repo's version."
  fi
  read -p "   Update now? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n${COLOR_BLUE}Update cancelled.${COLOR_RESET}\n"
    exit 0
  fi
  echo ""
fi

echo -e "${COLOR_BLUE}📦 Installing shared helpers...${COLOR_RESET}"
$USE_SUDO cp "${SCRIPT_DIR}/src/${COMMON_FILE}" "${INSTALL_DIR}/${COMMON_FILE}"
echo -e "${COLOR_GREEN}✓ Installed to ${INSTALL_DIR}/${COMMON_FILE}${COLOR_RESET}"
echo ""

for command_name in "${COMMANDS[@]}"; do
  echo -e "${COLOR_BLUE}📦 Installing ${command_name}...${COLOR_RESET}"
  $USE_SUDO cp "${SCRIPT_DIR}/src/${command_name}" "${INSTALL_DIR}/${command_name}"
  $USE_SUDO chmod +x "${INSTALL_DIR}/${command_name}"
  echo -e "${COLOR_GREEN}✓ Installed to ${INSTALL_DIR}/${command_name}${COLOR_RESET}"
  echo ""
done

# Warn if Upsun CLI is missing (the commands need it)
if ! command -v upsun >/dev/null 2>&1; then
  echo -e "${COLOR_YELLOW}⚠️  Upsun CLI not found in PATH${COLOR_RESET}"
  echo -e "   These commands need it to talk to Upsun."
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
echo -e "  ${COLOR_GREEN}upsun-db-dump${COLOR_RESET}           dump the current branch database"
echo -e "  ${COLOR_GREEN}upsun-check-traffic${COLOR_RESET}     top origin IPs on main"
echo ""
echo -e "${COLOR_BLUE}💡 Note:${COLOR_RESET} If a command isn't found, run: ${COLOR_GREEN}hash -r${COLOR_RESET}"
echo -e "   (This refreshes your shell's command cache)"
echo ""
echo -e "${COLOR_BLUE}To uninstall:${COLOR_RESET}"
echo -e "  cd ${SCRIPT_DIR}"
echo -e "  ./uninstall.sh"
echo ""
