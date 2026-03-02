# dotfiles-mac

macOS (Apple Silicon / Intel) 向けの初期セットアップを、最小レイヤーで再現するための dotfiles です。

- Layer0 は作成しません。
- Layer1: Homebrew 導入 + Brewfile 適用
- Layer2: `dotfiles-shell` 適用 + zsh bridge のみ
- すべて再実行可能（idempotent）を前提に設計しています。

## Directory

- `spec/`
  - `01-layer1-homebrew.md`
  - `02-layer2-shell-git.md`
  - `03-layer2-os-ime-terminal.md`
- `layer1/`
  - `Brewfile`
  - `apply.sh`
- `layer2/`
  - `install.sh`
  - `apply.sh`
  - `files/main.zsh`
- `bootstrap.sh`

## Setup

1. bootstrap.sh を直接実行

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/opqrshun/dotfiles-mac/dev/bootstrap.sh)
```

2. ブランチを変える場合

```bash
BOOTSTRAP_REPO_REF=main \
bash <(curl -fsSL https://raw.githubusercontent.com/opqrshun/dotfiles-mac/main/bootstrap.sh)
```

`dotfiles-shell` のブランチも同時に切り替える場合:

```bash
BOOTSTRAP_REPO_REF=dev \
LAYER2_SHELL_REPO_REF=main \
bash <(curl -fsSL https://raw.githubusercontent.com/opqrshun/dotfiles-mac/dev/bootstrap.sh)
```

3. 個別実行

```bash
./layer1/apply.sh
./layer2/install.sh
```

`dotfiles-shell` の取得先を切り替える場合:

```bash
LAYER2_SHELL_REPO_URL=https://github.com/<you>/dotfiles-shell.git \
LAYER2_SHELL_REPO_REF=master \
./layer2/install.sh
```

## Verification

### Layer1

```bash
uname -s
```
成功条件: `Darwin`。

```bash
command -v brew
```
成功条件: 終了コード 0。

```bash
brew bundle check --file ./layer1/Brewfile
```
成功条件: 終了コード 0（不足パッケージなし）。

### Layer2

```bash
test -d ~/.dotfiles-shell/.git && echo OK
```
成功条件: `OK` を表示。

```bash
grep -F 'main.zsh' ~/.zshrc | wc -l
```
成功条件: `1`。

```bash
test -f ~/.config/dotfiles/zsh/main.zsh && echo OK
```
成功条件: `OK` を表示。

## Backup and Rollback Policy

### Backup

- `layer2/apply.sh` は `~/.zshrc` を編集する前に、初回のみ `~/.zshrc.bak.dotfiles` を作成します。

### Rollback

- zsh bridge:

```bash
cp ~/.zshrc.bak.dotfiles ~/.zshrc
rm -f ~/.config/dotfiles/zsh/main.zsh
```

- `dotfiles-shell` を外す:

```bash
mv ~/.dotfiles-shell ~/.dotfiles-shell.backup.$(date +%Y%m%d%H%M%S)
```

## Notes

- 秘密情報（token, SSH 秘密鍵）は管理対象外です。
- 実行対象は `spec/`, `layer1/`, `layer2/` のみです。`dotfiles-macOS-old/` や他ディレクトリのコードは読み込みません。
