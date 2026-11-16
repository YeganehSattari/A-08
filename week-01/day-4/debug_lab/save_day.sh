#!/usr/bin/env bash
set -euo pipefail
# save_day.sh - stage, commit and push today's work
# usage: ./save_day.sh WEEK DAY "type(scope): message"

week=${1:-}
day=${2:-}
msg=${3:-}

if [ -z "$msg" ]; then
  echo "usage: ./save_day.sh WEEK DAY \"type(scope): message\""
  exit 1
fi

write_gitignore() {
  cat > .gitignore <<EOF
.venv/
__pycache__/
.env
EOF
}

write_gitignore
git add -A
git add .gitignore

echo "== staged files =="
git diff --cached --name-only

git commit -q -m "$msg"
git push -q origin main
echo "saved week-$week/day-$day"
