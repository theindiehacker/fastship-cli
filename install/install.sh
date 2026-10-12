#!/usr/bin/env bash
# FastShip CLI のインストーラ (macOS / Linux / WSL)。
#
#   curl -fsSL https://raw.githubusercontent.com/theindiehacker/fastship-cli/main/install/install.sh | bash
#
# - uv が無ければ入れ、uv tool install で main の fastship を入れる (Python も uv が用意する)。main に入ったものがリリース
# - 既に入っていれば、更新はバックグラウンドで行い、すぐに終わる (Claude Code の SessionStart で毎回呼ばれ、git の取得に数秒かかるため)。
#   更新は次のセッションから効く。失敗したらログを残し、次の実行で知らせる (入っているものは使い続ける)
# - FASTSHIP_REF にブランチやタグを入れると、それを入れる (PR の動作確認用)
set -euo pipefail

source="fastship @ git+https://github.com/theindiehacker/fastship-cli${FASTSHIP_REF:+@$FASTSHIP_REF}"

info() { echo "fastship: $*" >&2; }

# uv は git の取得に git コマンドを使う
command -v git >/dev/null || { info "git が必要です。先に git をインストールしてください"; exit 1; }

if ! command -v uv >/dev/null; then
  info "uv をインストールします"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  # uv のインストーラと同じ優先順位で置き場所を決める
  export PATH="${UV_INSTALL_DIR:-${XDG_BIN_HOME:-$HOME/.local/bin}}:$PATH"
fi

bin_dir="$(uv tool dir --bin)"
if ! command -v fastship >/dev/null && [ -x "$bin_dir/fastship" ]; then
  # 入っているのに PATH に無い (シェルの設定が戻された、など)。設定済みなら uv は失敗扱いにするので、終了コードは見ない
  uv tool update-shell >/dev/null 2>&1 || true
  info "$bin_dir が PATH にありません。新しいターミナルから fastship を使えます"
fi

if [ -x "$bin_dir/fastship" ]; then
  log="$(uv tool dir)/fastship-upgrade.log"
  if [ -f "$log" ]; then
    info "前回の更新に失敗しました。インストール済みの fastship を使い続けます (詳細: $log)"
  fi
  # 成功したらログを消す。失敗したら残し、次の実行で上のメッセージを出す
  # shellcheck disable=SC2016 # $1 / $2 は sh -c の中で展開する
  nohup sh -c 'uv tool install --quiet --upgrade "$1" >"$2" 2>&1 && rm -f "$2"' sh "$source" "$log" >/dev/null 2>&1 &
  exit 0
fi

info "インストールします"
uv tool install --quiet "$source"

if ! command -v fastship >/dev/null; then
  # uv tool のコマンドの置き場所 (既定 ~/.local/bin) をシェルの設定の PATH に足す。
  # 設定済みでも今のシェルに反映されていないだけなら失敗扱いになるので、終了コードは見ない
  uv tool update-shell || true
  info "$bin_dir/fastship を入れました。新しいターミナルから fastship を使えます"
fi
