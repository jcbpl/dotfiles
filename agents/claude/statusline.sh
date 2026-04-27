#!/usr/bin/env bash
# Minimal Claude Code status line: project[worktree] • branch • model effort ctx% • cost • tokens.
# Reads session JSON from stdin (see https://code.claude.com/docs/en/statusline).

input=$(cat)

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
RESET='\033[0m'

eval "$(echo "$input" | jq -r '
  "cwd="           + (.workspace.current_dir // "" | @sh) + "\n" +
  "git_worktree="  + (.workspace.git_worktree // "" | @sh) + "\n" +
  "model="         + (.model.display_name // "" | @sh) + "\n" +
  "effort="        + (.effort.level // "" | @sh) + "\n" +
  "used_pct="      + (.context_window.used_percentage // 0 | tostring | @sh) + "\n" +
  "cost="          + (.cost.total_cost_usd // 0 | tostring | @sh) + "\n" +
  "input_tokens="  + (.context_window.total_input_tokens // 0 | tostring | @sh) + "\n" +
  "output_tokens=" + (.context_window.total_output_tokens // 0 | tostring | @sh)
')"

git_dir="${cwd:-.}"

# Repo name from the main working tree (parent of --git-common-dir),
# falling back to cwd basename outside a repo.
common=$(git -C "$git_dir" rev-parse --git-common-dir 2>/dev/null)
if [ -n "$common" ]; then
  common_abs=$(cd "$git_dir" 2>/dev/null && cd "$common" 2>/dev/null && pwd)
  repo_name=$(basename "$(dirname "$common_abs")")
elif [ -n "$cwd" ]; then
  repo_name=$(basename "$cwd")
else
  repo_name=""
fi

if [ -n "$repo_name" ] && [ -n "$git_worktree" ]; then
  project_seg="${CYAN}${repo_name}${RESET}${DIM}[${RESET}${CYAN}${git_worktree}${RESET}${DIM}]${RESET}"
elif [ -n "$repo_name" ]; then
  project_seg="${CYAN}${repo_name}${RESET}"
else
  project_seg=""
fi

if branch=$(git -C "$git_dir" -c core.fileMode=false rev-parse --abbrev-ref HEAD 2>/dev/null); then
  if git -C "$git_dir" -c core.fileMode=false diff-index --quiet HEAD -- 2>/dev/null; then
    git_seg="${GREEN}${branch}${RESET}"
  else
    git_seg="${YELLOW}${branch} *${RESET}"
  fi
else
  git_seg="${DIM}no git${RESET}"
fi

if [ -n "$effort" ]; then
  model_seg="${CYAN}${model}${RESET} ${DIM}${effort} ${used_pct}%${RESET}"
else
  model_seg="${CYAN}${model}${RESET} ${DIM}${used_pct}%${RESET}"
fi

cost_seg="${DIM}$(printf '$%.2f' "$cost")${RESET}"

fmt() {
  local n=$1
  if [ "$n" -ge 1000000 ] 2>/dev/null; then
    awk "BEGIN{printf \"%.1fM\", $n/1000000}"
  elif [ "$n" -ge 1000 ] 2>/dev/null; then
    echo "$(( n / 1000 ))k"
  else
    echo "$n"
  fi
}

total=$(( input_tokens + output_tokens ))
if [ "$total" -gt 0 ]; then
  tok_seg="${DIM}$(fmt $total) ⇡$(fmt $input_tokens) ⇣$(fmt $output_tokens)${RESET}"
else
  tok_seg=""
fi

SEP="${DIM} • ${RESET}"
parts=()
[ -n "$project_seg" ] && parts+=("$project_seg")
parts+=("$git_seg" "$model_seg" "$cost_seg")
[ -n "$tok_seg" ] && parts+=("$tok_seg")

out=""
for i in "${!parts[@]}"; do
  [ "$i" -gt 0 ] && out+="$SEP"
  out+="${parts[$i]}"
done

printf '%b' "$out"
