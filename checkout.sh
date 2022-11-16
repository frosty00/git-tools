#!/usr/bin/env bash

directory="$(dirname $0)"
number=$1
metadata="$directory/get-metadata.js"

function usage {
  echo 'Usage:' >&2
  echo '  ./checkout.sh [number]' >&2
}

if [ $# -ne 1 ]; then
  usage
  exit 1
fi

if ! [ -d .git ]; then
  echo 'not a git repo!' >&2
  exit 2
fi

if ! [ -f "$metadata" ]; then
  echo "cannot find get-metadata.js, ensure both files are in the same directory" >&2
  exit 3
fi

origin=$(git remote -v | grep origin | head -n 1 | awk '{ print $2 }')

if ! [[ $origin =~ ^"https://" ]]; then
  echo "failed to detect repo, please add an origin remote branch tracking a https git repo" >&2
  exit 4
fi

owner=$(echo $origin | cut -d / -f4)
repo=$(echo $origin | cut -d / -f5)

result="$(node $metadata $owner $repo $number)"
exit_code=$?

if [ $exit_code -ne 0 ]; then
  echo "failed to fetch metadata" >&2
  exit $exit_code
fi

read remote_branch user_login remote_repo commit_hash <<<"$result"

if ! $(git remote -v | grep -q $remote_repo); then
  echo "adding remote repository for $user_login: $remote_repo"
  git remote add $user_login $remote_repo
fi

if git show-ref --quiet refs/heads/"$remote_branch"; then
  echo "remote branch already exists"
  git checkout "$remote_branch"
  git merge "$user_login/$remote_branch"
else
  echo "fetching $user_login's fork's branches..."
  git fetch -q $user_login
  git switch -c "$remote_branch" "$user_login/$remote_branch" --track=direct
fi

git show -s HEAD --format=oneline
