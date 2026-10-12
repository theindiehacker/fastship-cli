# 🚀 FastShip CLI

FastShip CLI は、セキュリティチェック・リント・フォーマットチェックを行う CLI です。
もともとは https://github.com/theindiehacker/devops で Taskfile + lefthook を社内に配布していましたが、Taskfile + lefthook の導入・同期が必要だったりするため、CLI でインストールしたら、動作するようにする。

## 💻 インストール

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
            "command": "fastship fix && fastship check"
          }
        ]
      }
    ]
  }
}
```

</details>
