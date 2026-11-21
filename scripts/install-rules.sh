#!/usr/bin/env bash
# Install DataKnifeAI shared Cursor rules into .cursor/rules (symlink or copy).
# See rules/README.md — default target is ./.cursor/rules (project rules).

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install-rules.sh [options]

  Default: symlink every *.mdc from this repo's rules/ into ./.cursor/rules
  (create dirs as needed). Skips rules/README.md and anything under rules/templates/.

Options:
  -u, --user          Install to ~/.cursor/rules instead of ./.cursor/rules
  -p, --project       Install to ./.cursor/rules (default)
  -t, --target DIR    Install .mdc files under DIR
  -r, --repo DIR      Path to agent-skills checkout (directory containing rules/).
                      Default: parent of this script's directory.
  --clone URL         Shallow-clone URL into the cache, then install from that tree.
                      Updates with git pull --ff-only when the cache already exists.
  --cache DIR         Clone/update directory for --clone (default: $XDG_CACHE_HOME/agent-skills or ~/.cache/agent-skills)
  --only LIST         Comma-separated rule basenames without .mdc (e.g. dataknifeai-common)
  -c, --copy          Copy .mdc files instead of symlinking (preferred for product repos)
  -n, --dry-run       Print actions without changing the filesystem
  -h, --help          Show this help

Examples:
  ./scripts/install-rules.sh --copy
  ./scripts/install-rules.sh --user
  ./scripts/install-rules.sh --clone https://github.com/DataKnifeAI/agent-skills.git --copy
  curl -fsSL https://raw.githubusercontent.com/DataKnifeAI/agent-skills/main/scripts/install-rules.sh | bash -s -- --clone https://github.com/DataKnifeAI/agent-skills.git --copy
EOF
}

DEST_MODE=project
DEST_CUSTOM=
REPO_ROOT=""
CLONE_URL=""
CACHE="${XDG_CACHE_HOME:-${HOME}/.cache}/agent-skills"
ONLY_LIST=""
INSTALL_MODE=symlink
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -u | --user) DEST_MODE=user; shift ;;
    -p | --project) DEST_MODE=project; shift ;;
    -t | --target)
      DEST_CUSTOM="${2:?}"
      shift 2
      ;;
    -r | --repo)
      REPO_ROOT="${2:?}"
      shift 2
      ;;
    --clone)
      CLONE_URL="${2:?}"
      shift 2
      ;;
    --cache)
      CACHE="${2:?}"
      shift 2
      ;;
    --only)
      ONLY_LIST="${2:?}"
      shift 2
      ;;
    -c | --copy) INSTALL_MODE=copy; shift ;;
    -n | --dry-run) DRY_RUN=1; shift ;;
    -h | --help) usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -n "$CLONE_URL" ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] would clone/update: $CLONE_URL -> $CACHE"
  else
    mkdir -p "$(dirname "$CACHE")"
    if [[ -d "$CACHE/.git" ]]; then
      git -C "$CACHE" pull --ff-only
    else
      rm -rf "$CACHE"
      git clone --depth 1 "$CLONE_URL" "$CACHE"
    fi
  fi
  REPO_ROOT="$CACHE"
fi

if [[ -z "$REPO_ROOT" ]]; then
  _here="${BASH_SOURCE[0]-}"
  if [[ -z "$_here" || "$_here" == "-" ]]; then
    echo "error: cannot infer repo path when the script is read from stdin; use --clone URL or --repo DIR" >&2
    exit 1
  fi
  _SCRIPT_DIR="$(cd "$(dirname "$_here")" && pwd)"
  _CAND="$(cd "$_SCRIPT_DIR/.." && pwd)"
  if [[ -d "$_CAND/rules" ]]; then
    REPO_ROOT="$_CAND"
  else
    echo "error: could not find agent-skills checkout (expected rules/ next to scripts/); use --clone URL or --repo DIR" >&2
    exit 1
  fi
fi

RULES_SRC="$REPO_ROOT/rules"

if [[ -n "$DEST_CUSTOM" ]]; then
  DEST="$DEST_CUSTOM"
elif [[ "$DEST_MODE" == user ]]; then
  DEST="${HOME}/.cursor/rules"
else
  DEST="${PWD}/.cursor/rules"
fi

if [[ ! -d "$RULES_SRC" ]]; then
  if [[ "$DRY_RUN" -eq 1 && -n "$CLONE_URL" ]]; then
    echo "[dry-run] after clone, would install from $RULES_SRC to $DEST (mode=$INSTALL_MODE)"
    [[ -n "$ONLY_LIST" ]] && echo "[dry-run] --only $ONLY_LIST"
    exit 0
  fi
  echo "error: rules directory not found: $RULES_SRC" >&2
  exit 1
fi

ALL_RULES=()
shopt -s nullglob
for f in "$RULES_SRC"/*.mdc; do
  [[ -f "$f" ]] || continue
  ALL_RULES+=("$(basename "$f" .mdc)")
done
shopt -u nullglob
mapfile -t ALL_RULES < <(printf '%s\n' "${ALL_RULES[@]}" | sort)

if [[ ${#ALL_RULES[@]} -eq 0 ]]; then
  echo "error: no .mdc rules under $RULES_SRC" >&2
  exit 1
fi

TO_INSTALL=()
if [[ -z "$ONLY_LIST" ]]; then
  TO_INSTALL=("${ALL_RULES[@]}")
else
  IFS=',' read -ra _raw <<<"$ONLY_LIST"
  for name in "${_raw[@]}"; do
    name="${name//[[:space:]]/}"
    name="${name%.mdc}"
    [[ -n "$name" ]] || continue
    found=0
    for a in "${ALL_RULES[@]}"; do
      if [[ "$a" == "$name" ]]; then
        found=1
        break
      fi
    done
    if [[ "$found" -eq 0 ]]; then
      echo "error: unknown rule '$name' (not under $RULES_SRC)" >&2
      exit 1
    fi
    TO_INSTALL+=("$name")
  done
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[dry-run] REPO_ROOT=$REPO_ROOT"
  echo "[dry-run] DEST=$DEST"
  echo "[dry-run] mode=$INSTALL_MODE"
  for name in "${TO_INSTALL[@]}"; do
    echo "[dry-run] $INSTALL_MODE $RULES_SRC/$name.mdc -> $DEST/$name.mdc"
  done
  exit 0
fi

mkdir -p "$DEST"

for name in "${TO_INSTALL[@]}"; do
  src="$RULES_SRC/$name.mdc"
  dst="$DEST/$name.mdc"
  if [[ ! -f "$src" ]]; then
    echo "error: missing rule file: $src" >&2
    exit 1
  fi
  if [[ "$INSTALL_MODE" == symlink ]]; then
    ln -sfn "$src" "$dst"
  else
    cp -f "$src" "$dst"
  fi
  echo "installed: $dst"
done
