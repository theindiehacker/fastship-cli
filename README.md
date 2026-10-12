# 🚀 FastShip CLI

FastShip CLI は、セキュリティチェック・リント・フォーマットチェックを行う CLI です。
もともとは https://github.com/theindiehacker/devops で Taskfile + lefthook を社内に配布していましたが、Taskfile + lefthook の導入・同期が必要だったりするため、CLI でインストールしたら、動作するようにする。

## 💻 インストール

<details><summary><b>macOS、Linux、WSL</b></summary>

```bash
curl -fsSL https://registry.fastship.jp/cli/install.sh | bash
```

</details>

<details><summary><b>Windows</b></summary>

Windows PowerShell:
```bash
irm https://registry.fastship.jp/cli/install.ps1 | iex
```

Windows CMD:
```bash
curl -fsSL https://registry.fastship.jp/cli/install.cmd -o install.cmd && install.cmd && del install.cmd
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
            "command": "curl -fsSL https://registry.fastship.jp/cli/install.sh | bash"
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
