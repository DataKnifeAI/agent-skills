#!/usr/bin/env bash
# Install DataKnifeAI agent skills into Cursor's skills directory (symlink or copy).
# See README.md — default target is ./.cursor/skills (project skills).

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install-skills.sh [options]

  Default: symlink every skill from this repo into ./.cursor/skills (create dirs as needed).

Options:
  -u, --user          Install to ~/.cursor/skills instead of ./.cursor/skills
  -p, --project       Install to ./.cursor/skills (default)
  -t, --target DIR    Install under DIR (each skill becomes DIR/<name>)
  -r, --repo DIR      Path to agent-skills checkout (directory containing skills/).
                      Default: parent of this script's directory.
  --clone URL         Shallow-clone URL into the cache, then install from that tree.
                      Updates with git pull --ff-only when the cache already exists.
  --cache DIR         Clone/update directory for --clone (default: $XDG_CACHE_HOME/agent-skills or ~/.cache/agent-skills)
  --only LIST         Comma-separated skill dirs to install (e.g. gh-cli,kubectl-cli)
  -c, --copy          Copy skill dirs instead of symlinking
  -n, --dry-run       Print actions without changing the filesystem
  -h, --help          Show this help

Examples:
  ./scripts/install-skills.sh
  ./scripts/install-skills.sh --user
  ./scripts/install-skills.sh --clone https://github.com/DataKnifeAI/agent-skills.git
  curl -fsSL https://raw.githubusercontent.com/DataKnifeAI/agent-skills/main/scripts/install-skills.sh | bash -s -- --clone https://github.com/DataKnifeAI/agent-skills.git --only gh-cli
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
  if [[ -d "$_CAND/skills" ]]; then
    REPO_ROOT="$_CAND"
  else
    echo "error: could not find agent-skills checkout (expected skills/ next to scripts/); use --clone URL or --repo DIR" >&2
    exit 1
  fi
fi

SKILLS_SRC="$REPO_ROOT/skills"

if [[ -n "$DEST_CUSTOM" ]]; then
  DEST="$DEST_CUSTOM"
elif [[ "$DEST_MODE" == user ]]; then
  DEST="${HOME}/.cursor/skills"
else
  DEST="${PWD}/.cursor/skills"
fi

if [[ ! -d "$SKILLS_SRC" ]]; then
  if [[ "$DRY_RUN" -eq 1 && -n "$CLONE_URL" ]]; then
    echo "[dry-run] after clone, would install from $SKILLS_SRC to $DEST (mode=$INSTALL_MODE)"
    [[ -n "$ONLY_LIST" ]] && echo "[dry-run] --only $ONLY_LIST"
    exit 0
  fi
  echo "error: skills directory not found: $SKILLS_SRC" >&2
  exit 1
fi

ALL_SKILLS=()
shopt -s nullglob
for d in "$SKILLS_SRC"/*/; do
  [[ -d "$d" ]] || continue
  ALL_SKILLS+=("$(basename "${d%/}")")
done
shopt -u nullglob
mapfile -t ALL_SKILLS < <(printf '%s\n' "${ALL_SKILLS[@]}" | sort)

if [[ ${#ALL_SKILLS[@]} -eq 0 ]]; then
  echo "error: no skill directories under $SKILLS_SRC" >&2
  exit 1
fi

TO_INSTALL=()
if [[ -z "$ONLY_LIST" ]]; then
  TO_INSTALL=("${ALL_SKILLS[@]}")
else
  IFS=',' read -ra _raw <<<"$ONLY_LIST"
  for name in "${_raw[@]}"; do
    name="${name//[[:space:]]/}"
    [[ -n "$name" ]] || continue
    found=0
    for a in "${ALL_SKILLS[@]}"; do
      if [[ "$a" == "$name" ]]; then
        found=1
        break
      fi
    done
    if [[ "$found" -eq 0 ]]; then
      echo "error: unknown skill '$name' (not under $SKILLS_SRC)" >&2
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
    echo "[dry-run] $INSTALL_MODE $SKILLS_SRC/$name -> $DEST/$name"
  done
  exit 0
fi

mkdir -p "$DEST"

for name in "${TO_INSTALL[@]}"; do
  src="$SKILLS_SRC/$name"
  dst="$DEST/$name"
  if [[ ! -d "$src" ]]; then
    echo "error: missing skill directory: $src" >&2
    exit 1
  fi
  if [[ "$INSTALL_MODE" == symlink ]]; then
    ln -sfn "$src" "$dst"
  else
    rm -rf "$dst"
    cp -a "$src" "$dst"
  fi
  echo "installed: $dst"
done
