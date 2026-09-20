# The gates you run locally are the gates CI runs. If you only remember one
# target, remember `make check`: it is exactly what the pipeline enforces.
.DEFAULT_GOAL := help

DIST     := py-project-template
PACKAGE  := py_project_template
REPO_OWNER := wmariuss

UV       ?= uv
BUILD    := build

# The Python embedded in the standalone executable, and the pex that builds
# it. Both pinned: a build tool that floats is a build that is not reproducible.
PYTHON_VERSION ?= 3.13
PEX_VERSION    := 2.103.2
IMAGE    ?= ghcr.io/$(REPO_OWNER)/$(DIST)
TAG      ?= $(or $(shell git rev-parse --short HEAD 2>/dev/null),dev)

.PHONY: help install hooks format lint typecheck test cov audit sbom check \
	build binary docker docker-run run clean rename

help: ## List the targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

install: ## Create the virtualenv and install the project with its dev group
	$(UV) sync

hooks: install ## Install the git hooks so the gates run before you commit
	$(UV) run pre-commit install --install-hooks

format: ## Rewrite the code to the house style
	$(UV) run ruff format .
	$(UV) run ruff check --fix .

lint: ## Check style and common bugs without rewriting anything
	$(UV) run ruff format --check .
	$(UV) run ruff check .

typecheck: ## Check types under mypy strict
	$(UV) run mypy

test: ## Run the tests with coverage enforced
	$(UV) run pytest --cov --cov-report=term --cov-report=xml:$(BUILD)/coverage.xml

cov: test ## Run the tests and open the HTML coverage report path
	$(UV) run coverage html -d $(BUILD)/htmlcov
	@echo "open $(BUILD)/htmlcov/index.html"

audit: ## Check the shipped dependencies for known vulnerabilities
	@mkdir -p $(BUILD)
	$(UV) export --frozen --no-dev --no-emit-project \
		--format requirements.txt -o $(BUILD)/requirements.txt
	$(UV) tool run pip-audit --strict --requirement $(BUILD)/requirements.txt

sbom: ## Write a CycloneDX SBOM of what ships
	@mkdir -p $(BUILD)
	$(UV) export --frozen --no-dev --format cyclonedx1.5 -o $(BUILD)/sbom.json
	@echo "wrote $(BUILD)/sbom.json"

check: lint typecheck test audit ## Everything CI enforces, in one command

build: ## Build the sdist and the wheel
	$(UV) build --out-dir $(BUILD)/dist

binary: build ## Build a standalone executable that needs no Python on the target
	@mkdir -p $(BUILD)/bin
	$(UV) tool run --from pex==$(PEX_VERSION) pex \
		$(BUILD)/dist/*.whl \
		--console-script $(DIST) \
		--scie eager --scie-only \
		--scie-python-version $(PYTHON_VERSION) \
		--output-file $(BUILD)/bin/$(DIST)
	@ls -lh $(BUILD)/bin/$(DIST)

docker: ## Build the container image
	docker build -t $(IMAGE):$(TAG) -t $(IMAGE):latest .

docker-run: docker ## Build the image and run the CLI inside it
	docker run --rm $(IMAGE):$(TAG) run --name world

run: ## Run the CLI from the working tree
	$(UV) run $(DIST) $(ARGS)

clean: ## Remove build output and caches
	rm -rf $(BUILD) dist .coverage coverage.xml .pytest_cache .mypy_cache .ruff_cache
	find . -name __pycache__ -type d -prune -exec rm -rf {} +

# Renaming by hand means touching a dozen files and forgetting two of them.
# This does the whole thing, including the package directory, and leaves the
# result ready to commit.
rename: ## Make it yours: make rename NAME=my-tool [OWNER=me]
	@test -n "$(NAME)" || { echo "NAME is required, e.g. make rename NAME=my-tool"; exit 1; }
	@echo "$(NAME)" | grep -Eq '^[a-z][a-z0-9-]*$$' \
		|| { echo "NAME must be lowercase letters, digits and hyphens"; exit 1; }
	@mod=$$(echo "$(NAME)" | tr '-' '_'); \
	echo "  $(PACKAGE) -> $$mod"; \
	echo "  $(DIST) -> $(NAME)"; \
	git ls-files -z ':!uv.lock' \
		| xargs -0 sed -i "s/$(PACKAGE)/$$mod/g; s/$(DIST)/$(NAME)/g"; \
	git mv src/$(PACKAGE) src/$$mod; \
	if [ -n "$(OWNER)" ]; then \
		echo "  $(REPO_OWNER) -> $(OWNER)"; \
		git ls-files -z ':!uv.lock' | xargs -0 sed -i "s/$(REPO_OWNER)/$(OWNER)/g"; \
	fi; \
	rm -f uv.lock; $(UV) lock; \
	echo ""; \
	echo "Renamed. Three placeholders are prose and cannot be renamed for you:"; \
	echo "  pyproject.toml  project.description"; \
	echo "  Dockerfile      the image description label"; \
	echo "  README.md       all of it"; \
	echo "Review with 'git diff', then reset CHANGELOG.md to your own history."
