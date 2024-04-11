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
