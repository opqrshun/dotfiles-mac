# Spec: Layer2 Shell Bridge

Why(なぜ必要か): 信頼するシェル環境を再現しつつ、既存ユーザー設定への影響を最小にするため。

## Purpose
`dotfiles-shell` を実行し、最小の zsh bridge を `~/.zshrc` に追加する。

## Inputs/Preconditions
- `zsh` と `git` が利用可能であること。
- ホームディレクトリに書き込み可能であること。
- ネットワーク接続があること（`dotfiles-shell` 初回 clone 時）。

## Actions
1. `dotfiles-shell` を `~/.dotfiles-shell`（既定）へ clone/pull し、`install.sh` を実行する。
2. `layer2/files/main.zsh` を `~/.config/dotfiles/zsh/main.zsh` へ配置する。
3. `~/.zshrc` に `main.zsh` を `source` する 1 行を追加する（未登録時のみ）。
4. `~/.zshrc` 編集前に `~/.zshrc.bak.dotfiles` を作成する（初回のみ）。

## Expected State
- `~/.dotfiles-shell` が存在し、`install.sh` が実行される。
- `~/.config/dotfiles/zsh/main.zsh` が存在する。
- `~/.zshrc` に bridge 行が 1 回だけ存在する。

## Verification Commands
- `test -d ~/.dotfiles-shell/.git` が成功。
- `test -f ~/.config/dotfiles/zsh/main.zsh` が成功。
- `grep -F 'main.zsh' ~/.zshrc | wc -l` が `1`。

## Rollback（可能な範囲）
- `~/.zshrc` を `~/.zshrc.bak.dotfiles` から復元可能。
- bridge ファイル削除: `rm ~/.config/dotfiles/zsh/main.zsh`。
- `dotfiles-shell` を無効化する場合は `~/.dotfiles-shell` を退避または削除する。
