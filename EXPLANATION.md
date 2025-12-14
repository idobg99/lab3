# Lab 3 Detailed Explanation

## Understanding the Lab Structure

This lab teaches you how to write low-level programs without using the C standard library. Instead, you'll make direct system calls to the Linux kernel.

## What is a System Call?

A system call is a way for programs to request services from the operating system kernel. Examples:
- Reading/writing files
- Opening/closing files
- Creating processes
- Getting directory listings

### How System Calls Work on x86 Linux

1. Put the system call number in `eax`
2. Put arguments in `ebx`, `ecx`, `edx`, `esi`, `edi` (in that order)
3. Execute `int 0x80` instruction
4. Return value comes back in `eax`

Example:
```asm
; write(1, "hello", 5)
mov eax, 4       ; sys_write = 4
mov ebx, 1       ; stdout = 1
mov ecx, msg     ; pointer to "hello"
mov edx, 5       ; length = 5
int 0x80         ; make the system call
```

## Task Breakdown

### Task 0.A: Printing Arguments in C

**Goal:** Learn to use system calls from C

**Key concepts:**
- The `system_call()` function wraps the `int 0x80` instruction
- You pass system call number and arguments just like a regular function
- No `printf`! Use `system_call(4, 1, string, length)` for writing

**How it works:**
```c
system_call(SYS_WRITE, STDOUT, argv[i], strlen(argv[i]));
```
This translates to: "write to stdout the string argv[i] with length strlen(argv[i])"

### Task 0.B: Hello World in Pure Assembly

**Goal:** Write a complete program in assembly without any C code

**Key concepts:**
- Program needs an `_start` label (entry point)
- String data goes in `.data` section
- Must manually call `sys_exit` to exit cleanly

**Why this matters:**
This shows you what happens "under the hood" when a C program runs. The C standard library provides `_start` for you, but here you write it yourself.

### Task 1: Encoder in Assembly

This is the core of the lab. You're implementing a program that:
1. Prints its arguments (Task 1.A)
2. Encodes characters (Task 1.B)
3. Handles file I/O (Task 1.C)

**The Encoding Algorithm:**
```
For each character:
    If 'A' <= character <= 'Z':
        character = character + 3
        if character > 'Z':
            character = character - 26
```

So: A→D, B→E, ..., X→A, Y→B, Z→C

**Command-line parsing:**
```asm
; To check if argv[i] is "-i{filename}":
mov eax, [esi + edi*4]     ; Get pointer to argv[i]
cmp word [eax], 0x692D     ; Compare first 2 bytes with "-i"
je .handle_input           ; If match, handle input file
```

**Why `0x692D`?**
- 'i' = 0x69
- '-' = 0x2D
- x86 is little-endian, so "-i" is stored as `2D 69` in memory
- Reading as a word gives `0x692D`

### Task 2: Virus Attacher

**Goal:** Understand how viruses can attach themselves to files

**How it works:**

1. **Directory Listing (Task 2.A):**
   - Open current directory (".")
   - Call `getdents` to get all directory entries
   - Parse the returned buffer
   - Print filenames

2. **Virus Attachment (Task 2.B):**
   - The "virus" is the code between `code_start` and `code_end` labels
   - `infection()` prints a message (the "payload")
   - `infector(filename)` appends the virus code to a file
   - When the infected file is executed, the virus code runs

**The Virus Code:**
```asm
code_start:
    infection:
        ; Print "Hello, Infected File"
        ; ...
    
    infector:
        ; Open file in append mode
        ; Write bytes from code_start to code_end
        ; Close file
code_end:
```

**Why this works:**
The virus code is self-contained and position-independent. When appended to a file and the file is executed (if it's executable), the virus code will run.

## Common Challenges and Solutions

### Challenge 1: "Why can't I use printf?"

**Answer:** `printf` is part of the C standard library. This lab teaches you what's "below" the standard library. You're learning how `printf` itself is implemented (it eventually calls `write()`).

### Challenge 2: "My program segfaults"

**Common causes:**
1. **Bad pointer:** Dereferencing NULL or uninitialized pointer
2. **Stack misalignment:** Not cleaning up stack after function calls
3. **Writing to read-only memory:** Trying to modify string literals

**How to debug:**
```bash
gdb ./program
(gdb) run
# When it crashes:
(gdb) info registers    # See register values
(gdb) backtrace         # See call stack
(gdb) x/10i $eip        # See current instructions
```

### Challenge 3: "How do I test the encoder?"

**Step by step:**
```bash
# 1. Build
make task1

# 2. Test with simple input
echo "ABC" | ./task1
# Should output: DEF

# 3. Test with file
echo "HELLO WORLD" > test.txt
./task1 -itest.txt
# Should output: KHOOR ZRUOG

# 4. Test output file
./task1 -itest.txt -oencoded.txt
cat encoded.txt
```

### Challenge 4: "The virus code is too long"

**Solution:** Keep it simple!
- `infection()` should be ONE system call (write)
- `infector()` should be THREE system calls (open, write, close)
- Total: less than 30 lines of assembly

## Memory Layout in x86

```
High addresses
+------------------+
|   Command line   |  <- argv[], envp[]
|   and environ    |
+------------------+
|      Stack       |  <- grows downward
|        ↓         |
|                  |
|                  |
|        ↑         |
|      Heap        |  <- grows upward
+------------------+
|       BSS        |  <- uninitialized data
+------------------+
|      Data        |  <- initialized data
+------------------+
|      Text        |  <- program code
+------------------+
Low addresses
```

## CDECL Calling Convention

When calling a C function from assembly (or vice versa):

```asm
; Before call:
push arg3       ; Arguments pushed right to left
push arg2
push arg1
call function
add esp, 12     ; Caller cleans up (3 args × 4 bytes)

; Inside function:
push ebp        ; Save old base pointer
mov ebp, esp    ; Set up new base pointer
; Now:
; [ebp+8]  = arg1
; [ebp+12] = arg2
; [ebp+16] = arg3
; [ebp-4]  = local variable 1
; [ebp-8]  = local variable 2
; etc.
pop ebp         ; Restore base pointer
ret             ; Return (caller cleans stack)
```

## The `start.s` File Explained

```asm
_start:
    pop ecx              ; ecx = argc
    mov esi, esp         ; esi = argv (pointer to array)
    
    ; Calculate envp = argv + argc + 1
    mov eax, ecx         ; eax = argc
    shl eax, 2           ; eax = argc * 4 (each pointer is 4 bytes)
    add eax, esi         ; eax = &argv[argc]
    add eax, 4           ; eax = &argv[argc+1] = envp
    
    ; Set up arguments for main()
    push eax             ; envp
    push esi             ; argv
    push ecx             ; argc
    
    call main            ; Call main()
    
    ; Exit with return value from main
    mov ebx, eax         ; exit code = return value
    mov eax, 1           ; sys_exit
    int 0x80
```

This is what normally happens "behind the scenes" when a C program starts!

## File Permissions

When opening files:

```c
// Read only
fd = system_call(SYS_OPEN, filename, O_RDONLY, 0);

// Write (create if needed, truncate if exists)
fd = system_call(SYS_OPEN, filename, O_WRONLY|O_CREAT|O_TRUNC, 0644);

// Append
fd = system_call(SYS_OPEN, filename, O_WRONLY|O_APPEND, 0);
```

Permissions (octal):
- 0644 = rw-r--r-- (owner can read/write, others can read)
- 0755 = rwxr-xr-x (owner can do everything, others can read/execute)

## Testing Strategy

1. **Test in isolation:** Test each task separately
2. **Test with simple inputs:** Start with "ABC", not complex strings
3. **Use echo and pipes:** `echo "test" | ./program`
4. **Check return codes:** `echo $?` after running
5. **Use strace:** `strace ./program` to see all system calls
6. **Use gdb:** Debug when things go wrong

## Common Mistakes

1. **Forgetting to clean stack after calling C functions**
   ```asm
   push arg
   call strlen
   ; DON'T FORGET THIS:
   add esp, 4
   ```

2. **Using wrong comparison for signed/unsigned**
   - `jl`/`jg` for signed
   - `jb`/`ja` for unsigned

3. **Forgetting to close files**
   ```asm
   mov eax, SYS_CLOSE
   mov ebx, fd
   int 0x80
   ```

4. **Not checking for errors**
   ```asm
   int 0x80
   cmp eax, 0
   jl .error    ; Negative return = error
   ```

## Further Reading

- Intel x86 Manual: Complete instruction reference
- Linux System Call Table: List of all system calls
- "Programming from the Ground Up" by Jonathan Bartlett: Great assembly intro
- man pages: `man 2 write`, `man 2 open`, etc.

## What You've Learned

After completing this lab, you understand:
1. How programs interact with the operating system
2. What the C standard library does for you
3. How calling conventions work
4. How to read/write files at the system call level
5. How directory listings work
6. How viruses can attach to files (and why antivirus software is important!)

This knowledge is fundamental for:
- Operating system development
- Security research
- Embedded systems programming
- Understanding how programs really work
