import click


@click.group()
@click.version_option()
def cli() -> None:
    """py project template description"""


@cli.command()
@click.option("--name", "-n", help="What is your name?")
def run(name: str) -> None:
    """
    Test function
    """
    if name:
        print(f"Hello {name}")
