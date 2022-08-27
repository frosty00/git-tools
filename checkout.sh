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

origin=$(git remote -v | grep origin | head -n 1 | awk '{ print $2 }')

if ! [[ $origin =~ ^"https://" ]]; then
  echo "failed to detect repo, please add an origin remote branch tracking a https git repo" >&2
  exit 3
fi

owner=$(echo $origin | cut -d / -f4)
repo=$(echo $origin | cut -d / -f5)

result="$(node $directory/get-metadata.js $owner $repo $number)"
exit_code=$?

if [ $exit_code -ne 0 ]; then
  echo "failed to fetch metadata" >&2
  exit $exit_code
fi

read remote_branch user_login remote_repo commit_hash <<<"$result"

echo $remote_repo
if ! [ $(git remote -v | grep $remote_repo > /dev/null ) ]; then
  echo "adding remote repository $user_login - $remote_repo"
  git remote add $user_login $remote_repo
fi

echo "fetching $user_login branches..."
git fetch -q $user_login
git switch -c $remote_branch $commit_hash
git branch -q --set-upstream-to "$user_login/$remote_branch"
