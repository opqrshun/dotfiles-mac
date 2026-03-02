# Spec: Layer1 Homebrew Bootstrap and Bundle

Why(なぜ必要か): macOS の初期状態から CLI/GUI の依存を再現可能にするため。

## Purpose
Layer1 で Homebrew の導入有無を判定し、`Brewfile` に定義したパッケージ群を idempotent に適用する。

## Inputs/Preconditions
- OS が macOS であること。
- ネットワーク接続があること（Homebrew 未導入時）。
- `xcode-select -p` が利用可能であること。
- 実行ユーザーに Homebrew 管理ディレクトリへの書き込み権限があること。

## Actions
1. `uname -s` で macOS を検証する。
2. `xcode-select -p` を確認し、未導入なら `xcode-select --install` を案内して停止する。
3. `brew` がなければ公式スクリプトでインストールする（非対話モード）。
4. Apple Silicon は `/opt/homebrew/bin/brew shellenv`、Intel は `/usr/local/bin/brew shellenv` を読み込む。
5. `brew bundle --file layer1/Brewfile` を実行する。

## Expected State
- `brew --version` が成功する。
- `layer1/Brewfile` の formula/cask が導入済みになる。
- 再実行しても同じ状態に収束し、不要な再変更をしない。

## Verification Commands
- `uname -s` が `Darwin`。
- `command -v brew` が 0 を返す。
- `brew bundle check --file ./layer1/Brewfile` が成功。

## Rollback（可能な範囲）
- 特定パッケージの削除: `brew uninstall <formula>` / `brew uninstall --cask <cask>`。
- Brewfile 全体を巻き戻す場合は対象を明示して個別アンインストールする（破壊的な一括削除は自動化しない）。
