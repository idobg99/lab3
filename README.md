# Lab 3: Assembly Language and System Calls

## Overview
This lab implements various programs in assembly language and C (without the standard library) to work with system calls, command-line arguments, file I/O, and directory manipulation.

## Prerequisites
- nasm (Netwide Assembler)
- gcc (32-bit compilation support)
- ld (GNU linker)

On Ubuntu/Debian, install with:
```bash
sudo apt-get install nasm gcc-multilib
```

## Building the Programs

Use the provided Makefile to build all programs:

```bash
make all      # Build Task 0 (argument printer)
make task0b   # Build Task 0.B (hello world in assembly)
make task1    # Build Task 1 (encoder in assembly)
make task2    # Build Task 2 (virus attacher)
make clean    # Remove all compiled files
```

## Task 0: Arguments Printing

### Task 0.A: C Implementation
**File:** `main.c`

Prints all command-line arguments to stdout, each on a separate line.

**Build and run:**
```bash
make task0
./task0 arg1 arg2 arg3
```

### Task 0.B: Hello World in Assembly
**File:** `task0b.s`

A standalone assembly program that prints "hello world" to stdout.

**Build and run:**
```bash
make task0b
./task0b
```

## Task 1: Simplified Encoder in Assembly

**File:** `task1.s`

A simplified encoder program that:
- Reads characters from input (stdin by default)
- Encodes characters 'A'-'Z' by adding 3 (with wraparound)
- Outputs encoded characters (stdout by default)
- All code is in assembly language

### Task 1.A: Debug Printout
Prints all command-line arguments to stdout.

### Task 1.B: Basic Encoder
Encodes from stdin to stdout.

**Usage:**
```bash
make task1
echo "HELLO WORLD" | ./task1
# Output: KHOOR ZRUOG
```

### Task 1.C: File I/O Support
Supports input/output file redirection.

**Usage:**
```bash
# Encode from file to stdout
./task1 -iinput.txt

# Encode from stdin to file
echo "HELLO" | ./task1 -ooutput.txt

# Encode from file to file
./task1 -iinput.txt -ooutput.txt
```

**Options:**
- `-i{file}` - Read input from the specified file
- `-o{file}` - Write output to the specified file

## Task 2: Virus Attacher

**Files:** `task2.c`, `start.s` (with infection/infector functions)

A program that lists files in the current directory and can attach "virus" code to files.

### Task 2.A: Directory Listing
Lists all files in the current directory.

**Usage:**
```bash
make task2
./task2
```

### Task 2.B: Virus Attachment
Attaches executable code to files matching a given prefix.

**Usage:**
```bash
# List all files starting with "te" and attach virus
./task2 -ate

# This will:
# 1. List all files in current directory
# 2. For files starting with "te", print "VIRUS ATTACHED"
# 3. Append the virus code to those files
```

**Warning:** The virus attachment modifies files! Test carefully with non-critical files.

**How it works:**
1. The `infection()` function prints "Hello, Infected File"
2. The `infector(filename)` function appends the code between `code_start` and `code_end` labels to the specified file
3. When an infected file is executed, it runs the virus code

**Testing:**
```bash
# Create test files
echo "test file 1" > test1.txt
echo "test file 2" > test2.txt
chmod u+wx test1.txt test2.txt

# Attach virus to files starting with "test"
./task2 -atest

# The files will now have the virus code appended
```

## Implementation Details

### System Calls Used
- `sys_write (4)` - Write to file descriptor
- `sys_read (3)` - Read from file descriptor
- `sys_open (5)` - Open file
- `sys_close (6)` - Close file descriptor
- `sys_exit (1)` - Exit program
- `sys_getdents (141)` - Get directory entries

### Calling Convention
All code follows the CDECL C calling convention:
- Arguments pushed right-to-left on stack
- Caller cleans up stack
- Return value in EAX register

### Key Features
- **No Standard Library:** All code uses direct system calls
- **32-bit x86 Assembly:** Uses IA-32 instruction set
- **Direct System Calls:** Uses `int 0x80` for Linux system calls
- **Mixed C/Assembly:** Demonstrates calling assembly from C and vice-versa

## File Descriptions

- `main.c` - Task 0.A: Prints command-line arguments
- `start.s` - Entry point, system_call wrapper, and virus functions
- `task0b.s` - Task 0.B: Hello world in pure assembly
- `task1.s` - Task 1: Complete encoder in assembly
- `task2.c` - Task 2: Directory listing and virus attachment
- `util.c/util.h` - Utility functions (strlen, strcmp, etc.)
- `makefile` - Build automation

## Notes

- All programs are 32-bit (use `-m32` flag)
- Programs do not use the C standard library (`-nostdlib`)
- Stack protection is disabled (`-fno-stack-protector`)
- Error exit code is 0x55 (85 in decimal)

## Troubleshooting

**Problem:** `fatal error: sys/cdefs.h: No such file or directory`
**Solution:** Install 32-bit development libraries:
```bash
sudo apt-get install gcc-multilib
```

**Problem:** Programs don't execute
**Solution:** Ensure files have execute permissions:
```bash
chmod +x task0 task0b task1 task2
```

## Learning Objectives

1. Understanding assembly language basics
2. Making direct Linux system calls
3. Working without the C standard library
4. Understanding the CDECL calling convention
5. Mixing C and assembly code
6. Low-level file and directory operations
7. Understanding how viruses can attach to files
