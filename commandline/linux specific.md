## sasta tree command
ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'

## relations between distro and package manager frontend
ubuntu, mint, kali -> apt 
redhat based -> yum (rpm)
arch -> packman

