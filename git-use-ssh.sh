#!/usr/bin/env bash

git remote -v | grep "\shttps" | grep push | awk '{ print $1" "$2 }' | sed -E -e 's|github\.com/|github\.com:|' -e 's|https://|git@|' -e 's/git@.*github.com/git@github\.com/' | xargs -L 1 git remote set-url

exit ${PIPESTATUS[2]}
