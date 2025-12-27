# Compute repository root as the parent of this Makefile's directory (Makefile lives in test/)
ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)

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
	$(DOCKER) buildx build --platform $(PLATFORM) -f $(ROOT_DIR)/build/Dockerfile.ubuntu -t ubuntu-$(DOCKER_TAG) $(ROOT_DIR)

.PHONY: build-amazon
build-amazon: ## Build the Amazon Linux Docker image
	$(DOCKER) buildx build --platform $(PLATFORM) -f $(ROOT_DIR)/build/Dockerfile.amazon -t amazon-$(DOCKER_TAG) $(ROOT_DIR)

.PHONY: clean
clean: ## Remove the built image
	-$(DOCKER) rmi $$($(DOCKER) images --format '{{.Repository}}:{{.Tag}}' | grep '$(DOCKER_TAG)')

.PHONY: help
help: ## Show this help
	@echo "Targets:"
	@echo "  build-ubuntu           Build the Ubuntu Docker image (multi-arch)"
	@echo "  build-amazon           Build the Amazon Linux Docker image (multi-arch)"
	@echo "  clean                  Remove the built image"
	@echo ""
	@echo "Variables (override with VAR=value):"
	@echo "  IMAGE_NAME (default: $(IMAGE_NAME))"
	@echo "  IMAGE_TAG  (default: $(IMAGE_TAG))"
	@echo "  PLATFORM  (default: $(PLATFORM))"
