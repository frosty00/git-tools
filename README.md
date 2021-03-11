# git-tools

## prune.sh

Are you sick of getting conflicts and failing to push because a stale branch exists on GitHub already?

Use `prune.sh` to prune github's remote branches to the same set as your local branches.

Usage:

```
./prune.sh [--dry-run]
```

you can also change the name of the remote repository inside the script

## autopush.sh

Are you sick of having to type:

```
git checkout branch
git add file
git commit -m 'message'
git push github branch
git checkout master
```

Each time you want to push a small change? Fret no more you can use this tool to do it automatically for you.

Usage:

```
./autopush.sh branch_name
```

## git-delete.sh

Do you have 100 branches you need to delete but don't want to type `git branch -D` 100 times?

You can use git-delete for an interactive prompt which asks you what branches you would like to delete.

Usage:

```
./git-delete.sh

Would you like to delete branch_name? (y/n)
```
