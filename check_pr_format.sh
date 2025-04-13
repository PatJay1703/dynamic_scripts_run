#!/bin/bash

# Usage: ./check_pr_format.sh <pr_number> [base_branch] [source_repo_url]
# Example: ./check_pr_format.sh 123 main https://github.com/otheruser/repo.git

pr_number=$1
base_branch=${2:-main}
source_repo_url=$3


if [ -z "$pr_number" ]; then
    echo -e "\033[1;31m❌ Usage: $0 <pr_number> [base_branch] [source_repo_url]\033[0m"
    exit 1
fi

pr_branch="pr-$pr_number"
remote_name="temp-pr-remote"

if [ -n "$source_repo_url" ]; then
    echo -e "\033[1;34m🔗 Adding temporary remote from $source_repo_url...\033[0m"
    git remote add $remote_name "$source_repo_url" 2>/dev/null || true
    git fetch $remote_name pull/$pr_number/head:$pr_branch || { echo -e "\033[1;31m❌ Failed to fetch PR from forked repo\033[0m"; git remote remove $remote_name; exit 1; }
else
    echo -e "\033[1;34m📥 Fetching PR #$pr_number from origin...\033[0m"
    git fetch origin pull/$pr_number/head:$pr_branch || { echo -e "\033[1;31m❌ Failed to fetch PR from origin\033[0m"; exit 1; }
fi


extensions="c|cpp|cc|cxx|java|js|json|m|h|proto|cs"

echo -e "\033[1;36m🔍 Finding modified files between $base_branch and $pr_branch...\033[0m"
modified_files=$(git diff --name-only $base_branch $pr_branch | grep -E "\.(${extensions})$")

if [ -z "$modified_files" ]; then
    echo -e "\033[1;32m✅ No relevant files modified in this PR.\033[0m"
    [ -n "$source_repo_url" ] && git remote remove $remote_name
    exit 0
fi

echo -e "\033[1;33m📂 Modified files:\033[0m"
echo "$modified_files"


git checkout $pr_branch >/dev/null

echo -e "\033[1;35m🧼 Checking formatting issues with clang-format...\033[0m"
@@ -40,24 +46,19 @@ clang_output=$(git clang-format $base_branch --diff -- $modified_files)
if [ -n "$clang_output" ] && ! echo "$clang_output" | grep -q "no modified files to format"; then
    echo -e "\033[1;31m🚨 Format issues detected:\033[0m"
    echo -e "\033[1;37m--------------------------------------\033[0m"


    echo -e "\033[1;31mOriginal Code (Unformatted):\033[0m"
    echo "$clang_output" | grep -E "^\- " | cut -d ' ' -f 2-



    echo -e "\033[1;32m--------------------------------------\033[0m"
    echo -e "\033[1;32mFormatted Code (After git clang-format):\033[0m"

    echo "$clang_output" | grep -E "^\+ " | cut -d ' ' -f 2-

    echo -e "\033[1;37m--------------------------------------\033[0m"
    echo -e "\033[1;33m💡 Suggested Fix:\033[0m"
    echo -e "   \033[1;32mgit clang-format $base_branch\033[0m"
    echo -e "\033[1;34m📘 This will auto-fix the formatting for the changed lines.\033[0m"
    [ -n "$source_repo_url" ] && git remote remove $remote_name
    exit 1
else
    echo -e "\033[1;32m✅ No formatting issues detected!\033[0m"
    [ -n "$source_repo_url" ] && git remote remove $remote_name
    exit 0
fi