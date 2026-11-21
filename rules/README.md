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

## How to use in a product repo

1. Copy [`dataknifeai-common.mdc`](dataknifeai-common.mdc) into the product repo at `.cursor/rules/dataknifeai-common.mdc` and commit it.
2. Add project overrides as needed (see below).
3. When the org baseline changes, refresh by re-copying this canonical file into the product repo.

## Per-project overrides

1. Keep the vendored `dataknifeai-common.mdc` unmodified in the product repo.
2. Add `.cursor/rules/<project>.mdc` (copy from `templates/project-override.mdc.example`) for stack-specific guidance.
3. Use `globs` in frontmatter when a rule should apply only to certain files.

Do not fork the common rule in product repos — refresh the vendored file from this canonical source when the shared baseline changes.
