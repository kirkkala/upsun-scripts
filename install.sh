#!/bin/bash

# Installation script for upsun-scripts

set -e

COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RESET='\033[0m'

BIN_DIR="/usr/local/bin"
LIB_DIR="/usr/local/lib/kirkkala-upsun"
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

if [[ ! -w "$BIN_DIR" || ! -w "$(dirname "$LIB_DIR")" ]]; then
  echo -e "${COLOR_YELLOW}⚠️  Installing to ${LIB_DIR} requires elevated privileges${COLOR_RESET}"
  echo -e "   You may be prompted for your password...\n"
  USE_SUDO="sudo"
else
  USE_SUDO=""
fi

if [[ -d "$LIB_DIR" || -e "${BIN_DIR}/upsun-db-dump" || -e "${BIN_DIR}/upsun-check-traffic" ]]; then
  echo -e "${COLOR_YELLOW}⚠️  An existing install was found${COLOR_RESET}"
  if [[ -n "$CHECKOUT" ]]; then
    echo -e "   Running the installer again updates it to this checkout (${COLOR_GREEN}${CHECKOUT}${COLOR_RESET})."
  else
    echo -e "   Running the installer again updates it to this repo's version."
  fi
  read -p "   Update now? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n${COLOR_BLUE}Update cancelled.${COLOR_RESET}\n"
    exit 0
  fi
  echo ""
fi

echo -e "${COLOR_BLUE}📦 Installing to ${LIB_DIR}...${COLOR_RESET}"
$USE_SUDO mkdir -p "$LIB_DIR"
$USE_SUDO cp "${SCRIPT_DIR}/src/${COMMON_FILE}" "${LIB_DIR}/${COMMON_FILE}"
for command_name in "${COMMANDS[@]}"; do
  $USE_SUDO cp "${SCRIPT_DIR}/src/${command_name}" "${LIB_DIR}/${command_name}"
  $USE_SUDO chmod +x "${LIB_DIR}/${command_name}"
  $USE_SUDO ln -sfn "${LIB_DIR}/${command_name}" "${BIN_DIR}/${command_name}"
done
# Leftover from when the helper was copied onto PATH
$USE_SUDO rm -f "${BIN_DIR}/${COMMON_FILE}"
echo -e "${COLOR_GREEN}✓ Scripts installed${COLOR_RESET}"
echo -e "  ${COLOR_GREEN}upsun-db-dump${COLOR_RESET}        → ${LIB_DIR}/upsun-db-dump"
echo -e "  ${COLOR_GREEN}upsun-check-traffic${COLOR_RESET}  → ${LIB_DIR}/upsun-check-traffic"
echo ""

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
