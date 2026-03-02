# Managed by dotfiles-mac/layer2/apply.sh
# Place personal and secret values in ~/.zshrc.local (not tracked by repo).

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
