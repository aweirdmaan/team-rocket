.PHONY: validate lint test help

help:
	@echo "Targets:"
	@echo "  make validate   Run all plugin self-checks (JSON, manifest, hooks, shellcheck)"
	@echo "  make lint       Alias for validate"
	@echo "  make test       Alias for validate"

validate:
	@bash scripts/validate.sh

lint: validate
test: validate
