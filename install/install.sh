#!/usr/bin/env bash
# FastShip CLI のインストーラ (macOS / Linux / WSL)。
#
#   curl -fsSL https://raw.githubusercontent.com/theindiehacker/fastship-cli/main/install/install.sh | bash
#
# - uv が無ければ入れ、uv tool install で main の fastship を入れる (Python も uv が用意する)。main に入ったものがリリース
# - 既に入っていれば、更新はバックグラウンドで行い、すぐに終わる (Claude Code の SessionStart で毎回呼ばれ、git の取得に数秒かかるため)。
#   更新は次のセッションから効く。オフラインなどで更新に失敗しても、入っているものを使い続ける
# - FASTSHIP_REF にブランチやタグを入れると、それを入れる (PR の動作確認用)
set -euo pipefail

source="fastship @ git+https://github.com/theindiehacker/fastship-cli${FASTSHIP_REF:+@$FASTSHIP_REF}"

info() { echo "fastship: $*" >&2; }

if ! command -v uv >/dev/null; then
  info "uv をインストールします"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

bin="$(uv tool dir --bin)/fastship"
if [ -x "$bin" ]; then
  nohup uv tool install --quiet --upgrade "$source" >/dev/null 2>&1 &
  exit 0
fi

info "インストールします"
uv tool install --quiet "$source"

if ! command -v fastship >/dev/null; then
  # uv tool のコマンドの置き場所 (既定 ~/.local/bin) をシェルの設定の PATH に足す。
  # 設定済みでも今のシェルに反映されていないだけなら失敗扱いになるので、終了コードは見ない
  uv tool update-shell || true
  info "$bin を入れました。新しいターミナルから fastship を使えます"
fi
