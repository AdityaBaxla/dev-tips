# command line basics

wsl : change password of user
Ubuntu (Default)

C:\Users\rishab>ubuntu config --default-user root


C:\Users\rishab>ubuntu config --default-user appdeve
id: ‘appdeve’: no such user
Error: 0x80070057 The parameter is incorrect.


C:\Users\rishab>ubuntu config --default-user appdev

### what does & do in terminal / cmd
The & makes the command run in the background.

From man bash:

If a command is terminated by the control operator &, the shell executes the command in the background in a

### rename 
mv <oldname> <newname>

## nextline
if you pree '\' then enter then command will not execute

## How to quit applications
-alt+F2

## Using venv and requirement in python
```
python -m venv .venv
.\.venv\Scripts\activate -> windows
source .venv/bin/activate -> linux
after installing all the dependencies
pip freeze > requirement.txt
for installing all the dependencies
pip install -r .\requirements.txt
```
