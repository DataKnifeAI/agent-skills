---
name: kubectl-cli
description: >-
  Uses kubectl to inspect and change Kubernetes clusters: resources, logs,
  exec, port-forward, rollouts, and apply. Apply when the user works with pods,
  deployments, services, namespaces, events, or cluster debugging from a shell.
---

# kubectl (`kubectl`)

## When to use

- List, describe, create, update, or delete API resources (pods, deployments, services, configmaps, secrets, CRDs, etc.).
- Stream logs, run commands in containers (`exec`), or port-forward to workloads.
- Inspect rollouts, scale workloads, or diff/apply manifests.
- Troubleshoot with events, `describe`, metrics (`top`), or debug sessions.

## Prerequisites

- `kubectl` installed (`kubectl version --client`). Documentation: [kubectl reference](https://kubernetes.io/docs/reference/kubectl/).
- **Cluster access**: valid kubeconfig (default `~/.kube/config`, or `KUBECONFIG` with one or more files).
- **Context**: `kubectl config current-context`; switch with `kubectl config use-context` or pass `--context` per command.
- **Namespace**: use `-n <namespace>` or `-A` / `--all-namespaces` when not using `default`.

## Patterns

- **Help**: `kubectl --help`, `kubectl <cmd> --help`, `kubectl explain <resource>[.<fieldPath>]`.
- **Output**: `-o wide`, `-o yaml`, `-o json`, `-o jsonpath='...'` for scripts; `--show-labels` when labels matter.
- **Selection**: `-l key=value`, resource/name arguments, `-f file` or `-k dir` (kustomize).
- **Dry run**: `kubectl apply --dry-run=server|client` (and `kubectl delete`/`create` dry-run flags per command help) before destructive changes.
- **Imperative vs declarative**: quick edits with `kubectl edit` / `kubectl patch`; repeatable changes with manifests + `kubectl apply`.

## Core commands (orienting)

| Area | Examples |
|------|----------|
| Discovery | `kubectl api-resources`, `kubectl get ns`, `kubectl get pods -n <ns>` |
| Inspect | `kubectl describe <type> <name> -n <ns>`, `kubectl get all -n <ns>` |
| Logs | `kubectl logs <pod> -n <ns>`, `kubectl logs -f ...`, `kubectl logs <pod> -c <container>` |
| Exec | `kubectl exec -it <pod> -n <ns> -- <cmd>` |
| Port forward | `kubectl port-forward svc/<name> <local>:<remote> -n <ns>` |
| Apply | `kubectl apply -f manifest.yaml`, `kubectl apply -k overlays/prod` |
| Rollout | `kubectl rollout status deployment/<name> -n <ns>`, `kubectl rollout undo ...` |
| Cluster | `kubectl cluster-info`, `kubectl top nodes`, `kubectl top pods -n <ns>` |

## Safety

- **Secrets**: avoid printing secret contents in logs; redact tokens in command output shared with users.
- **Destructive**: `delete`, `drain`, `replace --force`, and some `apply`/`patch` operations can disrupt workloads—match intent to the user’s request.
- **Production**: prefer explicit `--context` and `-n` in shared scripts to avoid the wrong cluster or namespace.

## References

- **Official documentation:** [kubectl reference](https://kubernetes.io/docs/reference/kubectl/)
- **Local help:** `kubectl help`, `kubectl <cmd> --help`, `kubectl explain <resource>` (authoritative for your installed `kubectl` version)
