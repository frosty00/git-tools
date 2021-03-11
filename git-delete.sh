#!/bin/bash
for branch in $(git branch | grep -v '^*'); do
  read -p "Would you like to delete $branch? (y/n)" -n 1 answer
  if [[ "$answer" == "y" ]]; then
    printf "\n"
    git branch -D "$branch"
  else
    printf "\nSkipping $branch\n"
  fi
done
