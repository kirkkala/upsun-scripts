#!/bin/bash

# Installer for Kirkkala's Upsun scripts
#
# From a checkout:  ./install.sh
# Without git:      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/kirkkala/upsun-scripts/main/install.sh)"

set -e

COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_RESET='\033[0m'

BIN_DIR="/usr/local/bin"
LIB_DIR="/usr/local/lib/kirkkala-upsun"
COMMANDS=("upsun-db-dump" "upsun-check-traffic")
COMMON_FILE="upsun-scripts-common.sh"
GITHUB_REPO="kirkkala/upsun-scripts"
INSTALLER_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main/install.sh"

ROOT_DIR=""
SRC_DIR=""
CHECKOUT=""

# Checkout: use files next to this script. Curl one-liner: download main.
resolve_sources() {
  local script_dir="" work
  if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  fi

  if [[ -n "$script_dir" && -f "${script_dir}/src/${COMMON_FILE}" ]]; then
    ROOT_DIR="$script_dir"
    SRC_DIR="${script_dir}/src"
    CHECKOUT=$(git -C "$script_dir" describe --tags --always 2>/dev/null || true)
    return
  fi

  command -v curl >/dev/null && command -v tar >/dev/null || {
    echo -e "${COLOR_RED}Error: curl and tar are required to install.${COLOR_RESET}" >&2
    exit 1
  }

  echo -e "${COLOR_BLUE}📥 Downloading ${GITHUB_REPO}...${COLOR_RESET}"
  work=$(mktemp -d)
  trap 'rm -rf "'"$work"'"' EXIT
  curl -fsSL "https://github.com/${GITHUB_REPO}/archive/refs/heads/main.tar.gz" | tar -xz -C "$work"
  ROOT_DIR="$work/upsun-scripts-main"
  SRC_DIR="${ROOT_DIR}/src"
  CHECKOUT="main"
  if [[ ! -f "${SRC_DIR}/${COMMON_FILE}" ]]; then
    echo -e "${COLOR_RED}Error: download did not contain expected files.${COLOR_RESET}" >&2
    exit 1
  fi
  echo ""
}

resolve_sources
# shellcheck source=src/upsun-scripts-common.sh
source "${SRC_DIR}/${COMMON_FILE}"

echo ""
echo -e "${COLOR_BLUE}╔═══════════════════════════════════════════════════════╗${COLOR_RESET}"
echo -e "${COLOR_BLUE}║                                                       ║${COLOR_RESET}"
echo -e "${COLOR_BLUE}║         💾  ${TOOL_NAME}  ✨              ║${COLOR_RESET}"
echo -e "${COLOR_BLUE}║                                                       ║${COLOR_RESET}"
echo -e "${COLOR_BLUE}╚═══════════════════════════════════════════════════════╝${COLOR_RESET}"
echo -e "${COLOR_YELLOW}Unofficial helpers by kirkkala — not affiliated with Upsun.${COLOR_RESET}"
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
    echo -e "   Running the installer again updates it to ${COLOR_GREEN}${CHECKOUT}${COLOR_RESET}."
  else
    echo -e "   Running the installer again updates it to this version."
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
$USE_SUDO cp "${SRC_DIR}/${COMMON_FILE}" "${LIB_DIR}/${COMMON_FILE}"
for command_name in "${COMMANDS[@]}"; do
  $USE_SUDO cp "${SRC_DIR}/${command_name}" "${LIB_DIR}/${command_name}"
  $USE_SUDO chmod +x "${LIB_DIR}/${command_name}"
  $USE_SUDO ln -sfn "${LIB_DIR}/${command_name}" "${BIN_DIR}/${command_name}"
done
if [[ -f "${ROOT_DIR}/uninstall.sh" ]]; then
  $USE_SUDO cp "${ROOT_DIR}/uninstall.sh" "${LIB_DIR}/uninstall.sh"
  $USE_SUDO chmod +x "${LIB_DIR}/uninstall.sh"
fi
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

echo -e "${COLOR_BLUE}${TOOL_NAME} are ready. From any Upsun project:${COLOR_RESET}"
echo -e "  ${COLOR_GREEN}upsun-db-dump${COLOR_RESET}           dump the current branch database"
echo -e "  ${COLOR_GREEN}upsun-check-traffic${COLOR_RESET}     top origin IPs on main"
echo ""
echo -e "${COLOR_BLUE}💡 Note:${COLOR_RESET} If a command isn't found, run: ${COLOR_GREEN}hash -r${COLOR_RESET}"
echo -e "   (This refreshes your shell's command cache)"
echo ""
echo -e "${COLOR_BLUE}To uninstall:${COLOR_RESET}"
echo -e "  ${COLOR_GREEN}${LIB_DIR}/uninstall.sh${COLOR_RESET}"
echo ""
echo -e "${COLOR_BLUE}To reinstall / update:${COLOR_RESET}"
echo -e "  ${COLOR_GREEN}/bin/bash -c \"\$(curl -fsSL ${INSTALLER_URL})\"${COLOR_RESET}"
echo ""
