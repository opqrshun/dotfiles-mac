#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf '[bootstrap][error] %s\n' "$*" >&2
  exit 1
}

[[ "$(uname -s)" == "Darwin" ]] || fail 'This bootstrap supports macOS only.'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dir=""

# If executed inside a local repo, use it directly.
if [[ -x "${script_dir}/layer1/apply.sh" && -x "${script_dir}/layer2/install.sh" ]]; then
  root_dir="${script_dir}"
else
  # If executed via curl, download this repo branch to a temp directory and run from there.
  ref="${BOOTSTRAP_REPO_REF:-dev}"
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "${tmp_dir}"' EXIT

  curl -fsSL "https://codeload.github.com/opqrshun/dotfiles-mac/tar.gz/refs/heads/${ref}" -o "${tmp_dir}/repo.tar.gz"
  tar -xzf "${tmp_dir}/repo.tar.gz" -C "${tmp_dir}"
  root_dir="$(find "${tmp_dir}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
fi

[[ -n "${root_dir}" ]] || fail 'Failed to prepare repository files.'
"${root_dir}/layer1/apply.sh"
"${root_dir}/layer2/install.sh"
