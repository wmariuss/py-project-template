"""py-project-template: replace this with what your project does."""

from importlib.metadata import PackageNotFoundError, version

try:
    # The version lives in pyproject.toml and nowhere else. Reading it back
    # from the installed metadata keeps the two from drifting.
    __version__ = version("py-project-template")
except PackageNotFoundError:  # pragma: no cover - only when running from source
    __version__ = "0.0.0+unknown"

__all__ = ["__version__"]
