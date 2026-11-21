# Manage Cursor agent skills (symlink/copy into .cursor/skills or ~/.cursor/skills).
# Run from the root of this repository unless using clone-install with --repo.

SHELL := /bin/bash

INSTALL_SCRIPT := $(CURDIR)/scripts/install-skills.sh
SKILLS_DIR := $(CURDIR)/skills
RULES_DIR := $(CURDIR)/rules

# Optional: comma-separated skill dirs, e.g. make install ONLY=gh-cli,kubectl-cli
ONLY ?=

INSTALL_FLAGS := $(if $(strip $(ONLY)),--only $(ONLY),)

CLONE_URL ?= https://github.com/DataKnifeAI/agent-skills.git
CACHE ?= $(HOME)/.cache/agent-skills

.DEFAULT_GOAL := help

.PHONY: help install install-user install-copy dry-run list validate clone-install clean-project

help: ## Show this help
	@echo "Targets (see also: $(INSTALL_SCRIPT) --help)"
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
	@rcount=0; \
	for f in "$(RULES_DIR)"/*.mdc; do \
	  [ -f "$$f" ] || continue; \
	  if [ ! -s "$$f" ]; then echo "empty rule: $$f" >&2; exit 1; fi; \
	  rcount=$$((rcount+1)); \
	done; \
	if [ "$$rcount" -eq 0 ]; then echo "error: no .mdc rules under $(RULES_DIR)" >&2; exit 1; fi; \
	echo "OK: $$rcount rule(s) under $(RULES_DIR)"

clone-install: ## Shallow-clone CLONE_URL into CACHE, then install skills to ./.cursor/skills
	@"$(INSTALL_SCRIPT)" --clone "$(CLONE_URL)" --cache "$(CACHE)" $(INSTALL_FLAGS)

clean-project: ## Remove ./.cursor/skills (project skill links only; destructive)
	@rm -rf "$(CURDIR)/.cursor/skills"
	@echo "removed $(CURDIR)/.cursor/skills"
