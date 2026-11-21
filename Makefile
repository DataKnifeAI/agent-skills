# Manage Cursor agent skills (symlink/copy into .cursor/skills or ~/.cursor/skills).
# Run from the root of this repository unless using clone-install with --repo.

SHELL := /bin/bash

INSTALL_SCRIPT := $(CURDIR)/scripts/install-skills.sh
RULES_SCRIPT := $(CURDIR)/scripts/install-rules.sh
SKILLS_DIR := $(CURDIR)/skills
RULES_DIR := $(CURDIR)/rules

# Optional: comma-separated skill dirs, e.g. make install ONLY=gh-cli,kubectl-cli
ONLY ?=

INSTALL_FLAGS := $(if $(strip $(ONLY)),--only $(ONLY),)

CLONE_URL ?= https://github.com/DataKnifeAI/agent-skills.git
CACHE ?= $(HOME)/.cache/agent-skills

.DEFAULT_GOAL := help

.PHONY: help install install-user install-copy dry-run list validate clone-install clean-project \
	install-rules install-rules-user install-rules-copy dry-run-rules list-rules validate-rules clone-install-rules clean-project-rules

help: ## Show this help
	@echo "Targets (see also: $(INSTALL_SCRIPT) --help, $(RULES_SCRIPT) --help)"
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

install: ## Install all skills into ./.cursor/skills (symlinks)
	@"$(INSTALL_SCRIPT)" $(INSTALL_FLAGS)

install-user: ## Install all skills into ~/.cursor/skills (symlinks)
	@"$(INSTALL_SCRIPT)" --user $(INSTALL_FLAGS)

install-copy: ## Copy skill trees into ./.cursor/skills (no symlinks)
	@"$(INSTALL_SCRIPT)" --copy $(INSTALL_FLAGS)

dry-run: ## Show what skill install would do (no filesystem changes)
	@"$(INSTALL_SCRIPT)" --dry-run $(INSTALL_FLAGS)

list: ## List skill directory names under skills/
	@ls -1 "$(SKILLS_DIR)"

validate: ## Ensure each skills/*/ has a SKILL.md; each rules/*.mdc is non-empty
	@missing=$$(find "$(SKILLS_DIR)" -mindepth 1 -maxdepth 1 -type d ! -exec test -f {}/SKILL.md \; -print); \
	if [ -n "$$missing" ]; then echo "missing SKILL.md:" >&2; echo "$$missing" >&2; exit 1; fi; \
	count=$$(find "$(SKILLS_DIR)" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d '[:space:]'); \
	if [ "$$count" -eq 0 ]; then echo "error: no skill directories under $(SKILLS_DIR)" >&2; exit 1; fi; \
	echo "OK: all skills under $(SKILLS_DIR) have SKILL.md"
	@$(MAKE) --no-print-directory validate-rules

install-rules: ## Install shared .mdc rules into ./.cursor/rules (symlinks)
	@"$(RULES_SCRIPT)" $(INSTALL_FLAGS)

install-rules-user: ## Install shared rules into ~/.cursor/rules (symlinks)
	@"$(RULES_SCRIPT)" --user $(INSTALL_FLAGS)

install-rules-copy: ## Copy shared .mdc rules into ./.cursor/rules (no symlinks)
	@"$(RULES_SCRIPT)" --copy $(INSTALL_FLAGS)

dry-run-rules: ## Show what rule install would do (no filesystem changes)
	@"$(RULES_SCRIPT)" --dry-run $(INSTALL_FLAGS)

list-rules: ## List shared rule basenames under rules/
	@ls -1 "$(RULES_DIR)"/*.mdc 2>/dev/null | xargs -n1 basename

validate-rules: ## Ensure each rules/*.mdc exists and is non-empty
	@count=0; \
	for f in "$(RULES_DIR)"/*.mdc; do \
	  [ -f "$$f" ] || continue; \
	  if [ ! -s "$$f" ]; then echo "empty rule: $$f" >&2; exit 1; fi; \
	  count=$$((count+1)); \
	done; \
	if [ "$$count" -eq 0 ]; then echo "error: no .mdc rules under $(RULES_DIR)" >&2; exit 1; fi; \
	echo "OK: $$count rule(s) under $(RULES_DIR)"

clone-install: ## Shallow-clone CLONE_URL into CACHE, then install skills to ./.cursor/skills
	@"$(INSTALL_SCRIPT)" --clone "$(CLONE_URL)" --cache "$(CACHE)" $(INSTALL_FLAGS)

clone-install-rules: ## Shallow-clone CLONE_URL into CACHE, then copy rules to ./.cursor/rules
	@"$(RULES_SCRIPT)" --clone "$(CLONE_URL)" --cache "$(CACHE)" --copy $(INSTALL_FLAGS)

clean-project: ## Remove ./.cursor/skills (project skill links only; destructive)
	@rm -rf "$(CURDIR)/.cursor/skills"
	@echo "removed $(CURDIR)/.cursor/skills"

clean-project-rules: ## Remove shared rule copies/links under ./.cursor/rules (keeps project overrides)
	@for f in "$(RULES_DIR)"/*.mdc; do \
	  [ -f "$$f" ] || continue; \
	  name=$$(basename "$$f"); \
	  rm -f "$(CURDIR)/.cursor/rules/$$name"; \
	  echo "removed $(CURDIR)/.cursor/rules/$$name"; \
	done
