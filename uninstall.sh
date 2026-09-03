#!/bin/bash

# Remove upsun-db-dump from /usr/local/bin

set -e

COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RESET='\033[0m'

INSTALL_DIR="/usr/local/bin"
COMMAND_NAME="upsun-db-dump"
TARGET="${INSTALL_DIR}/${COMMAND_NAME}"

if [[ ! -f "$TARGET" ]]; then
  echo -e "${COLOR_YELLOW}${COMMAND_NAME} is not installed.${COLOR_RESET}"
  exit 0
fi

read -p "$(echo -e ${COLOR_YELLOW})Remove ${TARGET}? (y/N) $(echo -e ${COLOR_RESET})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${COLOR_BLUE}Cancelled.${COLOR_RESET}"
  exit 0
fi

if [[ -w "$INSTALL_DIR" ]]; then
  rm -f "$TARGET"
else
  sudo rm -f "$TARGET"
fi

echo -e "${COLOR_GREEN}✓ Removed ${TARGET}${COLOR_RESET}"
