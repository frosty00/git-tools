#!/bin/bash

dry_run=0
max_threads=5
active_threads=0
remote='github'
lockfile='threads'

if [[ "$#" -gt 1 ]]; then
  echo 'Usage prune [--dry-run]'
  exit 1
fi

if [[ -f $lockfile ]]; then
  echo "lockfile $(pwd)/$lockfile already exists"
  exit 1
fi

echo $active_threads > $lockfile

declare -a branches

function in_array {
  local key="$1"
  local exists=0
  for ((i=0; i<n; i++)); do
    branch="${branches[$i]}"
    if [[ $branch == "$key" ]]; then
      exists=1
      break
    fi
  done
  echo $exists
}

function delete_in_thread {
  local branch="$1"
  git push "$remote" --delete "$branch"
  # this is needed because it runs in a background process
  active_threads=$(< $lockfile)
  ((active_threads--))
  if [[ active_threads -eq 0 ]]; then
    rm $lockfile
  else
    echo "$active_threads" > $lockfile
  fi
}

if [[ $1 == "--dry-run" ]]; then
  dry_run=1
fi

n=0
for branch in $(git branch | sed 's/\*//g' ); do
  branches[$n]="$branch"
  ((n++))
done

remote_branches="$(git ls-remote --head github | grep -Eo "([a-zA-Z0-9>_\-]*)$" )"

for branch in $remote_branches; do
  sleep 0.1
  exists=$(in_array "$branch")
  if [[ $exists -eq 1 ]]; then
    echo "skipping $remote/$branch"
  else
    echo "deleting $remote/$branch"
    if [[ $dry_run -eq 0 ]]; then
      active_threads=$(< $lockfile)
      ((active_threads++))
      echo "$active_threads" > $lockfile
      while [[ $active_threads -gt $max_threads ]]; do
          active_threads=$(< $lockfile)
      done
      delete_in_thread "$branch" &
    fi
  fi
done
