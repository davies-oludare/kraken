#!/bin/bash
set -uo pipefail

# Usage: ./terraform_all.sh [apply|plan]
# Default action is 'apply'
ACTION="${1:-apply}"
if [[ "$ACTION" != "apply" && "$ACTION" != "plan" ]]; then
  echo "Invalid action: $ACTION" >&2
  echo "Usage: $0 [apply|plan]" >&2
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

# Collect candidate customer directories (portable for macOS bash)
CUSTOMER_DIRS=()
for d in "$ROOT_DIR"/*; do
  base="$(basename "$d")"
  if [[ -d "$d" && "$base" != ".terraform" && "$base" != ".git" ]]; then
    if [[ -d "$d/workspaces" && -d "$d/deployments" ]]; then
      CUSTOMER_DIRS+=("$d")
    fi
  fi
done

if [[ ${#CUSTOMER_DIRS[@]} -eq 0 ]]; then
  echo "No customer directories found (expected subfolders with workspaces/ and deployments/)." >&2
  exit 1
fi

printf "Discovered %s customer directories:\n" "${#CUSTOMER_DIRS[@]}"
for d in "${CUSTOMER_DIRS[@]}"; do
  echo "- ${d##*/}"
done

declare -a FAILURES

run_terraform_for_path() {
  local path="$1"
  local env_name="$2" # workspaces or deployments

  printf "\n=== %s (%s) ===\n" "${path#$ROOT_DIR/}" "$env_name"
  if ! terraform -chdir="$path" init -upgrade -input=false; then
    echo "[ERROR] init failed: ${path}"
    FAILURES+=("${path}:init")
    return
  fi

  if ! terraform -chdir="$path" plan -input=false -out=tfplan; then
    echo "[ERROR] plan failed: ${path}"
    FAILURES+=("${path}:plan")
    return
  fi

  if [[ "$ACTION" == "apply" ]]; then
    if ! terraform -chdir="$path" apply -input=false -auto-approve tfplan; then
      echo "[ERROR] apply failed: ${path}"
      FAILURES+=("${path}:apply")
      return
    fi
  fi
}

for customer_dir in "${CUSTOMER_DIRS[@]}"; do
  for sub in workspaces deployments; do
    path="$customer_dir/$sub"
    if [[ -d "$path" ]]; then
      run_terraform_for_path "$path" "$sub"
    fi
  done
done

if [[ ${#FAILURES[@]} -gt 0 ]]; then
  printf "\nCompleted with errors in %s locations:\n" "${#FAILURES[@]}" >&2
  for f in "${FAILURES[@]}"; do
    echo "- $f" >&2
  done
  exit 2
fi

printf "\nAll done: terraform %s completed successfully for all customer folders.\n" "$ACTION"

