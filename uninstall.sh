#!/bin/bash

# Remove upsun-scripts commands from /usr/local/bin

set -e

COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RESET='\033[0m'

INSTALL_DIR="/usr/local/bin"
COMMANDS=("upsun-db-dump" "upsun-check-traffic")
COMMON_FILE="upsun-scripts-common.sh"

targets=()
for command_name in "${COMMANDS[@]}"; do
  if [[ -f "${INSTALL_DIR}/${command_name}" ]]; then
    targets+=("${INSTALL_DIR}/${command_name}")
  fi
done
if [[ -f "${INSTALL_DIR}/${COMMON_FILE}" ]]; then
  targets+=("${INSTALL_DIR}/${COMMON_FILE}")
fi

if [[ ${#targets[@]} -eq 0 ]]; then
  echo -e "${COLOR_YELLOW}No upsun-scripts commands are installed.${COLOR_RESET}"
  exit 0
fi

echo -e "${COLOR_YELLOW}Will remove:${COLOR_RESET}"
for target in "${targets[@]}"; do
  echo "  $target"
done

read -p "$(echo -e ${COLOR_YELLOW})Continue? (y/N) $(echo -e ${COLOR_RESET})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${COLOR_BLUE}Cancelled.${COLOR_RESET}"
  exit 0
fi

if [[ -w "$INSTALL_DIR" ]]; then
  USE_SUDO=""
else
  USE_SUDO="sudo"
fi

for target in "${targets[@]}"; do
  $USE_SUDO rm -f "$target"
  echo -e "${COLOR_GREEN}✓ Removed ${target}${COLOR_RESET}"
done
