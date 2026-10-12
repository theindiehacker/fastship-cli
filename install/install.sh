#!/usr/bin/env bash
# FastShip CLI のインストーラ (macOS / Linux / WSL)。
#
#   curl -fsSL https://registry.fastship.jp/cli/install.sh | bash
#
# - 最新のバージョンが入っていれば何もしない (Claude Code の SessionStart で毎回呼ばれるため)
# - 最新のバージョンを確かめられなくても、既に入っていれば失敗にしない (オフラインでもセッションを止めない)
# - 環境変数 FASTSHIP_INSTALL_DIR (既定 ~/.local/bin) に置く。FASTSHIP_REGISTRY は動作確認用
set -euo pipefail

base_url="${FASTSHIP_REGISTRY:-https://registry.fastship.jp}/cli"
install_dir="${FASTSHIP_INSTALL_DIR:-$HOME/.local/bin}"
bin="$install_dir/fastship"

info() { echo "fastship: $*" >&2; }
fail() { info "$*"; exit 1; }

case "$(uname -s)" in
  Darwin) os=darwin ;;
  Linux) os=linux ;;
  *) fail "対応していない OS です: $(uname -s) (Windows は install.ps1 を使ってください)" ;;
esac
case "$(uname -m)" in
  arm64 | aarch64) arch=arm64 ;;
  x86_64 | amd64) arch=x64 ;;
  *) fail "対応していない CPU です: $(uname -m)" ;;
esac
# Rosetta 2 の上のシェルでも、Apple Silicon ならネイティブのバイナリを入れる
if [ "$os-$arch" = darwin-x64 ] && [ "$(sysctl -n hw.optional.arm64 2>/dev/null)" = 1 ]; then
  arch=arm64
fi
if [ "$os" = linux ] && ldd --version 2>&1 | grep -qi musl; then
  fail "musl libc (Alpine など) には対応していません"
fi

installed=""
if [ -x "$bin" ]; then
  installed=$("$bin" --version 2>/dev/null || true)
fi

if ! latest=$(curl -fsSL "$base_url/latest"); then
  [ -n "$installed" ] && { info "最新のバージョンを確かめられませんでした。$installed を使い続けます"; exit 0; }
  fail "最新のバージョンを取得できませんでした: $base_url/latest"
fi
if [ "$installed" = "$latest" ]; then
  exit 0
fi

asset="fastship-$os-$arch"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

info "$latest をインストールします ($asset)"
curl -fsSL -o "$tmp/$asset" "$base_url/$latest/$asset"
curl -fsSL -o "$tmp/SHA256SUMS" "$base_url/$latest/SHA256SUMS"

expected=$(awk -v f="$asset" '$2 == f || $2 == "*" f { print $1 }' "$tmp/SHA256SUMS")
if command -v sha256sum >/dev/null; then
  actual=$(sha256sum "$tmp/$asset" | cut -d' ' -f1)
else
  actual=$(shasum -a 256 "$tmp/$asset" | cut -d' ' -f1)
fi
[ -n "$expected" ] && [ "$expected" = "$actual" ] || fail "チェックサムが一致しません: $asset"

mkdir -p "$install_dir"
chmod +x "$tmp/$asset"
# 実行中のバイナリを壊さないよう、同じディレクトリに置いてから mv で差し替える
cp "$tmp/$asset" "$bin.tmp.$$"
mv -f "$bin.tmp.$$" "$bin"
info "$bin に $latest をインストールしました"

case ":$PATH:" in
  *":$install_dir:"*) ;;
  *) info "$install_dir が PATH にありません。シェルの設定に export PATH=\"$install_dir:\$PATH\" を追加してください" ;;
esac
