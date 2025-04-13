#!/bin/bash

# Usage: ./run_all_checks.sh <pr_number> [base_branch] [source_repo_url] [--skip=script1.sh,script2.sh]

pr_number=$1
base_branch=${2:-main}
source_repo_url=$3
skip_list=""

if [ -z "$pr_number" ]; then
    echo -e "\033[1;31m❌ Usage: $0 <pr_number> [base_branch] [source_repo_url] [--skip=script1.sh,script2.sh]\033[0m"
    exit 1
fi

# Handle optional skip flag
for arg in "$@"; do
  if [[ $arg == --skip=* ]]; then
    skip_list="${arg#--skip=}"
  fi
done

IFS=',' read -r -a skip_scripts <<< "$skip_list"

# List all check scripts here (they should be in the same directory)
scripts=(
  "check_pr_format.sh"
  "check_docs.sh"
)

echo -e "\033[1;36m📂 Running checks for PR #$pr_number on local repo...\033[0m"

for script in "${scripts[@]}"; do
  if [[ " ${skip_scripts[@]} " =~ " ${script} " ]]; then
    echo -e "\033[1;33m⏭️  Skipping $script\033[0m"
    continue
  fi

  if [ ! -f "$script" ]; then
    echo -e "\033[1;31m⚠️  Script $script not found, skipping...\033[0m"
    continue
  fi

  echo -e "\033[1;34m🚀 Running $script...\033[0m"
  bash "$script" "$pr_number" "$base_branch" "$source_repo_url" &
done

wait
echo -e "\033[1;32m✅ All checks completed on local repo.\033[0m"
