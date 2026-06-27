#!/usr/bin/env bash
# Launch a Cursor self-hosted worker for EvolutionSimGame on this machine.
#
# Usage:
#   ./scripts/start-self-hosted-worker.sh          # start worker (My Machines)
#   ./scripts/start-self-hosted-worker.sh debug    # preflight diagnostics
#   ./scripts/start-self-hosted-worker.sh --help
#
# Configuration: copy .cursor/worker.env.example → .cursor/worker.env
# Docs: https://cursor.com/docs/cloud-agent/my-machines
#       https://cursor.com/docs/cloud-agent/self-hosted-pool

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${REPO_ROOT}/.cursor/worker.env"
LABELS_FILE="${REPO_ROOT}/.cursor/worker.labels.toml"

usage() {
  cat <<'EOF'
Usage: start-self-hosted-worker.sh [debug] [--help]

Start or debug a Cursor self-hosted worker bound to this repository.

Commands:
  (none)   Start the worker and keep it connected.
  debug    Run preflight diagnostics (auth, privacy, routing, repo labels).

Setup:
  cp .cursor/worker.env.example .cursor/worker.env
  agent login
  ./scripts/start-self-hosted-worker.sh debug
  ./scripts/start-self-hosted-worker.sh

Select the worker in Cursor: Cloud Agents → environment dropdown.
EOF
}

die() {
  echo "error: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "'$1' not found. Install the Cursor CLI: curl https://cursor.com/install -fsS | bash"
}

load_env() {
  if [[ -f "${ENV_FILE}" ]]; then
    # shellcheck disable=SC1090
    set -a
    source "${ENV_FILE}"
    set +a
  elif [[ ! -f "${REPO_ROOT}/.cursor/worker.env.example" ]]; then
    die "missing ${ENV_FILE}. Copy .cursor/worker.env.example to .cursor/worker.env"
  else
    echo "note: ${ENV_FILE} not found; using defaults. Copy .cursor/worker.env.example to customize."
  fi
}

default_worker_name() {
  local host
  host="$(hostname -s 2>/dev/null || hostname)"
  echo "evolutionsimgame-${host}"
}

validate_repo() {
  [[ -d "${REPO_ROOT}/.git" ]] || die "not a git repository: ${REPO_ROOT}"
  git -C "${REPO_ROOT}" remote get-url origin >/dev/null 2>&1 \
    || die "origin remote not configured. Workers register via the git remote in --worker-dir."
}

build_worker_args() {
  WORKER_ARGS=()

  local worker_name="${CURSOR_WORKER_NAME:-$(default_worker_name)}"
  WORKER_ARGS+=(--name "${worker_name}")
  WORKER_ARGS+=(--worker-dir "${REPO_ROOT}")

  if [[ -f "${LABELS_FILE}" ]]; then
    WORKER_ARGS+=(--labels-file "${LABELS_FILE}")
  fi

  if [[ "${CURSOR_WORKER_POOL:-false}" == "true" ]]; then
    WORKER_ARGS+=(--pool)
    if [[ -n "${CURSOR_WORKER_POOL_NAME:-}" ]]; then
      WORKER_ARGS+=(--pool-name "${CURSOR_WORKER_POOL_NAME}")
    fi
    if [[ -n "${CURSOR_WORKER_IDLE_RELEASE_TIMEOUT:-}" ]]; then
      WORKER_ARGS+=(--idle-release-timeout "${CURSOR_WORKER_IDLE_RELEASE_TIMEOUT}")
    fi
  fi

  if [[ -n "${CURSOR_WORKER_MANAGEMENT_ADDR:-}" ]]; then
    WORKER_ARGS+=(--management-addr "${CURSOR_WORKER_MANAGEMENT_ADDR}")
  fi

  if [[ -n "${CURSOR_DATA_DIR:-}" ]]; then
    WORKER_ARGS+=(--data-dir "${CURSOR_DATA_DIR}")
  fi
}

run_debug() {
  echo "Repository: ${REPO_ROOT}"
  echo "Origin:     $(git -C "${REPO_ROOT}" remote get-url origin)"
  echo "Worker:     ${CURSOR_WORKER_NAME:-$(default_worker_name)}"
  echo "Mode:       $([[ "${CURSOR_WORKER_POOL:-false}" == "true" ]] && echo "pool" || echo "my-machines")"
  echo
  agent worker "${WORKER_ARGS[@]}" debug --json
}

run_start() {
  local start_args=(start)
  if [[ "${CURSOR_WORKER_VERBOSE:-false}" == "true" ]]; then
    start_args+=(--verbose)
  fi

  echo "Starting Cursor self-hosted worker for EvolutionSimGame"
  echo "  repo:   ${REPO_ROOT}"
  echo "  name:   ${CURSOR_WORKER_NAME:-$(default_worker_name)}"
  echo "  mode:   $([[ "${CURSOR_WORKER_POOL:-false}" == "true" ]] && echo "pool" || echo "my-machines")"
  echo
  echo "Keep this process running. Select the worker in Cursor → Cloud Agents."
  echo "Press Ctrl+C to stop."
  echo

  exec agent worker "${WORKER_ARGS[@]}" "${start_args[@]}"
}

main() {
  local command="${1:-start}"
  if [[ "${command}" == "--help" || "${command}" == "-h" ]]; then
    usage
    exit 0
  fi

  require_command agent
  require_command git
  load_env
  validate_repo
  build_worker_args

  case "${command}" in
    debug)
      run_debug
      ;;
    start)
      run_start
      ;;
    *)
      usage
      die "unknown command: ${command}"
      ;;
  esac
}

main "$@"
