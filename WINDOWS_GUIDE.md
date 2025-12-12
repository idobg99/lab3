# Running Lab 3 on Windows

This lab is designed for Linux x86 32-bit systems. Here are your options for running it on Windows.

## ⭐ Recommended: Windows Subsystem for Linux (WSL)

WSL is the easiest way to run Linux programs on Windows 10/11.

### Step 1: Install WSL

Open PowerShell as Administrator and run:

```powershell
wsl --install
```

This installs Ubuntu by default. Restart your computer when prompted.

### Step 2: Set Up Ubuntu in WSL

After restart, Ubuntu will open automatically. Create a username and password.

### Step 3: Install Required Tools

In the Ubuntu terminal:

```bash
sudo apt-get update
sudo apt-get install nasm gcc gcc-multilib make
```

### Step 4: Navigate to Your Lab Directory

Your Windows drives are mounted under `/mnt/`:

```bash
cd /mnt/c/Users/idobe/OneDrive/Desktop/lab3
```

### Step 5: Build and Run

```bash
make all
./task0 hello world
./task0b
echo "HELLO" | ./task1
./task2
```

### Tips for WSL

- **Edit files**: You can edit files with VS Code or any Windows editor
- **File permissions**: You may need to fix line endings if you get errors:
  ```bash
  dos2unix *.c *.s *.h makefile
  # If dos2unix is not installed:
  sudo apt-get install dos2unix
  ```
- **View output**: Everything runs in the Ubuntu terminal window

## Option 2: Docker

If you have Docker Desktop installed:

### Step 1: Create a Dockerfile

Create a file named `Dockerfile` in your lab3 directory:

```dockerfile
FROM i386/ubuntu:latest

RUN apt-get update && \
    apt-get install -y nasm gcc make && \
    apt-get clean

WORKDIR /lab3
```

### Step 2: Build the Docker Image

In PowerShell, navigate to your lab directory:

```powershell
cd C:\Users\idobe\OneDrive\Desktop\lab3
docker build -t lab3 .
```

### Step 3: Run the Container

```powershell
docker run -it --rm -v ${PWD}:/lab3 lab3
```

### Step 4: Build and Run Inside Container

```bash
make all
./task0 hello world
./task1 < sample_input.txt
```

## Option 3: Virtual Machine

### Step 1: Download VirtualBox
- Download from: https://www.virtualbox.org/

### Step 2: Download Ubuntu ISO
- Get Ubuntu 22.04 from: https://ubuntu.com/download/desktop

### Step 3: Create Virtual Machine
1. Open VirtualBox
2. Click "New"
3. Name: "Lab3"
4. Type: Linux
5. Version: Ubuntu (32-bit) or (64-bit)
6. Memory: 2048 MB
7. Create virtual hard disk (20 GB)

### Step 4: Install Ubuntu
1. Start the VM
2. Select the Ubuntu ISO when prompted
3. Follow installation wizard

### Step 5: Install Tools
```bash
sudo apt-get update
sudo apt-get install nasm gcc gcc-multilib make
```

### Step 6: Transfer Files
Use shared folders or copy files via SSH/SCP.

## Option 4: Linux on Physical Hardware

If you have a spare computer or USB drive, you can install Linux directly:

1. Download Ubuntu 22.04
2. Create bootable USB with Rufus (https://rufus.ie/)
3. Boot from USB
4. Install or run as Live USB
5. Install tools and run the lab

## Compilation Commands for Windows (If Using MinGW/Cygwin - NOT RECOMMENDED)

⚠️ **Warning**: This lab uses Linux-specific system calls. MinGW/Cygwin won't work properly!

The `int 0x80` instruction and system call numbers are Linux-specific and won't work on Windows.

## Comparing Options

| Method | Difficulty | Speed | Isolation | Recommendation |
|--------|-----------|-------|-----------|----------------|
| **WSL** | ⭐ Easy | ⭐⭐⭐ Fast | Medium | **Best for most users** |
| **Docker** | ⭐⭐ Medium | ⭐⭐ Medium | High | Good if you know Docker |
| **Virtual Machine** | ⭐⭐⭐ Hard | ⭐ Slow | High | Good for learning Linux |
| **Physical Linux** | ⭐⭐⭐ Hard | ⭐⭐⭐ Fast | High | Best performance |

## Using VS Code with WSL

You can edit files in VS Code and compile in WSL:

### Step 1: Install VS Code Extension

Install the "WSL" extension in VS Code.

### Step 2: Open Folder in WSL

1. Open VS Code
2. Press `Ctrl+Shift+P`
3. Type "WSL: Open Folder in WSL"
4. Navigate to `/mnt/c/Users/idobe/OneDrive/Desktop/lab3`

### Step 3: Open Integrated Terminal

Press `` Ctrl+` `` to open terminal (it will be a WSL terminal)

### Step 4: Build and Run

```bash
make all
./task0 hello world
```

## Common Issues on Windows

### Issue: Line Ending Problems

**Symptom**: Scripts fail with weird errors like `$'\r': command not found`

**Solution**: Convert line endings to Unix format
```bash
dos2unix *.c *.s makefile
```

Or in your editor, save with LF line endings instead of CRLF.

### Issue: File Permissions

**Symptom**: Files created in Windows don't have execute permission

**Solution**: 
```bash
chmod +x task0 task0b task1 task2
```

### Issue: Path with Spaces

**Symptom**: Errors accessing `OneDrive` path

**Solution**: Use quotes or escape spaces:
```bash
cd "/mnt/c/Users/idobe/OneDrive/Desktop/lab3"
```

### Issue: Cannot Find Files

**Symptom**: `make: *** No rule to make target...`

**Solution**: Make sure you're in the correct directory:
```bash
pwd
ls -la
```

## Quick Start for WSL (TL;DR)

```powershell
# In PowerShell (as Administrator):
wsl --install

# Restart computer, then in Ubuntu:
sudo apt-get update
sudo apt-get install -y nasm gcc gcc-multilib make
cd /mnt/c/Users/idobe/OneDrive/Desktop/lab3
make all
./task0 hello world
echo "ABC" | ./task1
./task2
```

## Testing Your Setup

After installation, verify everything works:

```bash
# Check NASM
nasm -version
# Should show: NASM version 2.x.x

# Check GCC
gcc --version
# Should show: gcc (Ubuntu ...) 

# Check 32-bit support
gcc -m32 --version
# Should work without errors

# Build hello world test
make task0b
./task0b
# Should print: hello world
```

## Where to Get Help

- **WSL Issues**: https://docs.microsoft.com/en-us/windows/wsl/
- **Docker Issues**: https://docs.docker.com/
- **Ubuntu Help**: https://help.ubuntu.com/
- **Lab Questions**: Ask your TA or instructor

## File Editing Tips

### Option 1: Edit in Windows, Compile in WSL
- Edit `.c` and `.s` files with any Windows editor
- Save changes
- Switch to WSL terminal and run `make`

### Option 2: Use VS Code Remote
- Install "Remote - WSL" extension
- Open folder in WSL mode
- Edit and compile all in one window

### Option 3: Use Linux Editors
- `nano`: Simple editor (`nano file.c`)
- `vim`: Powerful but steep learning curve (`vim file.c`)
- `gedit`: If you install Ubuntu desktop in VM

## Backup Your Work

Before testing the virus attachment code, backup your files!

```bash
# Create backup
cp -r /mnt/c/Users/idobe/OneDrive/Desktop/lab3 /mnt/c/Users/idobe/OneDrive/Desktop/lab3_backup

# Or use tar
tar -czf lab3_backup.tar.gz .
```

## Summary

**Best approach for Windows users:**
1. Install WSL (5 minutes)
2. Install build tools (2 minutes)
3. Navigate to lab folder
4. Run `make all` and start testing

This gives you a real Linux environment without rebooting or dual-booting!

Good luck! 🎉
