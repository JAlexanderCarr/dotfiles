.DEFAULT_GOAL := help

DOCKER     ?= docker
PLATFORM   ?= linux/amd64,linux/arm64
IMAGE_NAME ?= dotfiles
IMAGE_TAG  ?= latest
DOCKER_TAG := $(IMAGE_NAME):$(IMAGE_TAG)

# Dev container identity — override at build time:
#   make build-dev DEV_NAME="Alice" DEV_EMAIL="alice@example.com" DEV_GITHUB="alice"
DEV_NAME   ?= Developer
DEV_EMAIL  ?= dev@example.com
DEV_GITHUB ?= developer

.PHONY: build
build: build-ubuntu build-amazon

.PHONY: build-ubuntu
build-ubuntu: ## Build the Ubuntu Docker image
	$(DOCKER) buildx build --platform $(PLATFORM) -f ./build/Dockerfile.ubuntu -t ubuntu-$(DOCKER_TAG) .

.PHONY: build-amazon
build-amazon: ## Build the Amazon Linux Docker image
	$(DOCKER) buildx build --platform $(PLATFORM) -f ./build/Dockerfile.amazon -t amazon-$(DOCKER_TAG) .

.PHONY: build-manual
build-manual: ## Build the manual testing Docker image
	$(DOCKER) build -f ./build/Dockerfile.manual -t manual-$(DOCKER_TAG) .

.PHONY: build-dev
build-dev: ## Build the dev container image (single-arch, local use)
	$(DOCKER) build \
		--build-arg DEV_NAME="$(DEV_NAME)" \
		--build-arg DEV_EMAIL="$(DEV_EMAIL)" \
		--build-arg DEV_GITHUB="$(DEV_GITHUB)" \
		-f ./build/Dockerfile.dev \
		-t dev-$(DOCKER_TAG) .

.PHONY: shellcheck
shellcheck: ## Lint shell scripts (and rendered chezmoi templates) with shellcheck
	./test/shellcheck.sh

.PHONY: test
test: test-ubuntu test-amazon ## Run chezmoi tests on all containers

.PHONY: test-ubuntu
test-ubuntu: ## Run chezmoi test on the Ubuntu container
	$(DOCKER) run --rm \
		-v "$$(pwd):/dotfiles:ro" \
		ubuntu-$(DOCKER_TAG) \
		bash -c "cd /dotfiles && ./test/chezmoi-test.sh"

.PHONY: test-amazon
test-amazon: ## Run chezmoi test on the Amazon Linux container
	$(DOCKER) run --rm \
		-v "$$(pwd):/dotfiles:ro" \
		amazon-$(DOCKER_TAG) \
		bash -c "cd /dotfiles && ./test/chezmoi-test.sh"

.PHONY: test-dev
test-dev: ## Run smoke tests on the dev container (verifies chezmoi apply baked correctly)
	$(DOCKER) run --rm \
		-v "$$(pwd):/dotfiles:ro" \
		dev-$(DOCKER_TAG) \
		zsh /dotfiles/test/dev-test.sh

.PHONY: dev
dev: ## Launch dev container interactively (mounts cwd as /workspace, passes SSH agent)
	$(DOCKER) run -it --rm \
		-v "$$(pwd):/workspace" \
		-w /workspace \
		$(if $(SSH_AUTH_SOCK),-v "$(SSH_AUTH_SOCK):/run/ssh-agent.sock" -e SSH_AUTH_SOCK=/run/ssh-agent.sock) \
		dev-$(DOCKER_TAG) \
		zsh

.PHONY: version
version: ## Show the current dev container version (latest git tag)
	@git describe --tags --abbrev=0 2>/dev/null || echo "missing"

.PHONY: release-dev
release-dev: ## Trigger a manual dev container release via GitHub Actions (VERSION=YYYY.MM.PATCH required)
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION required. Usage: make release-dev VERSION=2026.04.0"; \
		exit 1; \
	fi
	gh workflow run release.yaml --field version=$(VERSION)

.PHONY: manual-test
manual-test: ## Launch manual test container with zsh for interactive chezmoi testing
	@echo ""
	@echo "==== Manual Chezmoi Testing ===="
	@echo ""
	@echo "To test chezmoi installation, run one of the following inside the container:"
	@echo ""
	@echo "  # Initialize from your GitHub dotfiles repo:"
	@echo "  chezmoi init --apply <github-username>"
	@echo ""
	@echo "  # Or initialize from local dotfiles (mounted at /dotfiles):"
	@echo "  chezmoi init --source /dotfiles --apply"
	@echo ""
	@echo "  # Switch to bash if needed:"
	@echo "  bash"
	@echo ""
	@echo "================================"
	@echo ""
	$(DOCKER) run -it --rm \
		-v "$$(pwd):/dotfiles:ro" \
		manual-$(DOCKER_TAG) \
		zsh

.PHONY: clean
clean: ## Remove all built images matching IMAGE_TAG
	-$(DOCKER) rmi $$($(DOCKER) images --format '{{.Repository}}:{{.Tag}}' | grep '$(DOCKER_TAG)')

.PHONY: help
help: ## Show this help
	@echo "Targets:"
	@echo "  build                  Build all Docker images (ubuntu + amazon)"
	@echo "  build-ubuntu           Build the Ubuntu Docker image (multi-arch)"
	@echo "  build-amazon           Build the Amazon Linux Docker image (multi-arch)"
	@echo "  build-manual           Build the manual testing Docker image"
	@echo "  build-dev              Build the dev container image (single-arch)"
	@echo "  shellcheck             Lint shell scripts and rendered chezmoi templates"
	@echo "  test                   Run chezmoi tests on all containers"
	@echo "  test-ubuntu            Run chezmoi test on the Ubuntu container"
	@echo "  test-amazon            Run chezmoi test on the Amazon Linux container"
	@echo "  test-dev               Run smoke tests on the dev container"
	@echo "  manual-test            Launch manual test container with zsh"
	@echo "  dev                    Launch dev container interactively (SSH agent passed through)"
	@echo "  version                Show the current dev container version (latest git tag)"
	@echo "  release-dev            Trigger a manual dev container release (VERSION=YYYY.MM.PATCH)"
	@echo "  clean                  Remove all built images matching IMAGE_TAG"
	@echo ""
	@echo "Variables (override with VAR=value):"
	@echo "  IMAGE_NAME  (default: $(IMAGE_NAME))"
	@echo "  IMAGE_TAG   (default: $(IMAGE_TAG))"
	@echo "  PLATFORM    (default: $(PLATFORM))"
	@echo "  DEV_NAME    (default: $(DEV_NAME))"
	@echo "  DEV_EMAIL   (default: $(DEV_EMAIL))"
	@echo "  DEV_GITHUB  (default: $(DEV_GITHUB))"
