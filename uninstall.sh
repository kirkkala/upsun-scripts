#!/bin/bash

# Remove Kirkkala's Upsun scripts and library files

set -e

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_common="${_dir}/src/upsun-scripts-common.sh"
[[ -f "$_common" ]] || _common="${_dir}/upsun-scripts-common.sh"
# shellcheck source=src/upsun-scripts-common.sh
source "$_common"

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
  echo -e "${COLOR_YELLOW}${TOOL_NAME} are not installed.${COLOR_RESET}"
  exit 0
fi

echo -e "${COLOR_YELLOW}Will remove:${COLOR_RESET}"
for target in "${targets[@]}"; do
  echo "  $target"
done

read -p "$(echo -e "${COLOR_YELLOW}")Continue? (y/N) $(echo -e "${COLOR_RESET}")" -n 1 -r
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
