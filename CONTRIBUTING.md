# Contributing

## Getting set up

```bash
make install   # creates .venv and installs the project with its dev group
make hooks     # runs the gates before each commit and push
```

You need [uv](https://docs.astral.sh/uv/). Everything else, Python included,
uv installs for you.

## The one command

```bash
make check
```

That runs lint, type checking, tests with a coverage floor, and a dependency
audit. It is exactly what CI runs, so if it passes here it passes there. If
you find a way to make CI fail while `make check` passes, that is a bug in
this repository and worth reporting on its own.

## Working on a change

1. Branch off `develop`.
2. Write the test first where you can. A bug fix without a regression test is
   a bug fix that comes back.
3. `make format` rewrites the code to the house style. Do not argue with it.
4. Add an entry to `CHANGELOG.md` under Unreleased.
5. Open a pull request against `develop`.

## Commits

One logical change per commit. Write the subject in the imperative and use the
body to say why, not what: the diff already says what.

## Releasing

Maintainers only.

1. Move the Unreleased entries in `CHANGELOG.md` under a new version heading.
2. Bump `version` in `pyproject.toml`.
3. Tag it: `git tag -a v1.2.3 -m "v1.2.3" && git push --tags`.

The release workflow refuses to continue if the tag and the version in
`pyproject.toml` disagree, then builds the distributions, the standalone
executables and the container image, attaches provenance attestations, and
publishes.
