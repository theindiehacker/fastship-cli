#!/usr/bin/env bash
# publish.yml がまとめたバイナリとインストールスクリプトを registry.fastship.jp の Cloud Storage (cli/<version>/) に置く。
# terraform-modules の scripts/upload_archive.sh と同じ方式。
#
#   scripts/upload.sh <ファイルのディレクトリ> <バージョン (1.2.0)> <バケット>
#
# - SHA256SUMS を最後に置く。registry は SHA256SUMS があるバージョンだけを配るため、途中で失敗しても半端なバージョンは見えない
# - 公開したバージョンは書き換えない。既にあるオブジェクトは、同じ内容 (md5 が一致) ならスキップし、違えば失敗する。
#   PyInstaller のビルドは毎回同じバイナリにならないため、失敗したときはワークフロー全体ではなく publish のジョブだけを再実行する
set -euo pipefail

if [ $# -ne 3 ]; then
  echo "usage: $0 <ファイルのディレクトリ> <バージョン> <バケット>" >&2
  exit 2
fi

dist=$1
version=$2
bucket=$3

upload() {
  local src=$1 dst=$2 local_md5 remote_md5
  local_md5=$(openssl dgst -md5 -binary "$src" | base64)
  if remote_md5=$(gcloud storage objects describe "$dst" --format='value(md5_hash)' 2>/dev/null); then
    if [ "$remote_md5" = "$local_md5" ]; then
      echo "skip (同じ内容): $dst" >&2
      return
    fi
    echo "::error::$dst は既に違う内容で公開されています。公開したバージョンは書き換えません" >&2
    exit 1
  fi
  # describe と cp の間に別の実行が置いた場合も上書きしない
  gcloud storage cp --if-generation-match=0 "$src" "$dst"
}

for src in "$dist"/*; do
  name=$(basename "$src")
  [ "$name" = SHA256SUMS ] && continue
  upload "$src" "gs://$bucket/cli/$version/$name"
done
upload "$dist/SHA256SUMS" "gs://$bucket/cli/$version/SHA256SUMS"
