# Security

## Reporting a vulnerability

Please do not open a public issue. Report it privately through
[GitHub's advisory form](https://github.com/wmariuss/py-project-template/security/advisories/new),
or by email to me@marius.xyz.

Expect an acknowledgement within a few days and an assessment shortly after.

## What this project does about supply chain risk

- Dependencies are locked in `uv.lock`, so every install resolves to the same
  versions and hashes.
- `make audit` checks the locked, shipped dependencies against the Python
  advisory database, and CI fails on a known vulnerability.
- `make sbom` produces a CycloneDX SBOM, and every release ships one.
- Releases carry [build provenance attestations](https://docs.github.com/actions/security-guides/using-artifact-attestations).
  Verify one with `gh attestation verify <file> --repo wmariuss/py-project-template`.
- PyPI publishing uses Trusted Publishing, so there is no long-lived API token
  in this repository to leak.
- GitHub Actions are pinned to exact releases rather than floating majors, so
  nothing changes what runs without a commit in this repository.
- Dependabot opens weekly update pull requests for Python dependencies, GitHub
  Actions and the container base image.
- The container runs as an unprivileged user, and CI fails if that regresses.

## Worth enabling on a fork

GitHub's secret scanning and CodeQL default setup are both a single click in
repository settings and are not configured as code here.
