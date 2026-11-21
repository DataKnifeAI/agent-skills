# Shared Cursor rules

Org-wide Cursor project rules for DataKnifeAI. **Vendor a copy** into each product repo at `.cursor/rules/dataknifeai-common.mdc` and commit it (plus thin project overrides). Day-to-day clones need no install step.

Canonical source stays in this repo under `rules/`.

## Layout

```text
rules/
  dataknifeai-common.mdc    # always-apply org defaults
  templates/
    project-override.mdc.example
```

## Refresh from canonical source (optional)

`install-rules.sh` / `make install-rules*` sync or refresh a vendored copy (and are useful for agent-workspace). They are **not** required for normal clone use.

From this checkout (prefer **copy** so product repos stay self-contained):

```bash
./scripts/install-rules.sh --copy
make install-rules-copy
```

Bootstrap a refresh without a local clone:

```bash
bash -c 'curl -fsSL https://raw.githubusercontent.com/DataKnifeAI/agent-skills/main/scripts/install-rules.sh | bash -s -- --clone https://github.com/DataKnifeAI/agent-skills.git --copy'
```

## Per-project overrides

1. Keep the vendored `dataknifeai-common.mdc` unmodified in the product repo.
2. Add `.cursor/rules/<project>.mdc` (copy from `templates/project-override.mdc.example`) for stack-specific guidance.
3. Use `globs` in frontmatter when a rule should apply only to certain files.

Do not fork the common rule in product repos — refresh the vendored file from this canonical source when the shared baseline changes.
