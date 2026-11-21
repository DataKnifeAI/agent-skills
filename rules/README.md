# Shared Cursor rules

Org-wide Cursor project rules for DataKnifeAI. Install into a product repo’s `.cursor/rules/` (or `~/.cursor/rules/` for user scope).

## Layout

```text
rules/
  dataknifeai-common.mdc    # always-apply org defaults
  templates/
    project-override.mdc.example
```

## Install

From this checkout (prefer **copy** into product repos so clones work without a sibling checkout):

```bash
./scripts/install-rules.sh --copy
make install-rules
```

Bootstrap without a local clone:

```bash
bash -c 'curl -fsSL https://raw.githubusercontent.com/DataKnifeAI/agent-skills/main/scripts/install-rules.sh | bash -s -- --clone https://github.com/DataKnifeAI/agent-skills.git --copy'
```

## Per-project overrides

1. Keep `dataknifeai-common.mdc` installed and unmodified.
2. Add `.cursor/rules/<project>.mdc` (copy from `templates/project-override.mdc.example`) for stack-specific guidance.
3. Use `globs` in frontmatter when a rule should apply only to certain files.

Do not fork the common rule in product repos — refresh it with `install-rules.sh --copy` when the shared baseline changes.
