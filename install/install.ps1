# FastShip CLI のインストーラ (Windows)。
#
#   irm https://registry.fastship.jp/cli/install.ps1 | iex
#
# - 最新のバージョンが入っていれば何もしない (Claude Code の SessionStart で毎回呼ばれるため)
# - 最新のバージョンを確かめられなくても、既に入っていれば失敗にしない
# - 環境変数 FASTSHIP_INSTALL_DIR (既定 %LOCALAPPDATA%\Programs\fastship) に置き、ユーザーの PATH に足す
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'  # 進捗表示があると Invoke-WebRequest が極端に遅くなる

$registry = if ($env:FASTSHIP_REGISTRY) { $env:FASTSHIP_REGISTRY } else { 'https://registry.fastship.jp' }
$baseUrl = "$registry/cli"
$installDir = if ($env:FASTSHIP_INSTALL_DIR) { $env:FASTSHIP_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA 'Programs\fastship' }
$bin = Join-Path $installDir 'fastship.exe'
$asset = 'fastship-windows-x64.exe'

if (-not [Environment]::Is64BitOperatingSystem) {
    throw 'fastship: 64 ビットの Windows だけに対応しています'
}

$installed = ''
if (Test-Path $bin) {
    try { $installed = (& $bin --version).Trim() } catch { }
}

try {
    $latest = (Invoke-RestMethod "$baseUrl/latest" -TimeoutSec 10).Trim()
} catch {
    if ($installed) {
        Write-Warning "fastship: 最新のバージョンを確かめられませんでした。$installed を使い続けます"
        return
    }
    throw "fastship: 最新のバージョンを取得できませんでした: $baseUrl/latest"
}
if ($installed -eq $latest) { return }

$tmp = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    $file = Join-Path $tmp $asset
    Write-Host "fastship: $latest をインストールします ($asset)"
    Invoke-WebRequest "$baseUrl/$latest/$asset" -OutFile $file -UseBasicParsing
    $sums = (Invoke-WebRequest "$baseUrl/$latest/SHA256SUMS" -UseBasicParsing).Content
    if ($sums -is [byte[]]) { $sums = [Text.Encoding]::UTF8.GetString($sums) }

    # -eq は大文字小文字を区別しないので、sha256sum (小文字) と Get-FileHash (大文字) をそのまま比べられる
    $expected = $null
    foreach ($line in ($sums -split "`n")) {
        $fields = $line.Trim() -split '\s+'
        if ($fields.Count -eq 2 -and $fields[1].TrimStart('*') -eq $asset) { $expected = $fields[0] }
    }
    $actual = (Get-FileHash $file -Algorithm SHA256).Hash
    if ($expected -ne $actual) {
        throw "fastship: チェックサムが一致しません: $asset"
    }

    New-Item -ItemType Directory -Force -Path $installDir | Out-Null
    Move-Item -Force $file $bin
    Write-Host "fastship: $bin に $latest をインストールしました"
} finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not (($userPath -split ';') -contains $installDir)) {
    [Environment]::SetEnvironmentVariable('Path', (@($userPath, $installDir) | Where-Object { $_ }) -join ';', 'User')
    $env:Path = "$env:Path;$installDir"
    Write-Host "fastship: ユーザーの PATH に $installDir を追加しました。新しいターミナルから使えます"
}
