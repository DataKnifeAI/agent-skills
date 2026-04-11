---
name: coder-cli
description: >-
  Uses the Coder CLI (`coder`) to manage login, workspaces, SSH, port-forwarding,
  templates, and deployment URLs. Apply when the user works in Coder, needs to
  start/stop/update workspaces, connect over SSH, or troubleshoot connectivity.
---

# Coder CLI (`coder`)

## When to use

- Authenticate to a Coder deployment (`coder login`) or confirm session (`coder whoami`).
- List, create, start, stop, restart, delete, or open workspaces.
- SSH into a workspace or run a remote command; forward ports between laptop and workspace.
- Inspect workspace details, logs, or resource usage; manage templates or tokens when the user is an admin or template author.

## Prerequisites

- `coder` installed (`coder version`).
- **Deployment URL**: `--url` or `$CODER_URL`.
- **Auth**: `coder login` or `$CODER_SESSION_TOKEN` (prefer the env var for non-interactive use; see `coder login --help`).
- Global config directory: `$CODER_CONFIG_DIR` (default shown in `coder --help` under `--global-config`).

## Global flags (often relevant)

- `--url` / `$CODER_URL` — Coder deployment base URL.
- `--token` / `$CODER_SESSION_TOKEN` — session token.
- `--global-config` / `$CODER_CONFIG_DIR` — config path.

## Core commands (orienting)

| Area | Examples |
|------|----------|
| Session | `coder login`, `coder logout`, `coder whoami`, `coder version` |
| Workspaces | `coder list`, `coder create`, `coder show <name>`, `coder start`, `coder stop`, `coder restart`, `coder delete`, `coder update`, `coder open` |
| Access | `coder ssh <workspace>`, `coder ssh <workspace> -- <cmd>`, `coder port-forward <workspace>`, `coder config-ssh` |
| Info | `coder logs <workspace>`, `coder ping <workspace>`, `coder stat`, `coder speedtest` |
| Templates | `coder templates list`, `coder templates init` (see `--help` for create/plan/push flows) |
| Tokens | `coder tokens` (subcommands via `coder tokens --help`) |

Exact flags and subcommands vary by Coder version; always prefer `coder <cmd> --help` over guessing.

## Agent / automation notes

- Prefer **non-interactive** auth (`CODER_SESSION_TOKEN` + `CODER_URL`) in CI or headless agents when the user provides them.
- For long operations, use the CLI’s own flags for JSON or quiet output if available in that version.

## Safety

- Session tokens grant workspace access; never commit them or print them in full.
- `coder delete`, `coder state`, and admin commands can destroy data or affect other users—confirm scope.

## References

- `coder --help`, `coder <subcommand> --help`
- [Coder documentation](https://coder.com/docs) (CLI and workspaces)
