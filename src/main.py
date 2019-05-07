import click


@click.group()
@click.version_option()
def cli():
    """py project template description"""
    pass


@cli.command()
@click.option('--name', '-n', help="What is your name?")
def run(name):
    if name:
        print(f'Hello {name}')
