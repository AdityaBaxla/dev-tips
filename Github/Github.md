commands: 
### how to push code to github
$git push origin main
syntax : git push <remote> <branch-name>

## how to delete gh-pages
$ git push origin :gh-pages

## paper trail personal repo
- add issue in github
- git branch branch-name-to-fix
- git checkout branch-name-to-fix
- git add
- git commit -m "bal bal"
- git push --set-upstream origin branch-name-to-fix
- git push origin/branch-name-tofix
- open new pull request



### for deployement through vite viteconfig.js should have exactly
```
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  base: "/project-showcase/",
  plugins: [react()],
});

```

base: reponame  with double back slash

use this link to deploy vite app : https://dev.to/shashannkbawa/deploying-vite-app-to-github-pages-3ane

https://stackoverflow.com/questions/74518887/blank-page-when-deploying-a-react-app-to-github-pages-and-vite#comment131543640_74518887



basically 

$ git add dist -f
$ git commit -m "adding dist"
$ git subtree push --prefix dist origin gh-pages

## settings gh-pages github actions || through repo

## OR YOU COULD DO WHAT COMMENTS SAID
Or add: base: "/<repo>/", to vite.config.js,

npm install gh-pages --save-dev

add to package.json

```
 "homepage": "https://<username>.github.io/<repo>/",
  ...
  "scripts": {
...
"build": "vite build",
    "predeploy": "npm run build",
    "deploy": "gh-pages -d dist",
...
```
and then run command npm run deploy to keep it simple.
~im hopeful this works~

## finally what works:
- delete github pages
- prefix dist path
- goto github pages settings and select branch gh-pages

### onTabChange not working
not imported this on top of constructor :  void Function(int)? onTabChange;
### check const where there are state changes

### linking git and github
setup username 
$ git config --global user.name
setup email
$ git config --global user.email

make a repo on github using + icon

echo "# lib-management" >> README.md

git init

git add README.md

git commit -m "first commit"

git branch -M main

git remote add origin https://github.com/AdityaBaxla/lib-management.git

git push -u origin main : -u for setup of tracking subsiquent push can be done by : git push

## getting the current git branch upto date with latest commit

git branch // make sure you are in the correct branch

git checkout branchnamae // if needed change branch

git fetch // get commit data to git

git pull // reflect changes in you files

## installing github in termux android
```
pkg install gh git
and

gh auth login
then

gh repo clone <some-repo>
# or
git clone <some-repo>.git
```
## git errors,
if .git folder is there in the file and you get "fatal git not a  repository". your head is most likely corrupt.
if new repo:
$rm -rf .git
$git init
a
## creating new branch from cli and pushing it to github
```
git branch <branch-name>
git checkout <branch-name>
git branch (to confirm you are in the right branch)
git push --set-upstream origin <branch-name> (to create this branch in github)
```
## Clone a particular branch from github
`git clone -b <branchname> <remote-repo-url>`

## Get your current branch uptodate with main/ another branch
```
git status
git fetch origin main
git merge origin/main
git push origin <your_branch_name>
```
## create a new local branch and push it to github creating a new upstream branch
```
git push --set-upstream origin session-4-dashboard&features
```
## create 2 different account in git using ssh
To use multiple GitHub accounts on the same computer, especially when working with WSL (Windows Subsystem for Linux), you can follow these steps to manage different SSH keys and Git configurations for each account.

### 1. Generate SSH Keys for Each GitHub Account

First, generate a new SSH key for each GitHub account.

#### For Account 1:
```bash
ssh-keygen -t rsa -b 4096 -C "your_email1@example.com"
# Save the key as: /home/your_username/.ssh/id_rsa_account1
```

#### For Account 2:
```bash
ssh-keygen -t rsa -b 4096 -C "your_email2@example.com"
# Save the key as: /home/your_username/.ssh/id_rsa_account2
```

### 2. Add SSH Keys to the SSH Agent

Start the SSH agent and add your SSH keys.

```bash
# Start the SSH agent
eval "$(ssh-agent -s)"

# Add SSH key for Account 1
ssh-add ~/.ssh/id_rsa_account1

# Add SSH key for Account 2
ssh-add ~/.ssh/id_rsa_account2
```

### 3. Add SSH Keys to Your GitHub Accounts

Copy the SSH public key and add it to the corresponding GitHub account.

```bash
# For Account 1
cat ~/.ssh/id_rsa_account1.pub

# For Account 2
cat ~/.ssh/id_rsa_account2.pub
```

Follow GitHub's instructions to add these keys to your accounts:
- [Adding a new SSH key to your GitHub account](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

### 4. Create an SSH Config File

Create or edit the `~/.ssh/config` file to differentiate between the accounts.

```bash
# Open the SSH config file
nano ~/.ssh/config
```

Add the following configuration:

```plaintext
# GitHub Account 1
Host github-account1
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_rsa_account1

# GitHub Account 2
Host github-account2
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_rsa_account2
```

### 5. Clone Repositories Using the Correct Host

When cloning repositories, use the alias defined in the SSH config file.

#### For Account 1:
```bash
git clone git@github-account1:username/repo.git
```

#### For Account 2:
```bash
git clone git@github-account2:username/repo.git
```

### 6. Set Up Git Configurations for Each Repository

Configure the Git user and email for each repository.

#### For a repository of Account 1:
```bash
cd /path/to/repo1
git config user.name "Your Name Account 1"
git config user.email "your_email1@example.com"
```

#### For a repository of Account 2:
```bash
cd /path/to/repo2
git config user.name "Your Name Account 2"
git config user.email "your_email2@example.com"
```

### Summary

By following these steps, you can manage multiple GitHub accounts on the same computer using different SSH keys and Git configurations. This approach ensures that commits are associated with the correct GitHub account and allows you to switch seamlessly between different projects.
