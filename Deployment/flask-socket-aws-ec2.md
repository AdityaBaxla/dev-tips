Nice — I’ll give you a single, complete, copy-and-pasteable plan that takes your app from “works locally on the EC2 instance” → to → “public HTTPS site with Gunicorn + systemd + Nginx, DNS pointed at an Elastic IP.” I’ll explain *why* for every step and include commands, sample config files (fill the placeholders I call out), and quick tests/resources so you can verify each step worked.

Because you said your project lives at `/home/ec2-user/Applications/mad-colab` and your virtualenv is `.venv` in the project root, all examples below use those paths. Replace `example.com` with your real domain (or the Elastic IP while testing). Where I need your app’s Python entry point I’ll show a safe default you can adapt.

---

# Quick checklist (high level)

1. Confirm instance reachable by SSH (you already did this).
2. Reserve an **Elastic IP** for the instance and point your DNS A record to that IP. (prevents IP changes). ([AWS Documentation][1])
3. Install system packages (python, nginx, git, certbot).
4. Create `wsgi.py` (or confirm entry point), test app with Gunicorn.
5. Create a **systemd** service for Gunicorn and enable/start it (keeps the app running). ([Miguel Grinberg Blog][2])
6. Configure Nginx as reverse proxy to the Gunicorn UNIX socket; test. ([DigitalOcean][3])
7. Get HTTPS via Let’s Encrypt / certbot (or ALB if you prefer). ([Let's Encrypt Community Support][4])
8. Harden SSH/security group, test the live site and session cookies.

I’ll now expand every step with commands, files and *how to check*.

---

# 0 — Pre-checks / assumptions

* Instance OS: instructions include both Amazon Linux (2/2023) and Ubuntu style commands. If you know your distro, follow the matching commands.
* You have SSH key access and `ec2-user` is your login (adjust user if different).
* Your Flask app entry point: I’ll use a `wsgi.py` exposing `app` (common pattern). If your app file is `app.py` with `app = Flask(__name__)`, use that module name instead (see the wsgi example).
* You use `.venv` in project root — I’ll reference `/home/ec2-user/Applications/mad-colab/.venv`.

---

# 1 — Make sure your Flask app is production-ready (files & config)

### 1.1 Create (or confirm) `wsgi.py` in project root

Create `/home/ec2-user/Applications/mad-colab/wsgi.py` (used by Gunicorn). If your app variable lives in `app.py`, use that; if your package is `mad_colab` expose it accordingly.

Example `wsgi.py` (edit `your_module` → `app` source):

```py
# /home/ec2-user/Applications/mad-colab/wsgi.py
from werkzeug.middleware.proxy_fix import ProxyFix
from app import app   # <- change `app` to the module where your Flask app object is defined

# If Nginx is the reverse proxy, tell Flask/Werkzeug to trust the X-Forwarded-* headers.
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_prefix=1)

if __name__ == "__main__":
    app.run()
```

Why: `ProxyFix` ensures `request.scheme`, `request.remote_addr`, and redirects use the original client/protocol (Nginx sets X-Forwarded-*). Only enable when you run behind a reverse proxy. ([werkzeug.palletsprojects.com][5])

**Check:** run `python3 /home/ec2-user/Applications/mad-colab/wsgi.py` locally (should fail on port used by gunicorn but ensures no import errors); or run `python3 -c "import app; print('OK')"` in project root to detect import errors.

---

### 1.2 Ensure production config (SECRET, sessions)

* Set `app.config['SECRET_KEY']` to a long random secret (do NOT embed in source). Put it in an `.env` or better provide it as an `EnvironmentFile` for systemd.
* For secure sessions behind HTTPS:

```py
app.config.update(
  SESSION_COOKIE_SECURE=True,
  SESSION_COOKIE_HTTPONLY=True,
  SESSION_COOKIE_SAMESITE='Lax'
)
```

Why: secure cookies/flags help prevent session theft.

**Check:** after HTTPS is enabled, `curl -I https://example.com/login` should show `Set-Cookie` with `Secure; HttpOnly` attributes.

---

# 2 — Install system packages (Nginx, Git, Python tools, certbot)

Run the commands matching your OS.

### Amazon Linux 2 (or 2023-ish)

```bash
# update
sudo yum update -y

# install nginx, git
sudo yum install -y nginx git

# enable nginx
sudo systemctl enable --now nginx

# If Python3 not installed, install:
sudo yum install -y python3 python3-devel

# Create or upgrade pip
python3 -m pip install --upgrade pip setuptools wheel

# Install certbot (EPEL + certbot):
sudo amazon-linux-extras install epel -y
sudo yum install -y certbot python3-certbot-nginx
```

### Ubuntu (22.04+)

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y nginx git python3-venv python3-pip
sudo systemctl enable --now nginx
sudo apt install -y certbot python3-certbot-nginx
```

Why: Nginx will be the public-facing web server/reverse proxy; certbot obtains Let’s Encrypt certificates. Commands differ slightly by distro and package names. ([DigitalOcean][3])

**Check:** `sudo systemctl status nginx` should show active. `curl -I http://localhost` should return a basic nginx header.

---

# 3 — Set up your application (git clone, virtualenv, requirements)

If you already have the app in `/home/ec2-user/Applications/mad-colab`, skip clone. If you pull from git:

```bash
cd /home/ec2-user/Applications
git clone git@git.adityabaxla.link:/path/to/repo mad-colab
cd mad-colab

# create/use venv (if not already)
python3 -m venv .venv
source .venv/bin/activate

# install requirements
pip install --upgrade pip
pip install -r requirements.txt
```

If your git server requires an SSH key, add a deploy key to your git server and put the private key into `~/.ssh/` for `ec2-user`, or use `ssh-agent`.

**Check:** with venv active run:

```bash
# run a quick gunicorn test to ensure app loads:
./.venv/bin/gunicorn -b 127.0.0.1:8000 wsgi:app
# then in another terminal:
curl -I http://127.0.0.1:8000
```

You should receive an HTTP response (200 or redirect).

---

# 4 — Test run with Gunicorn (manual quick test)

From `/home/ec2-user/Applications/mad-colab`:

```bash
source .venv/bin/activate
# test with 2 workers, bind to local port for quick test
./.venv/bin/gunicorn --workers 2 --bind 127.0.0.1:8000 wsgi:app
```

**Check:** `curl -I http://127.0.0.1:8000` — you should see HTTP headers returned. If you see import errors, fix those before continuing. This verifies Gunicorn can import the app.

---

# 5 — Create a systemd service for Gunicorn (keeps app running)

Create `/etc/systemd/system/gunicorn-madcolab.service` with:

```ini
[Unit]
Description=gunicorn daemon for mad-colab
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/Applications/mad-colab
# PATH should point to your venv bin
Environment="PATH=/home/ec2-user/Applications/mad-colab/.venv/bin"
# optional: load environment variables from a file
EnvironmentFile=/home/ec2-user/Applications/mad-colab/.env

ExecStart=/home/ec2-user/Applications/mad-colab/.venv/bin/gunicorn \
  --workers 3 \
  --bind unix:/home/ec2-user/Applications/mad-colab/madcolab.sock \
  wsgi:app

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

**Notes & tips**

* `User`/`Group`: running as a non-root user is safer. `ec2-user` is common; you can create a specific `madcolab` user if preferred.
* We bind to a UNIX socket (faster & secure between Nginx and gunicorn). You can also bind to 127.0.0.1:8000 if you prefer.
* If you store secrets in `.env`, set `EnvironmentFile` path and `chmod 600` that file.

Activate service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now gunicorn-madcolab.service
```

**Check:**

* `sudo systemctl status gunicorn-madcolab.service` (should be active).
* `sudo journalctl -u gunicorn-madcolab -f` to stream logs; fix any errors.
* Confirm socket exists: `ls -l /home/ec2-user/Applications/mad-colab/madcolab.sock` (socket file should appear).
* If you bound to a port instead of socket, `ss -ltnp | grep gunicorn` will show the listening port.

Why systemd: it restarts the process if it crashes and starts it on boot — preferred over ad-hoc `gunicorn` background processes. See examples and rationale in systemd/gunicorn guides. ([Miguel Grinberg Blog][2])

---

# 6 — Configure Nginx as reverse proxy (serve app + static files)

Create `/etc/nginx/conf.d/madcolab.conf`:

```nginx
upstream madcolab {
    # using unix socket created by gunicorn
    server unix:/home/ec2-user/Applications/mad-colab/madcolab.sock;
}

server {
    listen 80;
    server_name example.com www.example.com;   # <--- replace with your domain or leave _ for testing

    # serve static files directly (adjust path if needed)
    location /static/ {
        alias /home/ec2-user/Applications/mad-colab/static/;
        try_files $uri =404;
    }

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://madcolab;
        proxy_read_timeout 120;
    }
}
```

Reload Nginx:

```bash
sudo nginx -t
sudo systemctl restart nginx
```

**Checks:**

* `sudo nginx -t` must report `ok`.
* `curl -I http://localhost/` should return an HTTP response from your Flask app.
* Check `sudo tail -F /var/log/nginx/error.log` for errors.

Why: Nginx handles TLS/HTTP, static files, and proxies requests to Gunicorn. The `proxy_set_header` lines forward the request metadata so app sees the correct host/protocol. See Nginx+Gunicorn tutorials for examples. ([DigitalOcean][3])

---

# 7 — Make the EC2 instance public & DNS mapping

### 7.1 Reserve an Elastic IP and attach it to your EC2 instance

Use the EC2 console → “Network & Security” → “Elastic IPs” → Allocate Elastic IP → Associate with instance. An Elastic IP gives you a static IPv4 address you can point DNS to (so you don’t have to change DNS when the instance restarts). ([AWS Documentation][1])

**Check:** `curl http://<elastic-ip>/` should return your site via nginx.

### 7.2 Security Group inbound rules (EC2)

* Open **Inbound** rules in the instance’s security group:

  * SSH (22) — restrict source to *your* IP (or 0.0.0.0/0 if you truly cannot restrict — **not recommended**). ([AWS Documentation][6])
  * HTTP (80) — 0.0.0.0/0
  * HTTPS (443) — 0.0.0.0/0

**Why:** Security Groups are the network-level firewall; only open what you need. ([AWS Documentation][6])

---

# 8 — Point Namecheap DNS to your Elastic IP (A record)

In Namecheap:

1. Sign into Namecheap → Domain List → Manage next to your domain.
2. Advanced DNS → Host Records → Add an A record:

   * Host: `@` → Value: `<your-elastic-ip>`
   * Host: `www` → Value: `<your-elastic-ip>` (if you want `www`)
     Follow Namecheap’s docs. After DNS propagation (minutes → hours) your domain will resolve. ([Namecheap][7])

**Check:** from your local machine:

```bash
dig +short example.com
# should show your elastic IP
curl -I http://example.com
```

---

# 9 — Enable HTTPS with Let’s Encrypt (certbot)

If `certbot` and the `certbot-nginx` plugin is installed:

```bash
# run once, interactive
sudo certbot --nginx -d example.com -d www.example.com
```

If `certbot --nginx` plugin is unavailable on your distro, use webroot mode:

```bash
sudo certbot certonly --webroot -w /home/ec2-user/Applications/mad-colab/static -d example.com -d www.example.com
# then update nginx to point to the certs ( /etc/letsencrypt/live/example.com/fullchain.pem etc )
```

Certbot will add the SSL vhost and configure auto-renewal (or you can add a cron). How you install certbot depends on distro; Amazon Linux needs EPEL/amazon-linux-extras in many cases. ([Let's Encrypt Community Support][4])

**Checks:**

* `sudo certbot certificates` shows the cert.
* `curl -I https://example.com` should return HTTP response and `openssl s_client -connect example.com:443 -servername example.com` will show cert details.
* `sudo certbot renew --dry-run` should succeed.

---

# 10 — SSH & security hardening (quick wins)

* Use only SSH keys, disable password authentication: `/etc/ssh/sshd_config` → `PasswordAuthentication no`, restart `sshd`.
* Lock SSH to your IP in the security group (not 0.0.0.0/0). ([AWS Documentation][6])
* Consider fail2ban to block brute force attempts (package available on Ubuntu; available on Amazon Linux via EPEL).
* Keep system packages updated (`sudo yum update -y` / `sudo apt upgrade -y` on a schedule).

**Check:** After changes, test SSH from your allowed IP. Confirm `sshd` restarts ok: `sudo systemctl restart sshd && sudo systemctl status sshd`.

---

# 11 — Deploying updates (workflow)

When you push code to your git server, on the EC2 instance:

```bash
cd /home/ec2-user/Applications/mad-colab
git pull origin main
source .venv/bin/activate
pip install -r requirements.txt    # in case of new deps
# If you need DB migrations, run them here (example flask-migrate)
# flask db upgrade

sudo systemctl restart gunicorn-madcolab.service
# optionally: sudo systemctl reload nginx
```

**Check:** `sudo journalctl -u gunicorn-madcolab -n 200` for new logs. `curl -I https://example.com` to validate the live site.

---

# 12 — Troubleshooting & useful commands (copy-paste)

* `sudo systemctl status gunicorn-madcolab` — check gunicorn service.
* `sudo journalctl -u gunicorn-madcolab -f` — live gunicorn logs.
* `sudo nginx -t && sudo systemctl restart nginx` — test and reload nginx.
* `sudo tail -F /var/log/nginx/error.log /var/log/nginx/access.log` — nginx logs.
* `ss -ltnp | grep LISTEN` — see open ports.
* `curl -vk https://example.com` — verbose HTTPS test.
* `dig +short example.com` — check DNS resolves.
* `sudo certbot renew --dry-run` — test cert renewal.

---

# 13 — Extra notes / best practices & alternatives

* **Elastic Load Balancer (ALB)**: If you want AWS-managed TLS termination and easier scaling, put an ALB in front of EC2 and let the ALB handle HTTPS, then point DNS to the ALB. (This is more AWS-native than running certbot on the instance). Many folks prefer ALB for production-grade deployments. (If you go ALB, you’ll still want systemd + gunicorn + nginx or skip nginx and let Gunicorn serve behind ALB.) ([Reddit][8])
* **Backups & snapshots**: take AMI or EBS snapshots before system changes.
* **Database**: if your app uses a database, consider AWS RDS for a managed DB instead of running on the same EC2.
* **Automation**: consider automating deployments with Github Actions + SSH deploy or an Ops tool (Ansible / Terraform) later.

---

# 14 — Helpful resources (the short list)

* Systemd + Gunicorn pattern (good examples & rationale): Miguel Grinberg’s blog. ([Miguel Grinberg Blog][2])
* Nginx reverse proxy + Gunicorn tutorial (clear examples): DigitalOcean guide. ([DigitalOcean][3])
* Elastic IPs & associating with instance: AWS EC2 docs. ([AWS Documentation][1])
* Security groups best practices: AWS VPC Security Groups docs. ([AWS Documentation][6])
* Point domain in Namecheap (how to add A records): Namecheap support doc. ([Namecheap][7])
* Certbot on Amazon Linux tips / EPEL notes: Let’s Encrypt community and related posts (Amazon Linux often needs EPEL). ([Let's Encrypt Community Support][4])
* ProxyFix / deploying behind a reverse proxy: Werkzeug / Flask docs. ([werkzeug.palletsprojects.com][5])

---

# 15 — Quick example checklist you can run now (copy-paste)

```bash
# 0: run on instance
cd /home/ec2-user/Applications/mad-colab
source .venv/bin/activate

# 1: quick gunicorn test
./.venv/bin/gunicorn --workers 2 --bind 127.0.0.1:8000 wsgi:app &

# 2: test
curl -I http://127.0.0.1:8000

# 3: stop test (if needed)
pkill -f 'gunicorn --workers 2'

# 4: enable systemd service you saved earlier
sudo systemctl daemon-reload
sudo systemctl enable --now gunicorn-madcolab.service
sudo systemctl status gunicorn-madcolab -n 30

# 5: test nginx
sudo nginx -t && sudo systemctl restart nginx
curl -I http://localhost/

# 6: DNS check (on your laptop)
dig +short example.com

# 7: certbot (after DNS -> elastic IP)
sudo certbot --nginx -d example.com -d www.example.com
```

---

If you want, I can now:

* generate the exact `wsgi.py`, `gunicorn-madcolab.service`, and the `nginx` vhost file filled in with your real domain and your app module name; **or**
* paste the exact commands in the order you should run them (script-like) given your instance is Amazon Linux or Ubuntu; **or**
* show the minimal changes you must make if your app’s entrypoint is `app.py` (i.e., what to replace in `wsgi.py` and in the `ExecStart`).

Tell me which of those you want and I’ll produce the ready-to-save files/commands (I won’t run anything for you).

[1]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/working-with-eips.html?utm_source=chatgpt.com "Associate an Elastic IP address with an instance"
[2]: https://blog.miguelgrinberg.com/post/running-a-flask-application-as-a-service-with-systemd?utm_source=chatgpt.com "Running a Flask Application as a Service with Systemd"
[3]: https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-gunicorn-and-nginx-on-ubuntu-22-04?utm_source=chatgpt.com "How To Serve Flask Applications with Gunicorn and Nginx ..."
[4]: https://community.letsencrypt.org/t/how-to-install-letsencrypt-in-amazon-linux-2-centos-rhel-fedora-using-nginx/159862?utm_source=chatgpt.com "How to install LetsEncrypt in Amazon Linux 2 (centos rhel ..."
[5]: https://werkzeug.palletsprojects.com/en/stable/deployment/proxy_fix/?utm_source=chatgpt.com "Tell Werkzeug it is Behind a Proxy"
[6]: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html?utm_source=chatgpt.com "Control traffic to your AWS resources using security groups"
[7]: https://www.namecheap.com/support/knowledgebase/article.aspx/319/2237/how-can-i-set-up-an-a-address-record-for-my-domain/?utm_source=chatgpt.com "How can I set up an A (address) record for my domain?"
[8]: https://www.reddit.com/r/aws/comments/tuoazq/namecheap_domain_with_ec2_instance_how_do_i_go/?utm_source=chatgpt.com "Namecheap domain with EC2 Instance. How do I go about ..."

# Nginx cant access socket, so localhost/ is not working but localhost:8000 is working.
The issue is a **permission denied** error. Nginx (running as the `nginx` user) can't access the socket file created by gunicorn (running as `ec2-user`).

Here are the solutions:

## Option 1: Add nginx user to ec2-user group (Recommended)

```bash
# Add nginx user to ec2-user group
sudo usermod -a -G ec2-user nginx

# Make the home directory accessible
chmod 710 /home/ec2-user
chmod 710 /home/ec2-user/Applications
chmod 710 /home/ec2-user/Applications/mad-colab

# Restart nginx to pick up the new group membership
sudo systemctl restart nginx
```

## Option 2: Modify the systemd service to set socket permissions

Edit your systemd service file:
```bash
sudo nano /etc/systemd/system/mad-flask.service
```

Add `--umask 0007` to the gunicorn command in the `ExecStart` line:
```ini
ExecStart=/home/ec2-user/Applications/mad-colab/.venv/bin/gunicorn --workers 3 --bind unix:/home/ec2-user/Applications/mad-colab/madcolab.sock --umask 0007 app:app
```

Then reload and restart:
```bash
sudo systemctl daemon-reload
sudo systemctl restart mad-flask
```

## Verify it works:

After applying either solution, check:
```bash
# Check socket permissions
ls -l /home/ec2-user/Applications/mad-colab/madcolab.sock

# Test from localhost
curl http://localhost
```

**Option 1 is cleaner and more secure** as it properly manages permissions through groups. Try that first!