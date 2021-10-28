#!/bin/bash

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
git add -u
git commit -m "$id"
git push github
git checkout master
