# Lab 3 Overview - What, Why, and How

## 🎯 The Big Picture: What Is This Lab About?

This lab teaches you **how programs work at the lowest level** - interacting directly with the operating system without any libraries. You're learning what happens "under the hood" when you use normal C functions like `printf()` or `fopen()`.

**Main Goal**: Write programs in assembly language and C that make **direct system calls** to the Linux kernel, without using the C standard library.

---

## 📚 Breaking Down the Tasks

### **Task 0: Getting Started with System Calls**

**Purpose**: Learn the basics of compiling mixed C/assembly code and making system calls.

**Task 0.A - Print Arguments (C)**
- **What**: Print command-line arguments using only system calls
- **Why**: Learn how to use `system_call()` wrapper instead of `printf()`
- **What I Did**: Used `system_call(SYS_WRITE, STDOUT, string, length)` in a loop to print each argv element

**Task 0.B - Hello World (Assembly)**
- **What**: Write a complete program in pure assembly
- **Why**: Understand what the C runtime normally does for you (the `_start` function)
- **What I Did**: Created assembly file with `_start` label, used `int 0x80` to make sys_write and sys_exit calls

---

### **Task 1: The Encoder Program (All in Assembly)**

**Purpose**: Implement a real program entirely in assembly - reading input, processing data, writing output, handling files.

**The Encoding Algorithm**: Shift letters A-Z forward by 3 positions
- A→D, B→E, ..., W→Z, X→A, Y→B, Z→C (wraparound)
- Everything else stays the same

**Task 1.A - Debug Printout**
- **What**: Print all command-line arguments (like Task 0, but in assembly)
- **Why**: Learn how to access `argc`/`argv` in assembly using CDECL convention
- **What I Did**: 
  - Retrieved argc/argv from stack via `[ebp+8]` and `[ebp+12]`
  - Looped through argv array (pointer arithmetic with `esi + edi*4`)
  - Called C's `strlen()` from assembly
  - Made sys_write calls to print each argument

**Task 1.B - Basic Encoder**
- **What**: Read from stdin, encode characters, write to stdout
- **Why**: Learn file I/O at the system call level
- **What I Did**:
  - Used global variables `Infile` (default=0=stdin) and `Outfile` (default=1=stdout)
  - Loop: read 1 byte → check if 'A'-'Z' → add 3 with wraparound → write 1 byte
  - Wraparound logic: if result > 'Z', subtract 26

**Task 1.C - File I/O**
- **What**: Add support for `-i{filename}` and `-o{filename}` flags
- **Why**: Learn file operations (open/close) at system level
- **What I Did**:
  - Parse command-line: check if `word [eax]` equals `0x692D` (little-endian for "-i")
  - Use `sys_open` with appropriate flags (O_RDONLY for input, O_WRONLY|O_CREAT|O_TRUNC for output)
  - Store file descriptors in `Infile`/`Outfile` variables
  - Close files at end (but not stdin/stdout)

---

### **Task 2: Virus Attachment Program (C + Assembly)**

**Purpose**: Understand how malware can attach itself to files (for educational/security awareness).

**Task 2.A - Directory Listing**
- **What**: List files in current directory, optionally filtered by prefix
- **Why**: Learn how directory operations work at the system level
- **What I Did**:
  - Used `sys_getdents` to read directory entries into a buffer
  - Parsed the buffer as `struct linux_dirent` structures
  - Implemented `starts_with()` function to match prefix
  - Printed matching filenames

**Task 2.B - Virus Attachment**
- **What**: Append executable code to files that match a prefix
- **Why**: Demonstrate how viruses propagate (and why you need antivirus software!)
- **What I Did**:
  - **In assembly (start.s)**:
    - Created `code_start` and `code_end` labels
    - `infection()`: One sys_write to print "Hello, Infected File"
    - `infector(filename)`: Open file in append mode, write bytes from code_start to code_end, close file
  - **In C (task2.c)**:
    - When `-a{prefix}` flag is provided and file matches prefix
    - Print "VIRUS ATTACHED" message
    - Call `infector(filename)` to append virus code
  
**How the virus works**: The code between `code_start` and `code_end` is appended to files. If those files are executed, the virus code runs first.

---

## 🔧 Technical Implementation Highlights

### Key Concepts Used:

1. **System Calls via `int 0x80`**
   ```asm
   mov eax, 4        ; sys_write
   mov ebx, 1        ; stdout
   mov ecx, msg      ; buffer
   mov edx, len      ; length
   int 0x80          ; invoke kernel
   ```

2. **CDECL Calling Convention**
   - Arguments pushed right-to-left
   - Caller cleans up stack
   - Function accesses args via `[ebp+8]`, `[ebp+12]`, etc.

3. **Little-Endian Architecture**
   - String "-i" stored as `2D 69` in memory
   - Read as word: `0x692D`

4. **Position-Independent Code**
   - Virus code uses no absolute addresses
   - Can be copied anywhere and still work

### Files Created:
- **main.c** - Task 0.A (C with system calls)
- **task0b.s** - Task 0.B (pure assembly hello world)
- **task1.s** - Task 1 (complete encoder in assembly)
- **task2.c** - Task 2 (directory listing + virus attachment in C)
- **start.s** - Modified to add infection() and infector() functions
- **makefile** - Automates compilation of all tasks

---

## 💡 What You Learn From This Lab

1. **What happens below the standard library** - `printf()` eventually calls `write()`
2. **How programs start** - The `_start` function sets up argc/argv before calling main()
3. **Assembly language basics** - Instructions, registers, memory addressing
4. **System programming** - Direct interaction with OS kernel
5. **Security awareness** - How viruses attach to files (and why this is dangerous!)

---

## ✅ Verification - Everything Matches Requirements

✓ No standard library usage (`-nostdlib` flag)  
✓ Task 0.A prints argv using system calls  
✓ Task 0.B is standalone assembly  
✓ Task 1.A prints arguments in assembly  
✓ Task 1.B encodes stdin→stdout  
✓ Task 1.C supports `-i` and `-o` flags  
✓ Task 2.A lists directory with sys_getdents  
✓ Task 2.B has infection() with ONE system call  
✓ Task 2.B has infector() with THREE system calls (open, write, close)  
✓ Virus code between code_start and code_end labels  
✓ Error exit code is 0x55  
✓ Makefile automates compilation  

---

## 🎓 In Simple Terms

**You're learning to speak directly to the operating system in its native language (system calls), rather than using the "interpreter" that the C standard library provides. It's like learning to order food in the local language instead of using a translation app - harder at first, but you understand exactly what's happening!**
