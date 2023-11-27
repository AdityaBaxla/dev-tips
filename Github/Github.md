commands: 

## how to delete gh-pages
$ git push origin :gh-pages

## paper trail personal repo
- add issue in github
- git brach branch-name-to-fix
- git checkout branch-name-to-fix
- git add
- git commit -m "bal bal"
- git push origin/branch-name-to-fix
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