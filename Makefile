.DEFAULT_GOAL := help

DOCKER ?= docker
PLATFORM ?= linux/amd64,linux/arm64
IMAGE_NAME ?= dotfiles
IMAGE_TAG ?= latest
DOCKER_TAG := $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: build
build: build-ubuntu build-amazon

.PHONY: build-ubuntu
build-ubuntu: ## Build the Ubuntu Docker image
	$(DOCKER) buildx build --platform $(PLATFORM) -f ./build/Dockerfile.ubuntu -t ubuntu-$(DOCKER_TAG) .

.PHONY: build-amazon
build-amazon: ## Build the Amazon Linux Docker image
	$(DOCKER) buildx build --platform $(PLATFORM) -f ./build/Dockerfile.amazon -t amazon-$(DOCKER_TAG) .

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

.PHONY: clean
clean: ## Remove the built image
	-$(DOCKER) rmi $$($(DOCKER) images --format '{{.Repository}}:{{.Tag}}' | grep '$(DOCKER_TAG)')

.PHONY: help
help: ## Show this help
	@echo "Targets:"
	@echo "  build                  Build all Docker images"
	@echo "  build-ubuntu           Build the Ubuntu Docker image (multi-arch)"
	@echo "  build-amazon           Build the Amazon Linux Docker image (multi-arch)"
	@echo "  test                   Run chezmoi tests on all containers"
	@echo "  test-ubuntu            Run chezmoi test on the Ubuntu container"
	@echo "  test-amazon            Run chezmoi test on the Amazon Linux container"
	@echo "  clean                  Remove the built image"
	@echo ""
	@echo "Variables (override with VAR=value):"
	@echo "  IMAGE_NAME (default: $(IMAGE_NAME))"
	@echo "  IMAGE_TAG  (default: $(IMAGE_TAG))"
	@echo "  PLATFORM  (default: $(PLATFORM))"
