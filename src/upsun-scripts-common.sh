#!/bin/bash

# Shared helpers for upsun-scripts commands. Sourced, not executed.

# Single source of truth for --version. Bump this when tagging a release.
VERSION="0.2.0"

COLOR_RED=$'\033[0;31m'
COLOR_GREEN=$'\033[0;32m'
COLOR_BLUE=$'\033[0;34m'
COLOR_YELLOW=$'\033[1;33m'
COLOR_RESET=$'\033[0m'

upsun_require_git() {
  if ! command -v git >/dev/null 2>&1; then
    echo -e "${COLOR_RED}Error: git is not installed.${COLOR_RESET}" >&2
    exit 1
  fi
}

upsun_require_cli() {
  if ! command -v upsun >/dev/null 2>&1; then
    echo -e "${COLOR_RED}Error: Upsun CLI not found.${COLOR_RESET}" >&2
    echo -e "Install it from: ${COLOR_BLUE}https://docs.upsun.com/administration/cli/${COLOR_RESET}" >&2
    exit 1
  fi
}

# Sets root to the current git repository toplevel.
upsun_require_repo() {
  if ! root=$(git rev-parse --show-toplevel 2>/dev/null); then
    echo -e "${COLOR_RED}Error: not inside a git repository.${COLOR_RESET}" >&2
    echo "Run this from your Upsun project." >&2
    exit 1
  fi
}

# Sets branch to the current git branch name.
upsun_require_branch() {
  branch=$(git -C "$root" branch --show-current)
  if [[ -z "$branch" ]]; then
    echo -e "${COLOR_RED}Error: not on a git branch (detached HEAD?).${COLOR_RESET}" >&2
    echo "Checkout a branch that matches an Upsun environment, then try again." >&2
    exit 1
  fi
}

# Requires .upsun/local/project.yaml.
#   $1  why the user should link (appended after "Link it so")
#   $2  optional extra hint line
#   $3  optional command shown under that hint
upsun_require_project_link() {
  local reason="$1"
  local extra_hint="${2:-}"
  local extra_command="${3:-}"

  if [[ ! -f "$root/.upsun/local/project.yaml" ]]; then
    echo -e "${COLOR_YELLOW}This repo isn't linked to an Upsun project.${COLOR_RESET}" >&2
    echo "" >&2
    echo "Link it so ${reason}:" >&2
    echo -e "  ${COLOR_GREEN}upsun project:set-remote${COLOR_RESET}" >&2
    if [[ -n "$extra_hint" ]]; then
      echo "" >&2
      echo "$extra_hint" >&2
      echo -e "  ${COLOR_GREEN}${extra_command}${COLOR_RESET}" >&2
    fi
    exit 1
  fi
}

upsun_require_basics() {
  upsun_require_git
  upsun_require_cli
  upsun_require_repo
}
