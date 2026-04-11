# DataKnifeAI agent skills

Shared [Cursor agent skills](https://cursor.com/docs/context/skills) (and compatible tooling) for DataKnifeAI repositories.

## Layout

Each skill is a directory with a `SKILL.md` file (and optional scripts or reference docs):

```text
skills/
  <skill-name>/
    SKILL.md
    scripts/          # optional
```

## Monorepo vs one repo per skill

**Default: use this single monorepo** for org-wide skills.

- **One change, one PR**: review, versioning, and CI stay simple.
- **Consistent conventions**: naming, frontmatter, and folder shape are easy to enforce in one place.
- **Easy discovery**: contributors browse one tree; release notes can summarize what changed.
- **Installation**: teams symlink, submodule, or copy the skill they need from `skills/<name>/` without juggling many remotes.

**Split into separate repositories** only when a skill is large enough to deserve its own lifecycle—for example, heavy automation with its own test matrix, frequent independent releases, or reuse outside DataKnifeAI with a distinct identity. Even then, a monorepo with clear ownership per folder is often enough until pain shows up.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md` with YAML frontmatter (`name`, `description`) and clear instructions.
2. Open a PR; keep scope to one new skill or one focused change per PR when possible.

## License

Add a `LICENSE` file when the org chooses a default policy for this repository.
