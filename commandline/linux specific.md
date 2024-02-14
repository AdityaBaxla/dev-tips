## sasta tree command
ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'

## relations between distro and package manager frontend
ubuntu, mint, kali -> apt 
redhat based -> yum (rpm)
arch -> packman

## add custom shortcuts
Go to System Settings
Select Keyboard
Open the Shortcuts tab
Click the + symbol at the bottom of the window
Enter gnome-system-monitor as the command
Click Apply
Click Disabled on the new shortcut 
