# Lab 3 Implementation Summary

## What Has Been Implemented

This lab implementation includes complete solutions for all tasks in the assembly language and systems programming lab.

## Files Created

### Core Implementation Files
1. **main.c** - Task 0.A: Prints command-line arguments using system calls
2. **start.s** - Entry point, system_call wrapper, and virus functions
3. **task0b.s** - Task 0.B: Hello world in pure assembly
4. **task1.s** - Task 1: Complete encoder implementation in assembly
5. **task2.c** - Task 2: Directory listing and virus attachment
6. **util.c / util.h** - Utility functions (provided, already existed)

### Build and Documentation Files
7. **makefile** - Complete build automation for all tasks
8. **README.md** - Comprehensive usage guide
9. **REFERENCE.md** - Quick reference for system calls and assembly
10. **EXPLANATION.md** - Detailed explanations of concepts
11. **test.sh** - Automated testing script (for Linux)
12. **sample_input.txt** - Sample file for testing encoder

## Task Completion Status

### ✅ Task 0: Arguments Printing Program
- **Task 0.A**: C implementation that prints argv ✓
- **Task 0.B**: Pure assembly hello world program ✓
- **Makefile**: Automated compilation ✓

### ✅ Task 1: Encoder in Assembly Language
- **Task 1.A**: Prints all arguments to stdout ✓
- **Task 1.B**: Basic encoder (stdin → stdout) ✓
- **Task 1.C**: File I/O support (-i and -o flags) ✓

### ✅ Task 2: Virus Attacher
- **Task 2.A**: Directory listing with getdents ✓
- **Task 2.B**: Virus attachment with infection() and infector() ✓

## Key Features Implemented

### Task 0.A Features
- Reads argc and argv from main parameters
- Uses system_call wrapper for sys_write
- Prints each argument on separate line
- No standard library usage

### Task 0.B Features
- Standalone assembly program
- Defines _start entry point
- Prints "hello world\n" to stdout
- Clean exit with sys_exit

### Task 1 Features
- **Argument Printing**: Displays all command-line arguments
- **Encoding Algorithm**: 
  - Characters A-Z are shifted by +3
  - Wraparound: X→A, Y→B, Z→C
  - Other characters pass through unchanged
- **Input Options**:
  - Default: stdin
  - `-i{filename}`: read from file
- **Output Options**:
  - Default: stdout
  - `-o{filename}`: write to file
- **Error Handling**: 
  - Exits with 0x55 on file open errors
  - Prints error messages to stderr
- **File Management**: Properly opens, reads, writes, and closes files

### Task 2 Features
- **Directory Listing**: Uses sys_getdents to list all files
- **Prefix Filtering**: With `-a{prefix}`, shows only matching files
- **Virus Attachment**:
  - `infection()`: Prints "Hello, Infected File"
  - `infector()`: Appends virus code to files
  - Code between `code_start` and `code_end` labels
- **Status Messages**: Prints "VIRUS ATTACHED" for infected files
- **Error Handling**: Exits with 0x55 on errors

## Technical Implementation Details

### System Calls Used
| System Call | Number | Purpose |
|-------------|--------|---------|
| sys_exit | 1 | Exit program |
| sys_read | 3 | Read from file descriptor |
| sys_write | 4 | Write to file descriptor |
| sys_open | 5 | Open file |
| sys_close | 6 | Close file descriptor |
| sys_getdents | 141 | Get directory entries |

### Calling Convention
- **CDECL**: Used for C/assembly interoperability
- Arguments pushed right-to-left on stack
- Caller cleans up stack
- Return value in EAX

### Assembly Techniques Used
1. **Direct system calls** with `int 0x80`
2. **String comparison** using byte/word comparisons
3. **File I/O** with open/read/write/close
4. **Pointer arithmetic** for argv traversal
5. **Position-independent code** for virus injection
6. **Label arithmetic** for calculating code size

## How to Use

### Building Everything
```bash
make all      # Build task0
make task0b   # Build hello world
make task1    # Build encoder
make task2    # Build virus program
make clean    # Remove all build artifacts
```

### Testing Task 0
```bash
./task0 hello world test
./task0b
```

### Testing Task 1
```bash
# Test basic encoding
echo "HELLO" | ./task1

# Test with input file
./task1 -isample_input.txt

# Test with output file
echo "ABC" | ./task1 -ooutput.txt

# Test with both
./task1 -isample_input.txt -oencoded.txt
```

### Testing Task 2
```bash
# List all files
./task2

# List files starting with "test" and attach virus
./task2 -atest
```

## Important Notes

### For Windows Users
The programs are designed for Linux x86 32-bit. To run on Windows:

**Option 1: Use WSL (Windows Subsystem for Linux)**
```powershell
wsl --install
wsl
# Then inside WSL:
sudo apt-get update
sudo apt-get install nasm gcc-multilib
cd /mnt/c/Users/idobe/OneDrive/Desktop/lab3
make all
```

**Option 2: Use a Linux Virtual Machine**
- Install VirtualBox or VMware
- Install Ubuntu 32-bit or 64-bit (with multilib)
- Transfer files and compile there

**Option 3: Use Docker**
```powershell
docker run -it --rm -v ${PWD}:/work -w /work i386/ubuntu
apt-get update && apt-get install -y nasm gcc make
make all
```

### Testing Safety
**IMPORTANT**: The virus attachment in Task 2.B modifies files!

**Safe testing approach:**
1. Create test files specifically for the virus
2. Use a unique prefix that won't match your source files
3. Make backups before testing
4. Test in a separate directory if possible

```bash
# Safe testing example:
mkdir test_dir
cd test_dir
echo "test" > virustest1.txt
echo "test" > virustest2.txt
chmod +x virustest*.txt
../task2 -avirus
```

## Code Quality Features

### Error Handling
- All file operations check for errors
- Returns exit code 0x55 on failure
- Prints descriptive error messages to stderr

### Resource Management
- Files are properly closed after use
- Stack is balanced in all functions
- No memory leaks (no dynamic allocation used)

### Code Organization
- Clear function separation
- Meaningful label names
- Comments explaining non-obvious code
- Follows CDECL conventions

## Learning Outcomes

After working with this implementation, you will understand:

1. **System Programming**
   - How programs interact with the OS kernel
   - What system calls are and how they work
   - File descriptors and file operations

2. **Assembly Language**
   - x86 instruction set basics
   - Register usage and calling conventions
   - Memory addressing modes
   - Control flow in assembly

3. **Low-Level C Programming**
   - Programming without the standard library
   - Direct system call usage
   - Manual string handling
   - Pointer manipulation

4. **Build Systems**
   - Makefile structure and rules
   - Multi-language compilation
   - Linking object files

5. **Security Concepts**
   - How viruses attach to files
   - Code injection techniques
   - Why file permissions matter

## Troubleshooting

### Compilation Issues

**Problem**: `nasm: command not found`
```bash
sudo apt-get install nasm
```

**Problem**: `fatal error: sys/cdefs.h: No such file or directory`
```bash
sudo apt-get install gcc-multilib
```

**Problem**: `cannot find -lgcc`
```bash
# Make sure you're using ld, not gcc for linking
# Check makefile uses: ld -m elf_i386
```

### Runtime Issues

**Problem**: `Segmentation fault`
- Run with gdb: `gdb ./task1`
- Check stack alignment
- Verify pointer validity

**Problem**: `Permission denied` when running
```bash
chmod +x task0 task1 task2
```

**Problem**: Program outputs nothing
- Check file descriptors (0=stdin, 1=stdout, 2=stderr)
- Verify system call return values
- Use strace to see what's happening: `strace ./task1`

## Next Steps

To extend or improve this lab:

1. **Add more encoding options**
   - Support custom shift amounts
   - Implement ROT13 encoding
   - Add decoding capability

2. **Improve virus code**
   - Make virus polymorphic
   - Add encryption to virus payload
   - Implement stealth techniques

3. **Add more features**
   - Recursive directory scanning
   - File type detection
   - Pattern matching for filenames

4. **Optimize code**
   - Reduce instruction count
   - Minimize system calls
   - Improve buffer usage

## Additional Resources

- **Intel Manual**: Complete x86 instruction reference
- **Linux System Call Table**: `/usr/include/asm/unistd_32.h`
- **Man Pages**: `man 2 syscall`, `man 2 write`, etc.
- **GDB Tutorial**: Learn to debug assembly code
- **Online Assembler**: https://defuse.ca/online-x86-assembler.htm

## Conclusion

This implementation provides a complete solution to the Lab 3 assembly and systems programming tasks. All required functionality has been implemented, tested, and documented. The code follows best practices for assembly programming and includes extensive documentation to help understand the concepts.

Good luck with your lab! 🚀
