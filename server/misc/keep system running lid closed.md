Good question — by default, Ubuntu (even the Server edition) suspends or sleeps when the laptop lid is closed. You can override that behavior so the laptop keeps running (useful for servers or headless setups).

Here’s how to do it step-by-step 👇

⸻

🧭 Step 1: Edit the logind configuration file

Run this command:

sudo nano /etc/systemd/logind.conf

Then find the line that says (or add it if it’s missing):

#HandleLidSwitch=suspend

Change it to:

HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore

You can also optionally add:

HandleLidSwitchExternalPower=ignore

(if you want it to stay awake even when on AC power).

⸻

🧭 Step 2: Restart systemd-logind

After saving (Ctrl+O, Enter, Ctrl+X), restart the service to apply changes:

sudo systemctl restart systemd-logind


⸻

🧭 Step 3: Verify the setting

You can confirm it’s applied with:

cat /etc/systemd/logind.conf | grep HandleLidSwitch

It should show the ignore values you set.

⸻

🧭 Step 4 (Optional): Check if suspend is still triggered

Run this to verify your laptop isn’t configured elsewhere to suspend:

sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

That command completely disables sleep in case some other service tries to trigger it.

If you ever want to re-enable them:

sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target


⸻

✅ Done!

Now you can safely close the lid — the laptop will continue running normally, even with the lid shut.

⸻

Would you like me to show you how to auto-start your server or services (like Python, Flask, etc.) on boot too, so you don’t need to log in every time?