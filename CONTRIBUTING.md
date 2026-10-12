# CONTRIBUTING
## セットアップ

```bash
git clone git@github.com:theindiehacker/fastship-cli.git
cd fastship-cli
uv sync  # .venv/ を作成し、依存をインストール
```

## よく使うコマンド

| やりたいこと | コマンド |
| --- | --- |
| CLI を実行 | `uv run fastship` |
| 依存を追加 | `uv add <package>` |
| 開発用依存を追加 | `uv add --dev <package>` |
| Python REPL | `uv run python` |

## リリース

main にマージしたものがそのままリリースです。各自の環境は、次に `install.sh` / `install.ps1` を実行したとき (Claude Code では次のセッション開始時) に、`uv tool install --upgrade` で main に追従します。

- main を壊すと全員の hook が壊れるので、main には PR のレビューを通したものだけを入れてください。
- `pyproject.toml` の `version` は `fastship --version` に出るだけです。変更点が分かるように上げてください。

### インストールスクリプトの動作確認

`FASTSHIP_REF` にブランチ名を入れると、そのブランチを入れられます。`UV_TOOL_DIR` と `UV_TOOL_BIN_DIR` を変えると、普段の環境を汚さずに試せます。

```bash
export UV_TOOL_DIR=/tmp/fastship-tools UV_TOOL_BIN_DIR=/tmp/fastship-bin PATH="/tmp/fastship-bin:$PATH"
FASTSHIP_REF=<ブランチ名> bash install/install.sh
fastship --version
```
