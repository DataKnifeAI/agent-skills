---
name: rancher-cli
description: >-
  Uses the Rancher CLI (`rancher`) to log into Rancher Server, select a project
  context, and run cluster/project operations including passthrough `kubectl`.
  Apply when the user manages Rancher projects, clusters, or workloads through
  Rancher rather than a raw kubeconfig alone.
---

# Rancher CLI (`rancher`)

## When to use

- Authenticate to a **Rancher Server** and work in terms of Rancher **projects** and **clusters**.
- Switch **context** to the project/cluster scope before running resource commands.
- Run **`rancher kubectl …`** to execute kubectl against the cluster associated with the current Rancher context.
- Inspect Rancher or Kubernetes resources via `inspect`, list workloads with `ps`, or use subcommands such as `clusters`, `projects`, `namespaces`, `nodes`, `machines`.

## Prerequisites

- `rancher` binary installed (often downloaded from the Rancher UI **CLI Downloads** or [rancher/cli releases](https://github.com/rancher/cli/releases)). Documentation: [Rancher CLI](https://ranchermanager.docs.rancher.com/reference-guides/cli-with-rancher/rancher-cli).
- **Rancher Server URL** and a **Bearer API token** ([API keys](https://ranchermanager.docs.rancher.com/reference-guides/user-settings/api-keys)).
- After login, **select a project** with `rancher context switch` before most operations; config is stored (e.g. `~/.ranchcli2.json` per upstream docs).

## Patterns

- **Help**: `rancher --help`, `rancher <cmd> --help`.
- **Login**: `rancher login https://<SERVER_URL> --token <BEARER_TOKEN>`. Self-signed certs may prompt to continue.
- **Context**: `rancher context switch` — pick the Rancher **project** (cluster + project) to target.
- **kubectl**: `rancher kubectl get pods` (and other kubectl subcommands) once context is valid.
- **Inspect**: `rancher inspect` for Kubernetes or Rancher resources (see command help for options and resource IDs).

## Core commands (orienting)

| Area | Examples |
|------|----------|
| Session | `rancher login`, `rancher token` (kubeconfig token; see `--help`) |
| Context | `rancher context switch` |
| Clusters / projects | `rancher clusters`, `rancher projects` (see `--help` for subcommands) |
| Workloads | `rancher ps`, `rancher namespaces` |
| kubectl | `rancher kubectl get pods`, `rancher kubectl describe …` |
| Nodes / SSH | `rancher nodes`, `rancher ssh` (see `--help`) |
| Other | `rancher inspect`, `rancher settings`, `rancher wait`, `rancher up` |

Exact subcommands and flags depend on the CLI version; prefer `rancher <cmd> --help`.

## Limitations

- The Rancher CLI **cannot** install Rancher dashboard apps or feature charts via Helm in the way the UI/charts flow does — see the [official docs](https://ranchermanager.docs.rancher.com/reference-guides/cli-with-rancher/rancher-cli#limitations).

## Safety

- Treat API bearer tokens like passwords; do not log or commit them.
- Operations on clusters, nodes, or workloads can be destructive — align with the user’s intent and environment (prod vs non-prod).

## References

- **Official documentation:** [Rancher CLI](https://ranchermanager.docs.rancher.com/reference-guides/cli-with-rancher/rancher-cli)
- **Local help:** `rancher --help`, `rancher <cmd> --help` (authoritative for your installed `rancher` version)
