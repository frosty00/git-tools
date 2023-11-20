#!/usr/bin/env bash

if [[ $# != 1 ]]; then
  echo 'Usage autopush branch_name'
  exit 1
fi

id="$1"
exists=$(git show-ref "refs/heads/$id")
if [ -n "$exists" ]; then
  git checkout "$id"
else
  git checkout -b "$id"
fi
if [[ $? != 0 ]]; then
  echo "invalid branch name: $1"
  exit 1
fi
git commit -am "$id"
git push -u github
git checkout master

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

body=$(jq --null-input --arg title "${id//-/ }" --arg head "frosty00:$id" --arg base "master" '{ $title, $head, $base }')
echo "$body"
curl \
  -X POST \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $GITHUB_AUTH_TOKEN"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/$owner/$repo/pulls" \
  -d "$body" | jq '._links.html.href'
