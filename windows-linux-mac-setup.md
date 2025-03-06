# Setup Guide for Windows, Linux, and macOS

This guide provides step-by-step instructions to set up your system MAD-2 project. Follow the steps for your operating system to get started quickly.

---

## Prerequisites

### Tools to Install
- **Python**
- **Node.js**


---

## Instructions for Windows 
[https://learn.microsoft.com/en-us/windows/wsl/install](Guide)

### 1. Install Windows Subsystem for Linux (WSL)
1. Open PowerShell/command prompt as Administrator.
2. Run:
   ```bash
   wsl --install
   ```
3. Restart your system if prompted.
4. A Ubuntu terminal should startup and prompt for username and password, put in usename and password of your choice. (password will be required when you use `sudo` command)
Note : Password written will not be shown in the screen, (it's normal behaviour). Type in you password and hit enter.

### 2. Install Required Tools
1. Search for WSL or Ubuntu in windows search and open it up (Ubuntu is recommended).
2. Run the following commands (updating the linux system):
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
   ```bash
   sudo apt install git python3 python3-pip -y
   ```

### 3. Install VSCode:

1. Go to [visualstudio.com](https://code.visualstudio.com/download)
2. Download and install the windows version.
3. Open vscode and navigate to extensions (view->extensions)
4. Search and install "wsl" by microsoft.

### 4. Clone the Repository (prefer to fork and clone the repo)
1. Open the Ubuntu terminal, navigate to your preferred directory:
   ```bash
   mkdir myFile
   cd myFile
   ```
2. Open VSCode in the current directory
   ```bash
   code .
   ```
It will install VSCode for Linux
3. VSCode should prompt you to reopen the folder in WSL, click on "reopen in wsl". (on the bottom right)


---

## Instructions for Linux

### 1. Update Your System
Run the following commands to ensure your system is up to date:
```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Install Required Tools
Install the necessary tools using the following commands:
```bash
sudo apt install git python3 python3-pip -y
```

### 3. Install VSCode:

1. Go to [visualstudio.com](https://code.visualstudio.com/download)
2. download the required file
3. Navigate to the directory where vscode is downloaded.
3. `sudo apt install ./<file>.deb`

### 3. Clone the Repository (prefer to fork and clone the repo)
1. Create a folder for the repository:
   ```bash
   mkdir myProject
   cd myProject
   ```
2. Clone the repository:
   ```bash
   git clone https://github.com/livinNector/iitm-bs-c-programming-lab
   ```
3. Move inside the newly created folder
   ```bash
   cd iitm-bs-c-programming-lab
   ```
Tip : you can hit tab to autocomplete folder/file name, example : cd iitm(tab), it will autocomplete the folder name.

### 4. Start Coding
Open the repository in your editor and start solving:
```bash
code .
```
Note : if this command does not work, open VSCode and goto open folder -> select the `iitm-bs-c-programming-lab` directory.

---

## Instructions for macOS (for macOS 13 or newer)
Note: for older versions we will use github codespaces.

### 1. Install Xcode Command Line Tools
Run the following command in your terminal:
```bash
xcode-select --install
```

### 2. Install Homebrew
If you don’t have Homebrew installed, run:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Install Required Tools
Use Homebrew to install the necessary tools:
```bash
brew install git python3
```


---
## Notes
- Replace `code .` with the command to open your preferred editor if you’re not using VSCode.
- Always run `git pull` inside the repository folder to fetch the latest updates before starting.


