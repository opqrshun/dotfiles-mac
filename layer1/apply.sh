#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[layer1] %s\n' "$*"
}

fail() {
  printf '[layer1][error] %s\n' "$*" >&2
  exit 1
}

ensure_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || fail 'This script supports macOS only.'
}

ensure_xcode_cli() {
  if ! xcode-select -p >/dev/null 2>&1; then
    log 'Xcode Command Line Tools are missing.'
    log 'Run: xcode-select --install'
    fail 'Install Xcode Command Line Tools first, then rerun.'
  fi
}

install_homebrew_if_needed() {
  if command -v brew >/dev/null 2>&1; then
    log 'Homebrew already installed.'
    return
  fi

  log 'Homebrew not found. Installing Homebrew.'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

load_brew_shellenv() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  elif command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
  else
    fail 'brew command not available after install attempt.'
  fi
}

apply_brew_bundle() {
  local script_dir repo_root brewfile
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  repo_root="$(cd "${script_dir}/.." && pwd)"
  brewfile="${repo_root}/layer1/Brewfile"

  [[ -f "${brewfile}" ]] || fail "Brewfile not found: ${brewfile}"

  log 'Running brew bundle...'
  brew bundle --file "${brewfile}"
  log 'brew bundle completed.'
}

main() {
  ensure_macos
  ensure_xcode_cli
  install_homebrew_if_needed
  load_brew_shellenv
  apply_brew_bundle
}

main "$@"
