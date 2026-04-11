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

## Using in Coder workspaces (Cursor agents)

Cursor loads **project** skills from `.cursor/skills/<skill-name>/` in the workspace. To inject skills from this repo into a Coder workspace, pick one of these patterns:

1. **Clone + symlink (per skill)** — In the workspace startup script or template `startup_script`:

   ```bash
   git clone --depth 1 https://github.com/DataKnifeAI/agent-skills.git "$HOME/.cache/agent-skills"
   mkdir -p "$PWD/.cursor/skills"
   ln -sf "$HOME/.cache/agent-skills/skills/gh-cli" "$PWD/.cursor/skills/gh-cli"
   ln -sf "$HOME/.cache/agent-skills/skills/glab-cli" "$PWD/.cursor/skills/glab-cli"
   ln -sf "$HOME/.cache/agent-skills/skills/coder-cli" "$PWD/.cursor/skills/coder-cli"
   ln -sf "$HOME/.cache/agent-skills/skills/kubectl-cli" "$PWD/.cursor/skills/kubectl-cli"
   ```

   Point `git clone` at a branch, tag, or internal mirror if you pin versions.

2. **Single project checkout** — If the repo is already a submodule or checked out beside the project, symlink from that path into `.cursor/skills/` the same way.

3. **User-wide skills** — Alternatively install under `~/.cursor/skills/` on the image (bakes skills into the template for all workspaces on that image).

Ensure `glab`, `gh`, `coder`, and/or `kubectl` are on `PATH` in the workspace image (or install them in the template); the skills only document how to use the CLIs.

## License

This repository is licensed under the MIT License — see [LICENSE](LICENSE).
