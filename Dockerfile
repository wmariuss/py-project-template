# syntax=docker/dockerfile:1

# Pinned on purpose. A rebuild next month should produce the same image, and
# Dependabot keeps these current. Floating tags make builds unreproducible and
# turn an unrelated upstream change into an outage you cannot explain.
ARG PYTHON_VERSION=3.13
ARG UV_VERSION=0.12.17

FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv

FROM python:${PYTHON_VERSION}-slim AS builder

COPY --from=uv /uv /usr/local/bin/uv

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=never

WORKDIR /app

# Dependencies before source. This layer is invalidated only by a lockfile
# change, which is the difference between a two second and a ninety second
# rebuild on every code edit.
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

COPY . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

FROM python:${PYTHON_VERSION}-slim AS runtime

# Consumed by `docker buildx imagetools inspect`, by GHCR to link the image
# back to this repository, and by policy engines that refuse unlabelled images.
LABEL org.opencontainers.image.title="py-project-template" \
      org.opencontainers.image.description="Project description" \
      org.opencontainers.image.source="https://github.com/wmariuss/py-project-template" \
      org.opencontainers.image.licenses="Apache-2.0"

# Nothing here needs root. A process running as root in a container is one
# escape away from being root on the host, for no benefit at all.
RUN groupadd --system --gid 10001 app \
    && useradd --system --uid 10001 --gid app --no-log-init --create-home app

COPY --from=builder --chown=app:app /app /app

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

USER app
WORKDIR /app

ENTRYPOINT ["py-project-template"]
CMD ["--help"]
