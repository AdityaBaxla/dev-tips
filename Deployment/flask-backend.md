

---

# 🚀 Deploying a Flask App on a Linux Server (with Nginx, Gunicorn, UFW, SSL)

This guide walks through setting up a secure Linux server to host a Flask app using SSH, UFW firewall, Gunicorn, and Nginx.

---

## 🖥️ Initial Server Setup

### 1. SSH into Your Server

Get your IP from your cloud provider.

```bash
ssh root@<ip-address>
```

---

### 2. Set Hostname

```bash
hostnamectl set-hostname flask-server
```

Edit `/etc/hosts`:

```bash
sudo nano /etc/hosts
# Add your IP and hostname mapping
```

---

### 3. Add a New User

```bash
adduser <username>
adduser <username> sudo
```

---

### 4. Re-login as the New User

```bash
exit
ssh <username>@<ip-address>
```

### 5. Restart the server
```bash
sudo reboot
```

---

## 🔑 SSH Key Authentication Setup

### 5. Generate SSH Key (On Local Machine)

```bash
ssh-keygen -b 4096
```

Save it to `~/.ssh/id_deployment`.

---

### 6. Copy Public Key to Server

```bash
scp ~/.ssh/id_deployment.pub username@<ip-address>:~/.ssh/authorized_keys
```

> **Troubleshooting**: If SSH still asks for a password:

* Use `-i` flag:

  ```bash
  ssh -i ~/.ssh/id_deployment username@<ip-address>
  ```
* Or configure `~/.ssh/config`:

```bash
Host flask-server
  HostName <ip-address>
  User username
  IdentityFile ~/.ssh/id_deployment
```

Ensure correct permissions on remote:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

Edit remote SSH config:

```bash
sudo nano /etc/ssh/sshd_config
# Set:
PermitRootLogin no
PasswordAuthentication no
```

```bash
sudo systemctl restart sshd
```

or 
```bash
sudo systemctl restart ssh
```

---

## 🔥 Secure the Server with UFW Firewall

```bash
sudo apt install ufw

# Default policies
sudo ufw default allow outgoing
sudo ufw default deny incoming

# Allow SSH & Flask port (5000)
sudo ufw allow ssh
sudo ufw allow 5000

# Enable firewall
sudo ufw enable
sudo ufw status
```

---

## 📦 Transfer Project Files

### Option 1: `scp`

```bash
scp -r /path/to/project username@<ip-address>:~
```

### Option 2: `rsync` (exclude `.gitignore` + `.git`)

```bash
sudo apt install rsync

rsync -av --exclude-from='.gitignore' --exclude='.git' ./ username@<ip-address>:~/myproject
```

### Option 3: Tarball

```bash
tar --exclude-vcs --exclude-from='.gitignore' -czf project.tar.gz .
scp project.tar.gz username@<ip-address>:~
ssh username@<ip-address>
mkdir myproject && tar -xzf project.tar.gz -C myproject && rm project.tar.gz
```

---

## 🐍 Python & Virtual Environment

```bash
sudo apt install python3-pip python3-venv

cd ~/myproject
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

---

## 🔐 Manage Environment Variables

You can create a JSON-based config:

```bash
sudo nano /etc/config.json
# Add your secrets as key-value pairs
```

Load in Flask:

```python
import json
config = json.load(open('/etc/config.json'))
```

---

## 🚧 Running Flask App (Dev Mode)

```bash
export FLASK_APP=app.py
flask run --host=0.0.0.0
```

---

## 🛡️ Production Setup with Nginx + Gunicorn

### Install Required Packages

```bash
sudo apt install nginx
pip install gunicorn
```

---

### Nginx Config

Remove default:

```bash
sudo rm /etc/nginx/sites-enabled/default
```

Create your config:

```nginx
server {
    listen 80;
    server_name <your-ip-or-domain>;

    location /static {
        alias /home/username/myproject/static;
    }

    location / {
        proxy_pass http://localhost:8000;
        include /etc/nginx/proxy_params;
        proxy_redirect off;
    }

    client_max_body_size 10M;
    server_tokens off;
}
```

Check config and restart:

```bash
sudo nginx -t
sudo ufw allow http
sudo ufw delete allow 5000
sudo systemctl restart nginx
```

---

### Start Gunicorn

```bash
gunicorn -w 3 app:app
# Use correct module:variable
```

---

## 🧑‍✈️ Running Gunicorn with Supervisor

```bash
sudo apt install supervisor

sudo nano /etc/supervisor/conf.d/portfolio.conf
```

Example config:

```ini
[program:portfolio]
directory=/home/username/myproject
command=/home/username/myproject/.venv/bin/gunicorn -w 3 app:app
user=username
autostart=true
autorestart=true
killasgroup=true
stderr_logfile=/var/log/myproject/portfolio.err.log
stdout_logfile=/var/log/myproject/portfolio.out.log
```

Create log directory:

```bash
sudo mkdir -p /var/log/myproject
sudo touch /var/log/myproject/portfolio.err.log
sudo touch /var/log/myproject/portfolio.out.log
```

---

## 🌐 Domain Setup & SSL

### Nginx for Domain

```nginx
server {
    listen 80;
    server_name adityabaxla.online www.adityabaxla.online;

    location /static {
        alias /home/aditya/first-deployment/static;
    }

    location / {
        proxy_pass http://localhost:8000;
        include /etc/nginx/proxy_params;
        proxy_redirect off;
    }

    client_max_body_size 10M;
    server_tokens off;
}
```

---

### Install SSL via Certbot

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d adityabaxla.online -d www.adityabaxla.online
```

Auto-renew:

```bash
sudo systemctl list-timers
sudo certbot renew --dry-run
```

---

## ✅ Final Checks

* Test locally:

```bash
curl http://127.0.0.1:8000
```

* Open SSL port:

```bash
sudo ufw allow 443
sudo ufw enable
```

---

