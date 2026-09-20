"""Tests for the command line interface.

click's CliRunner invokes the command the way a shell does, so these cover
argument parsing and exit codes, not just the function bodies.
"""

import subprocess
import sys
from importlib.metadata import entry_points

from click.testing import CliRunner

from py_project_template import __version__
from py_project_template.cli import cli


def test_version_is_reported() -> None:
    result = CliRunner().invoke(cli, ["--version"])
    assert result.exit_code == 0
    assert __version__ in result.output


def test_help_lists_the_commands() -> None:
    result = CliRunner().invoke(cli, ["--help"])
    assert result.exit_code == 0
    assert "run" in result.output


def test_run_greets() -> None:
    result = CliRunner().invoke(cli, ["run", "--name", "Ada"])
    assert result.exit_code == 0
    assert result.output.strip() == "Hello Ada"


def test_run_without_a_name_is_a_usage_error() -> None:
    result = CliRunner().invoke(cli, ["run"])
    assert result.exit_code == 2
    assert "Missing option" in result.output


def test_verbose_does_not_change_stdout() -> None:
    quiet = CliRunner().invoke(cli, ["run", "--name", "Ada"])
    loud = CliRunner().invoke(cli, ["--verbose", "run", "--name", "Ada"])
    assert loud.exit_code == 0
    assert loud.output == quiet.output


def test_module_entry_point_runs() -> None:
    """`python -m py_project_template` has to keep working.

    It runs in its own process, so coverage cannot see it. This is the only
    thing standing between a broken `__main__.py` and a user finding out.
    """
    result = subprocess.run(
        [sys.executable, "-m", "py_project_template", "--version"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert __version__ in result.stdout


def test_console_script_is_installed() -> None:
    """The entry point in pyproject.toml has to resolve to a real callable."""
    scripts = entry_points(group="console_scripts")
    assert "py-project-template" in {script.name for script in scripts}
