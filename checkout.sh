#!/usr/bin/env bash

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
  repo=${repo%%.git}
else
  echo "invalid origin repo - $origin, please add an origin remote branch tracking a git repo" >&2
  exit 4
fi

url="https://api.github.com/repos/$owner/$repo/pulls/$number"
result=$(curl -s -f -H 'Content-Type: application/json' $url | jq '.head.ref, .user.login, .base.repo.ssh_url, .head.sha' | sed 's/"//g'; exit ${PIPESTATUS[0]})
exit_code=$?
if [ $exit_code -ne 0 ]; then
  echo "failed to fetch metadata for $url" >&2
  exit $exit_code
fi

read -d '\n' remote_branch user_login remote_repo commit_hash <<< "$result"
local_branch="${remote_branch}"

if ! $(git remote | grep -q $user_login); then
  user_remote="git@github.com:$user_login/$repo.git"
  echo "adding remote repository for $user_login: $user_remote"
  git remote add $user_login $user_remote
fi

function has_local_branch {
  git show-ref -q refs/heads/"$local_branch"
}

function has_remote_branch {
  git show-ref -q refs/remotes/"$user_login/$remote_branch"
}

echo "fetching $user_login's fork's branches..."
git fetch -q $user_login

if has_local_branch; then
  git checkout -q "$local_branch"
  if has_remote_branch; then
    git merge -q "$user_login/$remote_branch"
  fi
  echo "local"
elif has_remote_branch; then
  echo "has remote"
  git switch -c "$local_branch" "$user_login/$remote_branch" --track=direct
else
  echo "else"
  git switch -c "$local_branch" "$commit_hash"
fi

git show -s HEAD --format=oneline
