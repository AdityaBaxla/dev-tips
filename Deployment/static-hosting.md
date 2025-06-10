
**Important Considerations Before You Start:**

* **Nginx Installation:** This guide assumes Nginx is already installed on your server. If not, you'll need to install it first (e.g., `sudo apt update && sudo apt install nginx` on Debian/Ubuntu, or `sudo yum install nginx` on CentOS/RHEL).
* **Permissions:** You mentioned you don't have permissions configured. This is crucial for Nginx. The Nginx user (often `www-data` on Debian/Ubuntu or `nginx` on CentOS/RHEL) needs **read access** to your `/home/aditya/git-tracker/Frontend/git-tracker-ui/dist` directory and all its contents. If Nginx doesn't have read access, you'll get `403 Forbidden` errors.
    * **How to fix permissions (if needed):**
        ```bash
        sudo chmod -R 755 /home/aditya/git-tracker/Frontend/git-tracker-ui
        sudo chown -R aditya:aditya /home/aditya/git-tracker/Frontend/git-tracker-ui # Make sure your user owns it initially
        # Then, grant read access to the Nginx user (replace www-data with your Nginx user if different)
        sudo usermod -a -G aditya www-data # Add nginx user to your user's group
        # OR, a less secure but quick way to test (not recommended for production):
        # sudo chmod -R 777 /home/aditya/git-tracker/Frontend/git-tracker-ui/dist
        ```
* **SELinux (for CentOS/RHEL):** If you're on CentOS/RHEL with SELinux enabled, it might prevent Nginx from serving files outside its default `/usr/share/nginx/html` or `/var/www/html` directories. You might need to adjust SELinux contexts.
    ```bash
    sudo semanage fcontext -a -t httpd_sys_content_t "/home/aditya/git-tracker/Frontend/git-tracker-ui/dist(/.*)?"
    sudo restorecon -Rv /home/aditya/git-tracker/Frontend/git-tracker-ui/dist
    sudo setsebool -P httpd_can_network_connect 1 # If your app needs to connect to backend APIs
    ```
* **Firewall:** Ensure your server's firewall (e.g., `ufw` on Ubuntu, `firewalld` on CentOS) allows traffic on port 80 (HTTP) and/or 443 (HTTPS).
    * **UFW (Ubuntu):** `sudo ufw allow 'Nginx HTTP'` or `sudo ufw allow 80/tcp`
    * **Firewalld (CentOS):** `sudo firewall-cmd --permanent --add-service=http` then `sudo firewall-cmd --reload`

---

### Nginx Configuration

You'll typically create a new server block configuration file in Nginx's `sites-available` directory and then symlink it to `sites-enabled`.

1.  **Create a New Configuration File:**
    Navigate to the Nginx configuration directory.
    * **Debian/Ubuntu:** `/etc/nginx/sites-available/`
    * **CentOS/RHEL:** `/etc/nginx/conf.d/` (you'd typically create a `.conf` file directly here)

    Let's assume Debian/Ubuntu path for the example:

    ```bash
    sudo nano /etc/nginx/sites-available/git-tracker-ui.conf
    ```

2.  **Add the Configuration:**
    Paste the following content into the file. Replace `/home/aditya/git-tracker/Frontend/git-tracker-ui/dist` with the *exact* path to your `dist` folder.

    ```nginx
    server {
        listen 80; # Listen on port 80 for HTTP traffic

        # If you have a domain name, you'd add:
        # server_name your_domain.com www.your_domain.com;
        # Since you want to access by IP, server_name is not strictly necessary,
        # but it's good practice to omit it or set it to _; for default server.

        root /home/aditya/git-tracker/Frontend/git-tracker-ui/dist; # Path to your 'dist' folder
        index index.html index.htm; # Default file to serve

        location / {
            try_files $uri $uri/ /index.html; # Essential for Single Page Applications (SPAs)
            # This line tells Nginx:
            # 1. Try to serve the exact file ($uri).
            # 2. If it's a directory, try to serve index.html inside it ($uri/).
            # 3. If neither is found (e.g., a direct link to /some-route in an SPA),
            #    then fall back to serving /index.html. This allows your SPA's
            #    client-side router to handle the route.
        }

        # Optional: Caching for static assets (improves performance)
        location ~* \.(css|js|gif|jpeg|jpg|png|svg|ico|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, no-transform";
            # You might want to remove expires if your build process adds content hashes
            # to file names, as those files are already "cache-busted".
        }

        # Optional: Error page (for custom 404, 500 pages)
        # error_page 404 /404.html;
        # location = /404.html {
        #     internal;
        # }

        # Optional: Logging
        access_log /var/log/nginx/git-tracker-ui_access.log;
        error_log /var/log/nginx/git-tracker-ui_error.log;
    }
    ```

3.  **Enable the Configuration (Debian/Ubuntu only):**
    Create a symbolic link from `sites-available` to `sites-enabled`.

    ```bash
    sudo ln -s /etc/nginx/sites-available/git-tracker-ui.conf /etc/nginx/sites-enabled/
    ```

    *If you're on CentOS/RHEL and placed the file in `/etc/nginx/conf.d/`, this step is not needed as Nginx automatically loads all `.conf` files in that directory.*

4.  **Test Nginx Configuration:**
    It's crucial to test your Nginx configuration for syntax errors before restarting the service.

    ```bash
    sudo nginx -t
    ```
    You should see output similar to this:
    ```
    nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /etc/nginx/nginx.conf test is successful
    ```
    If there are errors, Nginx will tell you where they are. Fix them before proceeding.

5.  **Restart Nginx:**
    Apply the changes by restarting the Nginx service.

    ```bash
    sudo systemctl restart nginx
    # Or for older systems:
    # sudo service nginx restart
    ```

    Ensure Nginx is running:
    ```bash
    sudo systemctl status nginx
    ```
    It should show "active (running)".

### Accessing Your Application

Now, open your web browser and go to your server's IP address:

```
http://your_server_ip_address
```

You should see your `git-tracker-ui` application loaded from the `dist` folder.

### Troubleshooting

* **`403 Forbidden` error:** This is almost always a permissions issue. Double-check the `root` directory path and ensure the Nginx user has read access to all files and execute access to all directories leading up to your `dist` folder. Check SELinux if on CentOS/RHEL.
* **`502 Bad Gateway` or `500 Internal Server Error`:** This is less common for static file serving but could indicate a misconfiguration or a problem with Nginx itself. Check the Nginx error logs (`/var/log/nginx/error.log` or the specific error log you configured).
* **Page not found for routes (SPA issues):** If your `index.html` loads, but navigating to `/some-route` manually gives a 404, then the `try_files` directive is probably misconfigured or you're missing it. Ensure `try_files $uri $uri/ /index.html;` is correctly set.
* **Check Nginx logs:**
    * Access logs: `/var/log/nginx/access.log` (or your custom access log)
    * Error logs: `/var/log/nginx/error.log` (or your custom error log)
    These logs are your best friends for debugging.

By following these steps, you should be able to successfully configure Nginx to serve your `dist` folder when accessing your server's IP address.
To configure Nginx to serve your `dist` folder when you go to the IP address of your server, you'll need to edit Nginx's configuration file.

**Important Considerations Before You Start:**

* **Permissions:** You mentioned you don't have permissions configured. This is crucial for Nginx. The Nginx worker process (usually running as `www-data` on Ubuntu/Debian or `nginx` on RHEL/CentOS) needs read access to your `/home/aditya/git-tracker/Frontend/git-tracker-ui/dist` directory and all its contents. If the permissions are too restrictive, Nginx won't be able to serve the files, and you'll see "403 Forbidden" errors in your browser and Nginx error logs.
* **Single-Page Application (SPA) Routing:** If your `dist` folder contains a Single-Page Application (like React, Angular, Vue.js), it likely handles its own routing client-side. This means that if a user directly accesses a route like `http://your_ip_address/about` (instead of navigating from `index.html`), Nginx needs to serve `index.html` for that route, and the SPA will then take over the routing.

### Steps to Configure Nginx:

1.  **Install Nginx (if not already installed):**
    On Ubuntu/Debian:
    ```bash
    sudo apt update
    sudo apt install nginx
    ```
    On CentOS/RHEL:
    ```bash
    sudo yum install nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
    ```

2.  **Adjust Folder Permissions (Crucial!):**
    Nginx typically runs as a user like `www-data` (Ubuntu/Debian) or `nginx` (CentOS/RHEL). Your `dist` folder is in your home directory, which might be restricted. You need to grant Nginx read access.

    ```bash
    # Grant execute permission to parent directories for www-data/nginx user
    sudo chmod o+x /home/aditya/
    sudo chmod o+x /home/aditya/git-tracker/
    sudo chmod o+x /home/aditya/git-tracker/Frontend/
    sudo chmod o+x /home/aditya/git-tracker/Frontend/git-tracker-ui/

    # Ensure the dist folder and its contents are readable
    sudo chmod -R 755 /home/aditya/git-tracker/Frontend/git-tracker-ui/dist/
    # OR, for stricter permissions (read-only for others, read/write for owner)
    # sudo find /home/aditya/git-tracker/Frontend/git-tracker-ui/dist/ -type d -exec chmod 755 {} \;
    # sudo find /home/aditya/git-tracker/Frontend/git-tracker-ui/dist/ -type f -exec chmod 644 {} \;
    ```
    Replace `o+x` with `g+x` and `www-data` (or `nginx`) if you want to explicitly add the Nginx user to the `aditya` group, but `o+x` (others execute) on the directories leading to `dist` is often sufficient for Nginx to traverse.

3.  **Edit Nginx Configuration File:**
    The main Nginx configuration file is typically located at `/etc/nginx/nginx.conf`. However, it's best practice to create a new server block configuration file in `/etc/nginx/sites-available/` and then create a symbolic link to it in `/etc/nginx/sites-enabled/`.

    Create a new file, for example, `git-tracker.conf`:
    ```bash
    sudo nano /etc/nginx/sites-available/git-tracker.conf
    ```

    Add the following content to the file:

    ```nginx
    server {
        listen 80; # Listen on port 80 for HTTP traffic
        listen [::]:80; # Listen on IPv6 as well

        # If you have a domain name, put it here. Otherwise, it will listen
        # on the server's IP address by default if this is the only server block.
        # server_name your_ip_address_or_domain.com;
        # If this is the only or default server block, you can often omit server_name
        # or use `_` as a wildcard, but for serving by IP, it's often not strictly needed
        # if this is the *only* server block listening on port 80.

        root /home/aditya/git-tracker/Frontend/git-tracker-ui/dist; # This is the path to your dist folder

        index index.html index.htm; # Default files to serve when a directory is requested

        location / {
            # This is crucial for Single-Page Applications (SPAs)
            # It tries to serve the requested URI, then the URI as a directory,
            # and if neither is found, it falls back to index.html.
            # This allows client-side routing to work.
            try_files $uri $uri/ /index.html;
        }

        # Optional: Add caching for static assets for better performance
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|eot|ttf|woff|woff2)$ {
            expires 30d; # Cache these files for 30 days
            add_header Cache-Control "public, no-transform";
            access_log off; # No need to log access for these static files
        }

        # Optional: Error pages
        error_page 404 /index.html; # Redirect 404s to index.html for SPA routing
    }
    ```

    **Explanation of directives:**

    * `listen 80;`: Nginx will listen for incoming HTTP connections on port 80.
    * `root /home/aditya/git-tracker/Frontend/git-tracker-ui/dist;`: This tells Nginx where to find your files. When a request comes in, Nginx will look for the file in this directory.
    * `index index.html index.htm;`: If a request is for a directory (like `http://your_ip_address/`), Nginx will look for `index.html` or `index.htm` within that directory and serve it.
    * `location / { ... }`: This block defines how Nginx handles requests for the root path (`/`) and any subpaths.
        * `try_files $uri $uri/ /index.html;`: This is key for SPAs.
            * `$uri`: Tries to find a file that exactly matches the request URI (e.g., if you request `/styles.css`, it tries to find `/home/aditya/git-tracker/Frontend/git-tracker-ui/dist/styles.css`).
            * `$uri/`: If `$uri` isn't found, it tries to find a directory matching the URI and serves its `index.html` (e.g., if you request `/about/`, it tries to find `/home/aditya/git-tracker/Frontend/git-tracker-ui/dist/about/index.html`).
            * `/index.html`: If neither of the above are found (which happens if a user directly enters `http://your_ip_address/some/spa/route`), Nginx serves your main `index.html` file. Your SPA's JavaScript will then load and handle the `/some/spa/route` internally.
    * `location ~* \.(js|css|...) { ... }`: This block uses a regular expression to apply specific settings for common static file types (JavaScript, CSS, images, fonts).
        * `expires 30d;`: Tells the browser to cache these files for 30 days, improving performance on subsequent visits.
        * `access_log off;`: Prevents logging access to these files, reducing log noise.
    * `error_page 404 /index.html;`: This is an alternative or supplementary way to handle 404s for SPAs. If a resource isn't found, it serves `index.html`, letting the SPA handle the "not found" state.

4.  **Enable the new configuration:**
    Create a symbolic link from your `sites-available` file to `sites-enabled`:
    ```bash
    sudo ln -s /etc/nginx/sites-available/git-tracker.conf /etc/nginx/sites-enabled/
    ```

5.  **Remove the default Nginx configuration (if it exists and conflicts):**
    If you haven't removed it already, the default Nginx configuration (`/etc/nginx/sites-enabled/default`) might be conflicting. It's often best to disable it when setting up your own:
    ```bash
    sudo rm /etc/nginx/sites-enabled/default
    ```

6.  **Test Nginx configuration:**
    It's crucial to test the configuration for syntax errors before reloading Nginx:
    ```bash
    sudo nginx -t
    ```
    You should see output similar to:
    ```
    nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /etc/nginx/nginx.conf test is successful
    ```
    If there are errors, Nginx will tell you where they are. Fix them before proceeding.

7.  **Reload Nginx to apply changes:**
    ```bash
    sudo systemctl reload nginx
    ```
    If `reload` doesn't work for some reason (e.g., a critical error prevented a graceful reload), you might need to `restart`:
    ```bash
    sudo systemctl restart nginx
    ```

8.  **Access your application:**
    Open your web browser and navigate to the IP address of your server. You should now see your `git-tracker-ui` application.

**Troubleshooting:**

* **"403 Forbidden" Error:** This almost always means Nginx doesn't have read permissions to the `dist` folder or its parent directories. Double-check the `chmod` commands. Ensure the user Nginx runs as (`www-data` or `nginx`) can traverse all directories from `/` down to your `dist` folder.
* **"404 Not Found" Error:**
    * Check the `root` path in your Nginx configuration. Is it absolutely correct?
    * Are the files actually present in the `dist` folder?
    * Is the `index.html` file present in the `dist` folder?
* **Nginx Logs:** Check the Nginx error logs for more detailed information.
    * On Ubuntu/Debian: `/var/log/nginx/error.log`
    * On CentOS/RHEL: `/var/log/nginx/error.log`
* **Firewall:** Ensure your server's firewall (e.g., `ufw` on Ubuntu, `firewalld` on CentOS) allows incoming traffic on port 80 (and 443 if you add SSL later).
    * For `ufw`: `sudo ufw allow 'Nginx HTTP'` or `sudo ufw allow 80/tcp`
    * For `firewalld`: `sudo firewall-cmd --permanent --add-service=http` then `sudo firewall-cmd --reload`

By following these steps carefully, you should be able to successfully serve your `dist` folder using Nginx.