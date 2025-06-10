Using Supervisor to manage Gunicorn is an excellent choice, especially if you're working on a server where Systemd might feel a bit more complex for certain tasks, or if you prefer a simpler, more application-focused process manager. Supervisor is lightweight, easy to configure, and provides robust process monitoring and automatic restarts.

Here's how to set up Supervisor to handle your Gunicorn process for the Flask backend:

1. Install Supervisor
If you don't have Supervisor installed already:

Bash

sudo apt update
sudo apt install supervisor
On CentOS/RHEL:

Bash

sudo yum install supervisor
sudo systemctl enable supervisord # Yes, it's supervisord for the service name
sudo systemctl start supervisord
2. Configure Supervisor for your Gunicorn Application
Supervisor configurations are typically stored in the /etc/supervisor/conf.d/ directory. Each program gets its own .conf file.

Create a new configuration file:

Bash

sudo nano /etc/supervisor/conf.d/git-tracker-backend.conf
Add the following content:

Ini, TOML

[program:git-tracker-backend]
command = /home/aditya/git-tracker/Backend/venv/bin/gunicorn --workers 3 --bind unix:/tmp/git-tracker-backend.sock wsgi:application
directory = /home/aditya/git-tracker/Backend/my_flask_app
user = aditya # The user under which Gunicorn will run
autostart = true
autorestart = true
stopasgroup = true
killasgroup = true
stderr_logfile = /var/log/supervisor/git-tracker-backend.err.log
stdout_logfile = /var/log/supervisor/git-tracker-backend.out.log
# Environment variables (optional, but good practice for Flask)
# environment=FLASK_ENV="production",SECRET_KEY="your_super_secret_key_here"
Explanation of directives:

[program:git-tracker-backend]: Defines a new program managed by Supervisor. git-tracker-backend is the name of your program (you can choose any meaningful name).
command: The full command that Supervisor will execute to start your Gunicorn server.
Crucial: Make sure this path (/home/aditya/git-tracker/Backend/venv/bin/gunicorn) points to the gunicorn executable within your virtual environment.
--bind unix:/tmp/git-tracker-backend.sock: Specifies the Unix socket for Gunicorn to listen on.
wsgi:application: Points to your Flask application instance (from wsgi.py).
directory: The working directory for your Gunicorn process. This is where Supervisor will execute the command from. It should be the root of your Flask application (my_flask_app).
user: The system user under which the Gunicorn process will run. It's good practice to run it as a non-root user (e.g., aditya or a dedicated web_app user). Ensure this user has proper permissions to the directory and command path.
autostart = true: Tells Supervisor to start this program automatically when Supervisor itself starts.
autorestart = true: Tells Supervisor to automatically restart the program if it crashes or exits unexpectedly.
stopasgroup = true and killasgroup = true: Important for ensuring that when Supervisor stops or kills the process, it stops/kills Gunicorn and all its worker processes as a group, preventing orphaned processes.
stderr_logfile and stdout_logfile: Paths for logging standard error and standard output from your Gunicorn process. These are invaluable for debugging.
environment (optional, commented out): You can set environment variables directly here. For highly sensitive secrets or many variables, it's often better to load them within your Flask app itself (e.g., from an .env file that's not committed, or using a separate Systemd service if you integrate this with Systemd). If you use EnvironmentFile with Systemd for your Flask app, then Supervisor's environment might be redundant or you'd manage secrets elsewhere.
3. Create Log Directory and Set Permissions
Make sure the log directory exists and the user running the Gunicorn process has write permissions to it.

Bash

sudo mkdir -p /var/log/supervisor
sudo chown aditya:www-data /var/log/supervisor # Or the user/group under which supervisor runs
sudo chmod 775 /var/log/supervisor
Also, ensure the user (aditya) has permissions to write the socket file in /tmp/ and Nginx has read access to it.

4. Update Supervisor Configuration
After creating or modifying a configuration file, you need to tell Supervisor to reread its configurations and update its processes.

Bash

sudo supervisorctl reread
sudo supervisorctl update
reread: Scans for new or changed configuration files.
update: Activates any new or changed programs.
5. Check Supervisor Status
You can check the status of your managed programs:

Bash

sudo supervisorctl status
You should see git-tracker-backend RUNNING (or something similar) along with its PID