from importlib.metadata import version
from typing import Annotated

import typer

app = typer.Typer(no_args_is_help=True)


def _print_version(value: bool) -> None:
    # install.sh / install.ps1 は、この出力と /cli/latest を比べて更新するかを決める
    if value:
        typer.echo(version("fastship"))
        raise typer.Exit()


@app.callback()
def callback(
    _version: Annotated[
        bool,
        typer.Option(
            "--version",
            callback=_print_version,
            is_eager=True,
            help="バージョンを表示する",
        ),
    ] = False,
) -> None:
    """セキュリティチェック・リント・フォーマットチェックを行う CLI"""


def main() -> None:
    app()
