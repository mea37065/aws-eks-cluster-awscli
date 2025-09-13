.PHONY: help vpc eks destroy-eks destroy-vpc test clean lint

# Default target
help:
	@echo "Available targets:"
	@echo "  vpc          - Create VPC infrastructure"
	@echo "  eks          - Create EKS cluster"
	@echo "  addons       - Install cluster add-ons"
	@echo "  monitoring   - Install monitoring stack"
	@echo "  test         - Run cluster tests"
	@echo "  destroy-eks  - Destroy EKS cluster"
	@echo "  destroy-vpc  - Destroy VPC infrastructure"
	@echo "  clean        - Clean up generated files"
	@echo "  lint         - Run linting checks"

# Infrastructure targets
vpc:
	@echo "Creating VPC infrastructure..."
	./scripts/create-vpc.sh

eks: vpc
	@echo "Creating EKS cluster..."
	./scripts/create-eks.sh

addons:
	@echo "Installing cluster add-ons..."
	./scripts/install-addons.sh

monitoring:
	@echo "Installing monitoring stack..."
	./scripts/install-monitoring.sh

# Testing
test:
	@echo "Running cluster tests..."
	./tests/test-cluster.sh

# Destruction targets
destroy-eks:
	@echo "Destroying EKS cluster..."
	./scripts/destroy-eks.sh

destroy-vpc:
	@echo "Destroying VPC infrastructure..."
	./scripts/delete-vpc.sh

destroy-all: destroy-eks destroy-vpc

# Maintenance targets
clean:
	@echo "Cleaning up generated files..."
	rm -rf artifacts/
	rm -f .env

lint:
	@echo "Running linting checks..."
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck not installed"; exit 1; }
	shellcheck scripts/*.sh tests/*.sh
	@command -v yamllint >/dev/null 2>&1 || { echo "yamllint not installed"; exit 1; }
	yamllint manifests/ cloudformation/

# Terraform targets
tf-init:
	cd terraform && terraform init

tf-plan: tf-init
	cd terraform && terraform plan

tf-apply: tf-init
	cd terraform && terraform apply

tf-destroy: tf-init
	cd terraform && terraform destroy

# Development targets
dev-setup:
	@echo "Setting up development environment..."
	@command -v aws >/dev/null 2>&1 || { echo "AWS CLI not installed"; exit 1; }
	@command -v kubectl >/dev/null 2>&1 || { echo "kubectl not installed"; exit 1; }
	@command -v helm >/dev/null 2>&1 || { echo "helm not installed"; exit 1; }
	chmod +x scripts/*.sh tests/*.sh
	@echo "Development environment ready!"

# Quick deployment
quick-deploy: vpc eks addons test
	@echo "Quick deployment completed!"

# Full deployment with monitoring
full-deploy: vpc eks addons monitoring test
	@echo "Full deployment with monitoring completed!"