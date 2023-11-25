commands: 




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