# Lab 3 Completion Checklist

Use this checklist to verify you've completed all requirements for the lab.

## ✅ Task 0: Setup and Basic Programs

### Task 0.A: C Implementation (main.c)
- [ ] Program compiles with provided compilation commands
- [ ] Makefile created and automates compilation
- [ ] Program prints all command-line arguments
- [ ] Each argument is on a separate line
- [ ] No use of standard library (no printf, no stdio.h)
- [ ] Uses system_call() for output
- [ ] Tested with multiple arguments

**Test command:**
```bash
make task0
./task0 arg1 arg2 arg3
```

**Expected output:**
```
./task0
arg1
arg2
arg3
```

### Task 0.B: Assembly Hello World (task0b.s)
- [ ] Standalone assembly program (no C code)
- [ ] Contains _start entry point
- [ ] Prints "hello world" and newline
- [ ] Uses direct system call (int 0x80)
- [ ] Exits cleanly with sys_exit
- [ ] Compiles with: `nasm -f elf32 task0b.s -o task0b.o`
- [ ] Links with: `ld -m elf_i386 task0b.o -o task0b`

**Test command:**
```bash
make task0b
./task0b
```

**Expected output:**
```
hello world
```

## ✅ Task 1: Encoder in Assembly

### Task 1.A: Debug Printout
- [ ] main function written in assembly
- [ ] Prints all command-line arguments
- [ ] Each argument on separate line
- [ ] Uses only direct system calls (no library functions)
- [ ] May call strlen from util.c
- [ ] Exits using exit system call

**Test command:**
```bash
make task1
./task1 arg1 arg2 arg3
```

**Expected output:**
```
./task1
arg1
arg2
arg3
```

### Task 1.B: Basic Encoder
- [ ] Reads from stdin by default
- [ ] Writes to stdout by default
- [ ] Encodes 'A'-'Z' by adding 3
- [ ] Characters not in range 'A'-'Z' pass through unchanged
- [ ] Handles wraparound (X→A, Y→B, Z→C)
- [ ] Uses read and write system calls

**Test command:**
```bash
echo "HELLO WORLD" | ./task1
```

**Expected output:**
```
./task1
KHOOR ZRUOG
```

**Additional tests:**
```bash
echo "ABC" | ./task1     # Should output: DEF
echo "XYZ" | ./task1     # Should output: ABC
echo "abc" | ./task1     # Should output: abc (lowercase unchanged)
echo "A1B2C3" | ./task1  # Should output: D1E2F3
```

### Task 1.C: File I/O Support
- [ ] Supports -i{file} flag for input
- [ ] Supports -o{file} flag for output
- [ ] Can use both flags together
- [ ] Opens files using sys_open
- [ ] Closes files when done
- [ ] Error handling (exit 0x55 on file open failure)
- [ ] Prints error message to stderr on failure

**Test commands:**
```bash
# Test input file
echo "HELLO" > input.txt
./task1 -iinput.txt

# Test output file
echo "WORLD" | ./task1 -ooutput.txt
cat output.txt

# Test both
echo "TESTING" > input.txt
./task1 -iinput.txt -ooutput.txt
cat output.txt

# Clean up
rm input.txt output.txt
```

**Expected behavior:**
- Input file: Reads from file instead of stdin
- Output file: Writes to file instead of stdout
- Both: Reads from input file, writes to output file
- Missing file: Prints error and exits with code 0x55

## ✅ Task 2: Virus Attacher

### Task 2.A: Directory Listing
- [ ] Program written in C (without standard library)
- [ ] Uses sys_getdents system call
- [ ] Opens current directory (".")
- [ ] Prints all filenames in current directory
- [ ] Each filename on separate line
- [ ] Handles directory entries buffer (< 8192 bytes)
- [ ] Exits with 0x55 on error
- [ ] No use of standard library functions

**Test command:**
```bash
make task2
./task2
```

**Expected output:**
```
.
..
main.c
start.s
util.c
util.h
task0
task1
task2
[... all files in current directory ...]
```

### Task 2.A with Prefix Filtering
- [ ] Supports -a{prefix} flag
- [ ] Prints only files matching prefix
- [ ] Prefix is 2 characters minimum
- [ ] Bonus: Supports longer prefixes

**Test command:**
```bash
# Create test files
touch testfile1.txt testfile2.txt otherfile.txt
./task2 -atest
rm testfile1.txt testfile2.txt otherfile.txt
```

**Expected output:**
```
testfile1.txt
testfile2.txt
```

### Task 2.B: Virus Attachment
- [ ] Assembly code in start.s file
- [ ] Code starts with label "code_start"
- [ ] infection() function implemented
- [ ] infection() prints "Hello, Infected File"
- [ ] infection() uses just ONE system call
- [ ] infector(char*) function implemented
- [ ] infector() opens file with append flag
- [ ] infector() writes code from code_start to code_end
- [ ] infector() closes file
- [ ] infector() uses just a FEW system calls (open, write, close)
- [ ] Code ends with label "code_end"
- [ ] C program calls infector() for matching files
- [ ] Prints "VIRUS ATTACHED" next to infected files

**Test commands:**
```bash
# Create safe test files
echo "#!/bin/bash" > testscript1.sh
echo "echo 'Original script 1'" >> testscript1.sh
chmod +x testscript1.sh

echo "#!/bin/bash" > testscript2.sh
echo "echo 'Original script 2'" >> testscript2.sh
chmod +x testscript2.sh

# Attach virus
./task2 -atest

# Verify virus was attached
ls -la testscript*.sh  # Files should be larger now

# Test infected file
./testscript1.sh
# Should print: Hello, Infected File
#               Original script 1

# Clean up
rm testscript1.sh testscript2.sh
```

**Expected behavior:**
- Files matching prefix get virus code appended
- Program prints "VIRUS ATTACHED" next to those files
- When infected file is executed, it prints "Hello, Infected File"
- Original functionality still works (if applicable)

## ✅ Code Quality Requirements

### No Standard Library
- [ ] No #include <stdio.h>
- [ ] No #include <stdlib.h>
- [ ] No #include <string.h>
- [ ] No printf, scanf, fopen, fgetc, strcmp, etc.
- [ ] May include util.h and use provided utility functions
- [ ] All I/O done via system calls

### Compilation
- [ ] All files compile without errors
- [ ] All files compile without warnings
- [ ] Makefile works correctly
- [ ] Uses correct flags: -m32 -Wall -ansi -c -nostdlib -fno-stack-protector
- [ ] Uses correct linker: ld -m elf_i386

### Assembly Code Quality
- [ ] Follows CDECL calling convention
- [ ] Proper function prologue/epilogue
- [ ] Stack is balanced
- [ ] Registers saved/restored as needed
- [ ] Code is commented
- [ ] Labels are meaningful

### C Code Quality
- [ ] Code is readable
- [ ] Functions have clear purposes
- [ ] Variables have meaningful names
- [ ] Error checking on system calls
- [ ] Resources (files) are properly closed

## ✅ Documentation

- [ ] README.md explains how to build and run
- [ ] Code comments explain non-obvious parts
- [ ] Makefile has clear targets
- [ ] Testing instructions provided

## ✅ Testing

### Basic Functionality
- [ ] All programs compile successfully
- [ ] All programs run without crashing
- [ ] All programs produce expected output
- [ ] All programs handle errors gracefully

### Edge Cases
- [ ] Empty input (Ctrl+D)
- [ ] Invalid file names
- [ ] Files that don't exist
- [ ] No command-line arguments
- [ ] Many command-line arguments

### Error Handling
- [ ] Missing input file handled
- [ ] Missing output file handled (should create)
- [ ] Permission denied handled
- [ ] Exit code 0x55 on errors

## ✅ Advanced Requirements

### Task 1 Advanced
- [ ] Handles multiple -i and -o flags (uses last one)
- [ ] Proper file descriptor management
- [ ] Closes stdin/stdout only when appropriate

### Task 2 Advanced
- [ ] Prefix can be longer than 2 characters (bonus)
- [ ] Doesn't infect "." or ".." directories
- [ ] Handles large directories gracefully

### Task 2.C: Shortest Code Competition (Bonus)
- [ ] Minimized instruction count in infection()
- [ ] Minimized instruction count in infector()
- [ ] Code still works correctly
- [ ] Code is still readable

## 📝 Before Submission

- [ ] All code compiles without warnings or errors
- [ ] All tests pass
- [ ] Code is properly commented
- [ ] Makefile is complete
- [ ] No unnecessary files included
- [ ] README is clear and complete
- [ ] Tested on actual Linux system (not just theory)
- [ ] Backed up source code
- [ ] Committed to version control (if using)

## 🎯 Final Verification

Run this complete test sequence:

```bash
# Clean build
make clean
make all
make task0b
make task1
make task2

# Task 0 tests
./task0 arg1 arg2 arg3
./task0b

# Task 1 tests
echo "ABCXYZ" | ./task1
echo "TEST" > input.txt
./task1 -iinput.txt
echo "DATA" | ./task1 -ooutput.txt
cat output.txt
./task1 -iinput.txt -ooutput.txt
cat output.txt

# Task 2 tests
./task2
echo "test" > virustest.txt
chmod +x virustest.txt
./task2 -avirus

# Clean up
rm input.txt output.txt virustest.txt
```

All of the above should work without errors!

## 📊 Grading Self-Assessment

Estimate your grade based on completion:

- **Task 0** (Setup): ___ / 10 points
  - 0.A (Makefile + argv printing): ___ / 5
  - 0.B (Hello world in assembly): ___ / 5

- **Task 1** (Encoder): ___ / 45 points
  - 1.A (Print arguments): ___ / 15
  - 1.B (Basic encoder): ___ / 15
  - 1.C (File I/O): ___ / 15

- **Task 2** (Virus): ___ / 45 points
  - 2.A (Directory listing): ___ / 20
  - 2.B (Virus attachment): ___ / 25
  - 2.C (Shortest code bonus): ___ / +5

**Total**: ___ / 100 points (+ bonus)

## 🚀 Ready to Submit?

If you've checked all the boxes above, you're ready to submit!

Good luck! 🎉
