@echo off
REM FastShip CLI installer for Windows CMD. It just runs install.ps1.
REM Keep this file ASCII-only: cmd.exe parses it with the console code page.
REM
REM   curl -fsSL https://registry.fastship.jp/cli/install.cmd -o install.cmd && install.cmd && del install.cmd
REM
REM irm decodes install.ps1 as UTF-8 (the registry sends charset=utf-8), while -File would read it as ANSI on Windows PowerShell 5.1.
setlocal
if not defined FASTSHIP_REGISTRY set "FASTSHIP_REGISTRY=https://registry.fastship.jp"
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm '%FASTSHIP_REGISTRY%/cli/install.ps1' | iex"
exit /b %ERRORLEVEL%
