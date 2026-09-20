# py-project-template

[![CI](https://github.com/wmariuss/py-project-template/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/wmariuss/py-project-template/actions/workflows/ci.yml)
[![Python](https://img.shields.io/badge/python-3.11%2B-3776AB)](https://www.python.org/)
[![Ruff](https://img.shields.io/badge/lint-ruff-D7FF64)](https://docs.astral.sh/ruff/)
[![uv](https://img.shields.io/badge/deps-uv-DE5FE9)](https://docs.astral.sh/uv/)
[![License](https://img.shields.io/github/license/wmariuss/py-project-template)](LICENSE)

A starting point for a Python command line tool that already has the parts
you would otherwise add in month three: a locked dependency set, one command
that runs every gate, a pipeline that builds and releases, and three ways to
ship it.

## Start here

```bash
gh repo create my-tool --template wmariuss/py-project-template --private --clone
cd my-tool
make rename NAME=my-tool OWNER=your-github-user
make install hooks
make check
```

`make rename` is the part worth knowing about. Renaming a template by hand
means editing a dozen files and missing two of them, usually the ones that
only break at release time. This renames the distribution, the import package,
the package directory, the console script and the owner in every tracked file,
re-locks, and then tells you which placeholders are prose that it could not
rename for you.

## What you get

| | |
| --- | --- |
| Packaging | PEP 621 metadata in `pyproject.toml`, built with hatchling |
| Dependencies | uv, with a committed `uv.lock` so every install is identical |
| Lint and format | ruff, which also does the import sorting |
| Types | mypy in strict mode |
| Tests | pytest with a coverage floor that fails the build |
| Security | `pip-audit` over the shipped dependencies, a CycloneDX SBOM |
| CI | lint, types, tests on Python 3.11 to 3.14, audit, wheel, image |
| Release | one tag, and everything below is built, signed and published |
| Ship as | a wheel, a container image, or a standalone executable |

## The one command

```bash
make check
```

Lint, types, tests with coverage, dependency audit. CI runs the same targets,
so passing here means passing there. That is deliberate: a pipeline that can
only be reproduced by pushing is a pipeline that wastes everyone's afternoon.

`make` on its own lists every target.

## Three ways to ship it

The right answer depends on one question: can you assume Python on the target?

### If yes, ship a wheel

```bash
uv tool install my-tool        # or: pipx install my-tool
uvx my-tool --help             # or run it without installing at all
```

This is the biggest change since this template was first written. `uvx` runs a
published tool in a throwaway environment with nothing to install and nothing
to clean up, which covers most of what a zipapp used to be for.

### If no, ship a standalone executable

```bash
make binary
```

That produces a single file with a portable CPython embedded in it. It runs on
a machine with no Python at all, and on a machine whose Python is the wrong
version, which is the case that actually bites.

Measured on this template at 0.1.0:

| | size | needs Python on the target |
| --- | --- | --- |
| `--scie eager` (the default here) | 123 MB | no |
| `--scie lazy` | 10 MB | no, fetches the interpreter on first run |
| a plain `.pex` zipapp | 1.1 MB | yes, and a compatible one |

Startup is about 0.26 s once warm. The size is the interpreter: there is no
way to bundle CPython and not pay for it.

This replaces the `tox -e package` pex target the template used to carry. It
is still pex underneath, but pex learned to build native executables, so the
output no longer depends on the target having the right Python. Switch to
`--scie lazy` in the Makefile if you would rather have a 10 MB download and a
slower first run.

### For servers and CI, ship the image

```bash
make docker-run
docker run --rm ghcr.io/wmariuss/py-project-template:latest run --name world
```

Multi-stage, dependencies cached in their own layer, runs as uid 10001. CI
fails if that ever regresses back to root.

## Releasing

```bash
# bump version in pyproject.toml, move CHANGELOG entries under a heading
git tag -a v0.2.0 -m "v0.2.0" && git push --tags
```

The pipeline refuses to go further if the tag and the version in
`pyproject.toml` disagree, then builds the wheel and sdist, the executables
for Linux x86_64, Linux arm64 and macOS arm64, and a multi-architecture image
on GHCR. Each artifact gets a build provenance attestation, a CycloneDX SBOM
is attached, and everything lands on a GitHub release.

PyPI publishing is wired up over Trusted Publishing, so there is no API token
in the repository. It stays off until you set the repository variable
`PUBLISH_TO_PYPI` to `true`, because a template should not publish itself.

## Layout

```
src/py_project_template/   the package, under src/ so tests run against the
                           installed copy rather than the working directory
  cli.py                   the click entry point
  __main__.py              so `python -m py_project_template` works
  py.typed                 so downstream mypy trusts the annotations
tests/                     real tests, not a placeholder that xfails
pyproject.toml             metadata and every tool's configuration
uv.lock                    the exact resolution, committed
Makefile                   every gate, identical to CI
Dockerfile                 multi-stage, non-root
.github/workflows/         ci.yml on every push, release.yml on a tag
```

## Decisions worth knowing about

**uv over pipenv and poetry.** It resolves in under a second, installs the
Python itself, and its lockfile is the whole environment. The lock is
committed, so CI, the container and your laptop resolve identically or the
build fails.

**ruff over black plus pylint plus isort plus pep8.** One tool, one config
block, one pass. The formatter is black-compatible, so nothing about the
resulting code looks unfamiliar.

**`src/` layout with a real package name.** The previous version of this
template shipped a package literally called `src`, so installing it put a top
level `src` module on the path where it collided with every other project that
made the same mistake. The `src/` directory is now a directory, not a package,
and tests import the installed distribution rather than whatever happens to be
in the working directory.

**A coverage floor, not a coverage target.** 90 percent, enforced. Raise it as
the project grows. Never lower it to make a build pass.

**The version lives in one place.** `pyproject.toml` holds it; `__init__.py`
reads it back out of the installed metadata. The release workflow checks the
tag against it before doing anything irreversible.

**Least privilege in the pipeline.** Workflows start at `contents: read` and
jobs opt into more. The job that pushes the image is the only one that can.

## Requirements

[uv](https://docs.astral.sh/uv/) and `make`. Docker only if you want the
image. uv installs the Python versions itself, so there is nothing else to set
up.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Security reports go through
[SECURITY.md](SECURITY.md), not the issue tracker.

## License

Apache-2.0, see [LICENSE](LICENSE).
