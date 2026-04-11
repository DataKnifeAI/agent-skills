---
name: gh-cli
description: >-
  Uses the GitHub CLI (`gh`) from the terminal for auth, repos, issues, PRs,
  Actions, API calls, and browsing. Apply when the user or task involves
  GitHub operations, CI status, or authenticated GitHub API access from a shell.
---

# GitHub CLI (`gh`)

## When to use

- Inspect or change GitHub resources (repos, PRs, issues, Actions, releases) without opening the browser first.
- Run authenticated `gh api` for endpoints not wrapped by a subcommand.
- The workspace may be a Coder VM or local machine; prefer **non-interactive** flags in scripts and agent-driven runs.

## Prerequisites

- `gh` installed (`gh version`). Documentation: [GitHub CLI manual](https://cli.github.com/manual/).
- Authentication: `gh auth status`. If needed, `gh auth login` (interactive) or token-based flows documented in `gh auth login --help`.

## Patterns

- **Help**: `gh help`, `gh <cmd> --help` (e.g. `gh pr create --help`).
- **Current repo context**: many commands infer the repo from `git` remotes in the working directory. Override with `-R owner/repo` when needed.
- **JSON / scripting**: many commands support `--json` and `-q` / `--jq` for machine-readable output.
- **API**: `gh api <endpoint> [-X METHOD] [-f key=value ...]` for REST; use `-H` as needed.

## Core commands (orienting)

| Area | Examples |
|------|----------|
| Auth | `gh auth status`, `gh auth login`, `gh auth token` |
| PRs | `gh pr list`, `gh pr view`, `gh pr create`, `gh pr checkout <n>`, `gh pr merge` |
| Issues | `gh issue list`, `gh issue create`, `gh issue view` |
| Repo | `gh repo view`, `gh repo clone`, `gh repo create` |
| Actions | `gh run list`, `gh run view`, `gh workflow run` |
| Search | `gh search repos`, `gh search issues`, `gh search prs` |
| Browse | `gh browse` (opens browser) |

## Safety

- Do not paste or log tokens. Prefer env vars and `gh`’s own credential storage.
- For destructive actions (merge, delete branch, close issues), confirm intent matches the user’s request.

## References

- **Official documentation:** [GitHub CLI manual](https://cli.github.com/manual/)
- **Local help:** `gh help`, `gh <cmd> --help` (authoritative for your installed `gh` version)
