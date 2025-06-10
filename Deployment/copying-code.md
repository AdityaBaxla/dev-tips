For your scenario (deploying a Flask backend and an Nginx-served frontend from a Linode server):

For your Flask Backend Code:

git clone and git pull are almost certainly the best tools. Your code is under version control, and Git provides a robust way to manage updates, revert if necessary, and ensure you're running a specific version.
For your Frontend Build Files (e.g., build directory from React/Vue/Angular):

If these are generated locally and then need to be moved to the server: rsync is often the best choice. It's highly efficient for transferring only the changed static files, especially if your build output is large.
You could also scp the entire build directory, but rsync will be much faster on subsequent deployments.
Alternative: If your frontend build process can run on the server, you could git pull the frontend source code and then run the build command (npm run build, yarn build) directly on the server. This keeps the build environment on the server but might require more server resources.
For Small Configuration Files or Quick Manual Fixes:

scp is perfectly fine.
In summary:

Use Git for your version-controlled application code.
Use rsync for efficient synchronization of non-versioned static assets or generated build output.
Use scp for simple, ad-hoc file transfers.