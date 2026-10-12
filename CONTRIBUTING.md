# CONTRIBUTING
## セットアップ

```bash
git clone git@github.com:theindiehacker/fastship-cli.git
cd fastship-cli
uv sync  # .venv/ を作成し、dev 依存 (pyinstaller) を含めてインストール
```

## よく使うコマンド

| やりたいこと | コマンド |
| --- | --- |
| CLI を実行 | `uv run fastship` |
| 依存を追加 | `uv add <package>` |
| 開発用依存を追加 | `uv add --dev <package>` |
| Python REPL | `uv run python` |
| バイナリを作る | `uv run pyinstaller --onefile --name fastship --copy-metadata fastship src/fastship/__main__.py` (`dist/fastship`) |

## リリース

バイナリとインストールスクリプトは [registry.fastship.jp](https://github.com/theindiehacker/registry.fastship.jp) の `/cli/` から配ります (リポジトリが private で、GitHub Releases は認証なしで取れないため)。

1. `pyproject.toml` の `version` を上げて、main にマージする (`uv lock` も忘れずに)
2. main にタグ `vX.Y.Z` を付けて push する
3. Actions → 📦 Publish を `version: vX.Y.Z` で実行する

- 📦 Publish は OS と CPU ごとのランナーでバイナリを作り、`--version` がタグと一致するかを確かめてから、Cloud Storage の `cli/<version>/` に置きます。
- 公開したバージョンは書き換えません。直すときは次のバージョンを出してください。
- publish のジョブが途中で失敗したときは、**そのジョブだけ**を再実行します。PyInstaller のビルドは毎回同じバイナリにならないため、ワークフロー全体をやり直すと公開済みのファイルと食い違って失敗します。
- 置いてから `https://registry.fastship.jp/cli/latest` に出るまで、最大 1 分かかります。

### 初回だけ必要な設定

registry.fastship.jp の bootstrap と environments/production を apply したあと、このリポジトリに次を設定します。

| 種類 | 名前 | 値 |
| --- | --- | --- |
| Variables | `WIF_PROVIDER_NAME` / `PUBLISH_SERVICE_ACCOUNT_EMAIL` | registry.fastship.jp の bootstrap の出力 `cli_github_variables` |
| Variables | `BUCKET` | registry.fastship.jp の environments/production の出力 `bucket` |
| Environments | `production` | publish のジョブが使う。保護ブランチは main だけにする |

### インストールスクリプトの動作確認

`install/install.sh` は `FASTSHIP_REGISTRY` と `FASTSHIP_INSTALL_DIR` で配信元と置き場所を変えられます。registry.fastship.jp をローカルで動かし (`ARCHIVE_DIR` に `cli/<version>/` を置く)、次のように試せます。

```bash
FASTSHIP_REGISTRY=http://localhost:8000 FASTSHIP_INSTALL_DIR=/tmp/fastship-bin bash install/install.sh
```
