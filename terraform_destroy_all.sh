#!/bin/bash
set -euo pipefail

# Usage:
#   ./terraform_destroy_all.sh            # destroy with auto-approve (non-interactive)
#   ./terraform_destroy_all.sh --prompt   # ask for confirmation per folder

AUTO_APPROVE=true
if [[ "${1:-}" == "--prompt" ]]; then
  AUTO_APPROVE=false
elif [[ "${1:-}" == "--auto-approve" || -z "${1:-}" ]]; then
  AUTO_APPROVE=true
else
  echo "Unknown option: ${1:-}" >&2
  echo "Usage: $0 [--auto-approve|--prompt]" >&2
  exit 1
fi

if ! command -v terraform >/dev/null 2>&1; then
  echo "Terraform is not installed or not in PATH" >&2
  exit 1
fi

if [[ -z "${ASTRO_API_TOKEN:-}" ]]; then
  echo "ASTRO_API_TOKEN is not set. Export it before running." >&2
  echo "Example: export ASTRO_API_TOKEN=\"<your-token>\"" >&2
  exit 1
fi

ROOT_DIR="$(pwd)"

# Collect candidate customer directories: any top-level folder with both workspaces/ and deployments/
mapfile -t CUSTOMER_DIRS < <(find "$ROOT_DIR" -mindepth 1 -maxdepth 1 -type d \
  ! -name ".terraform" \
  ! -name ".git" \
  -exec bash -c '[ -d "$1/workspaces" ] && [ -d "$1/deployments" ] && echo "$1"' _ {} \;)

if [[ ${#CUSTOMER_DIRS[@]} -eq 0 ]]; then
  echo "No customer directories found (expected subfolders with workspaces/ and deployments/)." >&2
  exit 1
fi

echo "Discovered ${#CUSTOMER_DIRS[@]} customer directories:"
for d in "${CUSTOMER_DIRS[@]}"; do
  echo "- ${d##*/}"
fi

declare -a FAILURES

run_destroy_for_path() {
  local path="$1"
  local env_name="$2" # workspaces or deployments

  echo -e "\n=== ${path#$ROOT_DIR/} (${env_name}) ==="

  # Ensure providers/modules are available
  if ! terraform -chdir="$path" init -upgrade -input=false; then
    echo "[ERROR] init failed: ${path}"
    FAILURES+=("${path}:init")
    return
  fi

  local DESTROY_ARGS=( -input=false )
  if [[ "$AUTO_APPROVE" == true ]]; then
    DESTROY_ARGS+=( -auto-approve )
  fi

  if ! terraform -chdir="$path" destroy "${DESTROY_ARGS[@]}"; then
    echo "[ERROR] destroy failed: ${path}"
    FAILURES+=("${path}:destroy")
    return
  fi
}

for customer_dir in "${CUSTOMER_DIRS[@]}"; do
  # Destroy deployments first (they depend on workspaces)
  if [[ -d "$customer_dir/deployments" ]]; then
    run_destroy_for_path "$customer_dir/deployments" deployments
  fi
  # Then destroy workspaces
  if [[ -d "$customer_dir/workspaces" ]]; then
    run_destroy_for_path "$customer_dir/workspaces" workspaces
  fi
done

if [[ ${#FAILURES[@]} -gt 0 ]]; then
  echo -e "\nCompleted with errors in ${#FAILURES[@]} locations:" >&2
  for f in "${FAILURES[@]}"; do
    echo "- $f" >&2
  done
  exit 2
fi

echo -e "\nAll done: terraform destroy completed successfully for all customer folders."
