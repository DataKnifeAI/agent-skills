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

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md` with YAML frontmatter (`name`, `description`) and clear instructions.
2. Open a PR; keep scope to one new skill or one focused change per PR when possible.

## Install (Cursor / Coder workspaces)

Cursor loads **project** skills from `.cursor/skills/<skill-name>/` in the workspace (or **user** skills from `~/.cursor/skills/`).

### Installer script

From a checkout of this repository:

```bash
./scripts/install-skills.sh              # ./.cursor/skills (symlinks)
./scripts/install-skills.sh --user       # ~/.cursor/skills
./scripts/install-skills.sh --only gh-cli,kubectl-cli
./scripts/install-skills.sh --copy       # copy trees instead of symlinks
```

Bootstrap from GitHub without cloning the full repo yourself (shallow clone to the cache, then symlink into `./.cursor/skills`):

```bash
bash -c 'curl -fsSL https://raw.githubusercontent.com/DataKnifeAI/agent-skills/main/scripts/install-skills.sh | bash -s -- --clone https://github.com/DataKnifeAI/agent-skills.git'
```

Use `--clone` with an internal mirror URL if your deployment mirrors this repo. Override the cache directory with `--cache DIR`. Run `./scripts/install-skills.sh --help` for all options.

### Manual install

If you prefer not to use the script: clone or submodule this repo, then symlink each `skills/<name>/` directory into `.cursor/skills/<name>/`, or install under `~/.cursor/skills/`.

Ensure `glab`, `gh`, `coder`, `kubectl`, and/or `rancher` are on `PATH` in the workspace image when those skills apply; the skills document CLI usage only.

## License

This repository is licensed under the MIT License — see [LICENSE](LICENSE).
