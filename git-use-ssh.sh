#!/usr/bin/env bash

git remote -v | grep origin | head -n 1 | awk '{ print $2 }' | grep ^https | sed -E -e 's|github\.com/|github\.com:|' -e 's|https://|git@|' -e 's/git@.*github.com/git@github\.com/' | xargs git remote set-url origin

exit ${PIPESTATUS[4]}
