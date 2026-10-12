# 🚀 FastShip CLI

FastShip CLI は、セキュリティチェック・リント・フォーマットチェックを行う CLI です。
もともとは https://github.com/theindiehacker/devops で Taskfile + lefthook を社内に配布していましたが、Taskfile + lefthook の導入・同期が必要だったりするため、CLI でインストールしたら、動作するようにする。

## 💻 インストール

[uv](https://docs.astral.sh/uv/) が無ければ一緒に入ります。Python は uv が用意するので、事前に入れる必要はありません (git は必要です)。

<details><summary><b>macOS、Linux、WSL</b></summary>

```bash
curl -fsSL https://raw.githubusercontent.com/theindiehacker/fastship-cli/main/install/install.sh | bash
```

</details>

<details><summary><b>Windows</b></summary>

Windows PowerShell:
```powershell
irm https://raw.githubusercontent.com/theindiehacker/fastship-cli/main/install/install.ps1 | iex
```

</details>

2 回目以降に実行すると、最新の main への更新をバックグラウンドで行います (次に起動したときから反映されます)。

## 🪄 使い方

```bash
fastship check
fastship fix
```

<details><summary><b>Claude Code</b></summary>

`.claude/settings.json`: 
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "curl -fsSL https://raw.githubusercontent.com/theindiehacker/fastship-cli/main/install/install.sh | bash"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "fastship fix"
          },
          {
            "type": "command",
            "command": "fastship check"
          }
        ]
      }
    ]
  }
}
```

</details>
