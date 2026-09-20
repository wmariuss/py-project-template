"""Command line interface."""

import logging
import sys

import click

from py_project_template import __version__

logger = logging.getLogger(__name__)


def _configure_logging(verbose: bool) -> None:
    """Send logs to stderr so stdout stays usable for real output.

    A CLI that mixes diagnostics into stdout cannot be piped. Keeping the two
    streams separate is the cheapest thing you can do for whoever scripts this.
    """
    logging.basicConfig(
        level=logging.DEBUG if verbose else logging.INFO,
        format="%(asctime)s %(levelname)-8s %(name)s %(message)s",
        stream=sys.stderr,
    )


@click.group(context_settings={"help_option_names": ["-h", "--help"]})
@click.option("-v", "--verbose", is_flag=True, help="Log at debug level.")
@click.version_option(version=__version__, prog_name="py-project-template")
def cli(verbose: bool) -> None:
    """py-project-template: replace this with what your tool does."""
    _configure_logging(verbose)


@cli.command()
@click.option("--name", "-n", required=True, help="What is your name?")
def run(name: str) -> None:
    """Greet someone, as a stand-in for real work."""
    logger.debug("greeting %s", name)
    click.echo(f"Hello {name}")
