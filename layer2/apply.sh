#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[layer2] %s\n' "$*"
}

fail() {
  printf '[layer2][error] %s\n' "$*" >&2
  exit 1
}

ensure_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || fail 'This script supports macOS only.'
}

resolve_home_path() {
  local p
  p="$1"
  if [[ "${p}" == ~/* ]]; then
    p="${HOME}/${p#~/}"
  fi
  printf '%s\n' "${p}"
}

apply_dotfiles_shell() {
  local repo_url repo_dir repo_ref install_script
  repo_url="${LAYER2_SHELL_REPO_URL:-https://github.com/opqrshun/dotfiles-shell.git}"
  repo_dir="${LAYER2_SHELL_REPO_DIR:-$HOME/.dotfiles-shell}"
  repo_ref="${LAYER2_SHELL_REPO_REF:-main}"

  repo_dir="$(resolve_home_path "${repo_dir}")"
  [[ "${repo_dir}" == /* ]] || fail "LAYER2_SHELL_REPO_DIR must be absolute: ${repo_dir}"
  repo_dir="${repo_dir%/}"

  if [[ -L "${repo_dir}" ]]; then
    fail "Refusing to use symlink repo dir: ${repo_dir} (set LAYER2_SHELL_REPO_DIR to a real directory)."
  fi

  if [[ ! -d "${repo_dir}/.git" ]]; then
    log "Cloning dotfiles-shell: ${repo_url} -> ${repo_dir}"
    git clone "${repo_url}" "${repo_dir}"
  else
    log "dotfiles-shell already exists: ${repo_dir}"
  fi

  git -C "${repo_dir}" fetch --all --prune
  git -C "${repo_dir}" checkout "${repo_ref}"
  git -C "${repo_dir}" pull --ff-only origin "${repo_ref}" || true

  install_script="${repo_dir}/install.sh"
  [[ -f "${install_script}" ]] || fail "install.sh not found: ${install_script}"

  log 'Running dotfiles-shell install.sh'
  bash "${install_script}"
}

backup_once() {
  local target backup
  target="$1"
  backup="${target}.bak.dotfiles"

  if [[ -f "${target}" && ! -f "${backup}" ]]; then
    cp "${target}" "${backup}"
    log "Backup created: ${backup}"
  fi
}

copy_if_different() {
  # Copy only when content changed (idempotent + low-noise rerun).
  local src dst
  src="$1"
  dst="$2"

  mkdir -p "$(dirname "${dst}")"
  if [[ ! -f "${dst}" ]] || ! cmp -s "${src}" "${dst}"; then
    cp "${src}" "${dst}"
    log "Updated: ${dst}"
  else
    log "Unchanged: ${dst}"
  fi
}

ensure_line_in_file() {
  # Ensure one managed line exists exactly once in the target file.
  local line file
  line="$1"
  file="$2"

  if [[ ! -f "${file}" ]]; then
    printf '%s\n' "${line}" >"${file}"
    log "Created: ${file}"
    return
  fi

  if ! grep -Fqx "${line}" "${file}"; then
    printf '\n%s\n' "${line}" >>"${file}"
    log "Appended managed line to: ${file}"
  else
    log "Managed line already exists: ${file}"
  fi
}

apply_zsh_bridge() {
  # Keep user .zshrc as-is and append one bridge line to load managed config.
  local script_dir src dst include_line
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  src="${script_dir}/files/main.zsh"
  dst="$HOME/.config/dotfiles/zsh/main.zsh"
  include_line='[ -f "$HOME/.config/dotfiles/zsh/main.zsh" ] && source "$HOME/.config/dotfiles/zsh/main.zsh"'

  copy_if_different "${src}" "${dst}"
  backup_once "$HOME/.zshrc"
  ensure_line_in_file "${include_line}" "$HOME/.zshrc"
}

main() {
  ensure_macos
  apply_dotfiles_shell
  apply_zsh_bridge
  log 'Done. Applied minimal layer2 setup.'
}

main "$@"
