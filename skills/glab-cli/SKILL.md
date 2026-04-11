---
name: glab-cli
description: >-
  Uses the GitLab CLI (`glab`) for merge requests, issues, CI/CD, releases, and
  GitLab API access from the terminal. Apply when the remote is GitLab
  (GitLab.com or self-managed) or when the user mentions MRs, pipelines, or
  GitLab projects.
---

# GitLab CLI (`glab`)

## When to use

- Create or review merge requests, issues, milestones, and labels from the shell.
- Inspect or retry pipelines and jobs (`glab ci`, `glab job`).
- Call the GitLab HTTP API via `glab api` with the same auth as the CLI.

## Prerequisites

- `glab` installed (`glab version`). Install and reference: [GitLab CLI documentation](https://docs.gitlab.com/cli/).
- **Auth**: `glab auth login` (interactive) or tokens. Common env vars:
  - `GITLAB_TOKEN` (or `GITLAB_ACCESS_TOKEN` / `OAUTH_TOKEN` per deployment)
  - `GITLAB_HOST` or `GL_HOST` for self-managed GitLab (e.g. `https://gitlab.example.com`)
- In **GitLab CI**, `GLAB_ENABLE_CI_AUTOLOGIN=true` can use `CI_JOB_TOKEN` for supported commands; token precedence is documented upstream.

## Patterns

- **Help**: `glab --help`, `glab <cmd> --help`.
- **Repo scope**: from current directory’s Git remote, or `-R group/project` / `--repo` where supported.
- **JSON**: many commands offer `-F json` or `--output json` (check each command’s help).

## Core commands (orienting)

| Area | Examples |
|------|----------|
| Auth | `glab auth status`, `glab auth login` |
| MRs | `glab mr list`, `glab mr create`, `glab mr view`, `glab mr checkout <id>`, `glab mr approve` |
| Issues | `glab issue list`, `glab issue create`, `glab issue view` |
| CI/CD | `glab ci view`, `glab ci list`, `glab job trace` (exact subcommands: `glab ci --help`) |
| Repo | `glab repo clone`, `glab repo view` |
| API | `glab api projects/:id` (paths and methods: `glab api --help`) |

## Safety

- Treat `GITLAB_TOKEN` like a password; never echo it in logs.
- Destructive operations (merge, delete, pipeline retry) require explicit user alignment.

## References

- **Official documentation:** [GitLab CLI](https://docs.gitlab.com/cli/)
- **Local help:** `glab --help`, `glab <cmd> --help` (authoritative for your installed `glab` version)
