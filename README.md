# git-tools

### checkout.sh

Are you in a rush to manage hundreds of pull requests and have the ability to push directly to other people's forks? `checkout.sh` is the perfect companion to a dev that works on multiple pull requests a day. You can simply

```
checkout PR_NUMBER_ON_GITHUB
git add modified_files
git commit -m 'message'
git push
```

and push directly to their branch! checkout.sh will fetch metadata from github to set the upstream branch correctly. It will also create a remote repo with the user's github username for your convenience.

```
> checkout 14798

> git remote -v

origin    https://github.com/ccxt/ccxt (fetch)
origin    https://github.com/ccxt/ccxt (push)
...
# newly added repo below
ttodua    https://github.com/ttodua/ccxt.git (fetch)
ttodua    https://github.com/ttodua/ccxt.git (push)
```

The github repo to fetch the pull request data is detected automatically from the `origin` remote so there is no need to configure this script.

#### checkout.sh installation guide

```
ln -s "$(pwd)/checkout.sh" /usr/local/bin/checkout
```

And you will be able to checkout any pull request by simply typing `checkout PR_NUMBER` inside of a local git repository.

---

### prune.sh

Are you sick of getting conflicts and failing to push because a stale branch exists on GitHub already?

Use `prune.sh` to prune github's remote branches to the same set as your local branches.

Usage:

```
./prune.sh [--dry-run]
```

you can also change the name of the remote repository inside the script

---

### autopush.sh

Are you sick of having to type:

```
git checkout -b branch
git add -u
git commit -m 'message'
git push github branch
git checkout master
```

Each time you want to push a small change? Fret no more you can use this tool to do it automatically for you.

Usage:

```
./autopush.sh branch_name
```

---

### clean.sh

Do you have 100 branches you need to delete but don't want to type `git branch -D` 100 times?

You can use `clean.sh` for an interactive prompt which asks you what branches you would like to delete.

Usage:

```
./clean.sh

Would you like to delete branch_name? (y/n)
```

---

### git-use-ssh.sh

This will automatically convert the origin remote repo from a https github remote repository to a ssh github remote repository, automatically handling any access tokens. This is useful if you use ssh keys to authenticate with github.

Usage:

```
> cd git-repo/
> git remote -v

origin	https://frosty00:ghp_ninadffFdnndsnfsdfadsfas@github.com/cs169/fa22-actionmap-fa22-43.git (fetch)
origin	https://frosty00:ghp_ninadffFdnndsnfsdfadsfas@github.com/cs169/fa22-actionmap-fa22-43.git (push)

> ./git-use-ssh.sh
> git remote -v

origin	git@github.com:cs169/fa22-actionmap-fa22-43.git (fetch)
origin	git@github.com:cs169/fa22-actionmap-fa22-43.git (push)
```

Make sure to add your ssh public key to github by doing:

```
# if your key exists
cat ~/.ssh/github_rsa.pub

# if you need to generate a key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/github_rsa

cat ~/.ssh/github_rsa.pub
```

And then copy the key to your github profile settings under https://github.com/settings/keys
