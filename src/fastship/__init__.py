# 依存パッケージを持たない (標準ライブラリだけで書く)。
# install.sh は uv tool install で入れるため uv.lock が効かず、依存の新しい版がレビューを通らずに全員の端末へ入ってしまう
import argparse
from importlib.metadata import version


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="fastship",
        description="セキュリティチェック・リント・フォーマットチェックを行う CLI",
    )
    parser.add_argument("--version", action="version", version=version("fastship"))
    parser.parse_args()
    parser.print_help()
