#!/usr/bin/env bash

directory="$(dirname $0)"
number=$1

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

if ! which -s jq; then
  echo "please install the dependency jq" >&2
  exit 3
fi

origin=$(git remote -v | grep origin | head -n 1 | awk '{ print $2 }')

if [[ $origin =~ ^https ]]; then
  owner=$(cut -d / -f4 <<< $origin)
  repo=$(cut -d / -f5 <<< $origin)
elif [[ $origin =~ ^git\@github\.com ]]; then
  path=$(cut -d : -f2 <<< $origin)
  owner=$(cut -d / -f1 <<< $path)
  repo=$(cut -d / -f2 <<< $path)
else
  echo "invalid origin repo - $origin, please add an origin remote branch tracking a git repo" >&2
  exit 4
fi

url="https://api.github.com/repos/$owner/$repo/pulls/$number"
result=$(curl -s -f -H 'Content-Type: application/json' $url | jq '.head.ref, .user.login, .base.repo.ssh_url, .head.sha' | sed 's/"//g')
exit_code=$?
if [ $exit_code -ne 0 ]; then
  echo "failed to fetch metadata for $url" >&2
  exit $exit_code
fi

read -d '\n' remote_branch user_login remote_repo commit_hash <<< "$result"
echo "$remote_branch $user_login $remote_repo $commit_hash"

if ! $(git remote | grep -q $user_login); then
  user_remote="git@github.com:$user_login/$repo.git"
  echo "adding remote repository for $user_login: $user_remote"
  git remote add $user_login $user_remote
fi

echo "fetching $user_login's fork's branches..."
git fetch -q $user_login
if git show-ref -q refs/heads/"$remote_branch"; then
  git checkout -q "$remote_branch"
  git merge -q "$user_login/$remote_branch"
elif git show-ref -q refs/heads/"$user_login/$remote_branch"; then
  git switch -c "$remote_branch" "$user_login/$remote_branch" --track=direct
else
  git switch -c "$remote_branch" "$commit_hash"
fi

git show -s HEAD --format=oneline
