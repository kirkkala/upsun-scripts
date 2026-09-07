#!/bin/bash

# Remove kirkkala-upsun commands and library files

set -e

COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RESET='\033[0m'

BIN_DIR="/usr/local/bin"
LIB_DIR="/usr/local/lib/kirkkala-upsun"

targets=()
for path in \
  "${BIN_DIR}/upsun-db-dump" \
  "${BIN_DIR}/upsun-check-traffic" \
  "${BIN_DIR}/upsun-scripts-common.sh" \
  "$LIB_DIR"
do
  if [[ -e "$path" || -L "$path" ]]; then
    targets+=("$path")
  fi
done

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

if [[ ! -w "$BIN_DIR" ]]; then
  USE_SUDO="sudo"
else
  USE_SUDO=""
fi

for target in "${targets[@]}"; do
  $USE_SUDO rm -rf "$target"
  echo -e "${COLOR_GREEN}✓ Removed ${target}${COLOR_RESET}"
done
