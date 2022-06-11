.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-40s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

TAG = "twindb/backup-test:$(shell git branch --no-color --show-current)"
.PHONY: help
help:
	@echo "Image will be tagged as $(TAG)\n"
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

.PHONY: build
build: ## Build image.
	@echo "Building image tagged as $(TAG)"
	docker build -t $(TAG) .


.PHONY: publish
publish: ## Publish image to hub.docker.com.
	@echo "Publishing image tagged as $(TAG)"
	docker push $(TAG)
