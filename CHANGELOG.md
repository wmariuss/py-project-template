# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Relicensed from MIT to Apache-2.0.
- Packaging moved from `setup.py` and `setup.cfg` to PEP 621 metadata in
  `pyproject.toml`, built with hatchling.
- Dependency management moved from pipenv to uv, with a committed `uv.lock`.
- Linting and formatting consolidated into ruff, replacing black, pylint and
  pep8. Import sorting comes with it.
- The package is now `src/py_project_template/` instead of `src/`. The old
  layout installed a top level module called `src`, which collides with every
  other project that made the same mistake.
- The supported Python floor is 3.11, tested through 3.14. It was 3.6, which
  reached end of life in December 2021.
- The container image is multi-stage and runs as an unprivileged user.
- CI moved from Travis to GitHub Actions.

### Added

- `make check`: lint, types, tests with a coverage floor, and a dependency
  audit, identical to what CI enforces.
- `make rename`: renames the project, the package directory and the owner in
  one step.
- `make binary`: a standalone executable with CPython embedded, so the target
  needs no Python.
- Tag-driven release pipeline: distributions, standalone executables for Linux
  and macOS, a multi-architecture container image on GHCR, a CycloneDX SBOM,
  build provenance attestations, and optional PyPI publishing over Trusted
  Publishing.
- Real tests of the CLI, the `python -m` entry point and the console script.
- `CONTRIBUTING.md`, `SECURITY.md`, this changelog, a pull request template,
  Dependabot configuration, pre-commit hooks and an `.editorconfig`.

### Removed

- pex zipapp packaging through tox. A `.pex` still needs a compatible Python
  on the target; the executable that replaces it does not.
- `tasks.py`, `tox.ini`, `mypy.ini`, `.pylintrc`, `Pipfile`, `setup.py`,
  `setup.cfg`, `.travis.yml` and `docs/list.todo`.

### Fixed

- `author_email` was a list where setuptools expects a string.
- `Intended Audience :: End Users` is not a valid trove classifier, so
  `twine check` rejected the metadata.
- `.pylintrc` had no section header, which pylint 3 refuses to parse.
- The `tox -e package` command passed a stray `request` argument to pex.
- `.dockerignore` excluded `README.md`, which the wheel build reads.
