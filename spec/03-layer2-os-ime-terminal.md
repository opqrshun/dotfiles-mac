# Spec: Layer2 macOS Settings / IME / Terminal (Deferred)

Why(なぜ必要か): 今後 OS 設定を自動化する場合の境界を明確にし、過剰変更を防ぐため。

## Purpose
現在の最小構成では OS/IME/Terminal 設定は自動変更しないことを明文化する。

## Inputs/Preconditions
- OS が macOS であること。

## Actions
1. `layer2/apply.sh` は `defaults write` を実行しない。
2. `layer2/apply.sh` は IME 設定を変更しない。
3. `layer2/apply.sh` は Terminal/iTerm 設定を変更しない。

## Expected State
- Layer2 実行後も OS/IME/Terminal 設定はユーザー手動設定のまま。

## Verification Commands
- `rg -n 'defaults write|com.apple.Terminal|com.googlecode.iterm2|ime' ./layer2/apply.sh` の結果に設定変更処理がない。

## Rollback（可能な範囲）
- この仕様に基づく自動変更は行っていないため、ロールバック不要。
