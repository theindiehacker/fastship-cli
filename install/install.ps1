# FastShip CLI のインストーラ (Windows)。
#
#   irm https://raw.githubusercontent.com/theindiehacker/fastship-cli/main/install/install.ps1 | iex
#
# - uv が無ければ入れ、uv tool install で main の fastship を入れる (Python も uv が用意する)。main に入ったものがリリース
# - 既に入っていれば、更新はバックグラウンドで行い、すぐに終わる (Claude Code の SessionStart で毎回呼ばれ、git の取得に数秒かかるため)。
#   更新は次のセッションから効く。オフラインや、別のセッションで fastship.exe が動いていて更新に失敗しても、入っているものを使い続ける
# - FASTSHIP_REF にブランチやタグを入れると、それを入れる (PR の動作確認用)
# - irm | iex は呼び出し元のセッションで実行されるので、全体を & { } で囲み、設定と変数を外に残さない
& {
    $ErrorActionPreference = 'Stop'

    $ref = if ($env:FASTSHIP_REF) { "@$env:FASTSHIP_REF" } else { '' }
    $source = "fastship @ git+https://github.com/theindiehacker/fastship-cli$ref"

    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Host 'fastship: uv をインストールします'
        Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
        $env:Path = "$env:USERPROFILE\.local\bin;$env:Path"
    }

    $bin = Join-Path (uv tool dir --bin) 'fastship.exe'
    if (Test-Path $bin) {
        Start-Process uv -ArgumentList 'tool', 'install', '--quiet', '--upgrade', "`"$source`"" -WindowStyle Hidden
        return
    }

    Write-Host 'fastship: インストールします'
    uv tool install --quiet $source
    if ($LASTEXITCODE -ne 0) { throw 'fastship: インストールに失敗しました' }

    if (-not (Get-Command fastship -ErrorAction SilentlyContinue)) {
        # uv tool のコマンドの置き場所 (既定 %USERPROFILE%\.local\bin) をユーザーの PATH に足す
        uv tool update-shell
        Write-Host "fastship: $bin を入れました。新しいターミナルから fastship を使えます"
    }
}
