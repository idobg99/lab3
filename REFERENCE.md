# Lab 3 Quick Reference Guide

## System Call Numbers (Linux x86)
```
sys_exit      = 1
sys_read      = 3
sys_write     = 4
sys_open      = 5
sys_close     = 6
sys_getdents  = 141
```

## File Descriptors
```
STDIN  = 0
STDOUT = 1
STDERR = 2
```

## Open Flags
```
O_RDONLY  = 0
O_WRONLY  = 1
O_RDWR    = 2
O_CREAT   = 64   (0100 octal)
O_TRUNC   = 512  (01000 octal)
O_APPEND  = 1024 (02000 octal)
```

## File Permissions (Octal)
```
0644 = rw-r--r-- (owner: read/write, others: read)
0755 = rwxr-xr-x (owner: rwx, others: rx)
```

## Assembly Language Quick Reference

### System Call in Assembly
```asm
mov eax, syscall_number    ; System call number
mov ebx, arg1              ; First argument
mov ecx, arg2              ; Second argument
mov edx, arg3              ; Third argument
int 0x80                   ; Make system call
; Return value in eax
```

### CDECL Function Call
```asm
; Calling a function:
push arg3                  ; Push arguments right to left
push arg2
push arg1
call function
add esp, 12                ; Clean up stack (3 args * 4 bytes)

; In the function:
push ebp
mov ebp, esp
; Access arguments as [ebp+8], [ebp+12], [ebp+16], etc.
; Function body...
pop ebp
ret
```

### String Operations
```asm
; Load string address
mov esi, string_address

; Compare byte
cmp byte [esi], 'A'

; Load word (2 bytes)
mov ax, word [esi]         ; Loads 2 bytes
cmp ax, 0x692D             ; Compare with "-i"
```

## Common Assembly Instructions

### Data Movement
```asm
mov dest, src              ; Move data
lea dest, [address]        ; Load effective address
```

### Arithmetic
```asm
add dest, src              ; Addition
sub dest, src              ; Subtraction
inc dest                   ; Increment
dec dest                   ; Decrement
```

### Comparison and Jumps
```asm
cmp op1, op2               ; Compare (sets flags)
jmp label                  ; Unconditional jump
je label                   ; Jump if equal (ZF=1)
jne label                  ; Jump if not equal (ZF=0)
jl label                   ; Jump if less (SF≠OF)
jle label                  ; Jump if less or equal
jg label                   ; Jump if greater
jge label                  ; Jump if greater or equal
```

### Bitwise Operations
```asm
and dest, src              ; Bitwise AND
or dest, src               ; Bitwise OR
xor dest, src              ; Bitwise XOR
shl dest, count            ; Shift left
shr dest, count            ; Shift right
```

## Encoder Algorithm
```
For each character:
  If character is in range 'A' to 'Z' (65-90):
    Add 3 to character
    If result > 'Z':
      Subtract 26 (wrap around)
  Output character
```

## Directory Entry Structure
```c
struct linux_dirent {
    unsigned long  d_ino;      /* Inode number */
    unsigned long  d_off;      /* Offset to next dirent */
    unsigned short d_reclen;   /* Length of this dirent */
    char           d_name[];   /* Filename (null-terminated) */
};
```

## Virus Code Structure
```asm
code_start:
    ; infection() function
    ; infector() function
code_end:

; To get virus code size:
mov edx, code_end
sub edx, code_start    ; edx = size of virus code
```

## Common Errors and Solutions

### Error: "cannot open file"
- Check file exists and has correct permissions
- Use absolute path or ensure file is in current directory

### Error: Exit code 0x55 (85)
- Program encountered an error (file open failed, etc.)
- Check file permissions and paths

### Segmentation Fault
- Check stack alignment
- Verify pointer validity before dereferencing
- Ensure proper function prologue/epilogue

## Debugging Tips

### Using GDB with Assembly
```bash
gdb ./task1
(gdb) break main
(gdb) run
(gdb) stepi              # Step one instruction
(gdb) info registers     # Show all registers
(gdb) x/10i $eip         # Examine next 10 instructions
(gdb) x/s $ecx           # Examine string at address in ecx
```

### Examining System Call Results
```bash
strace ./task1           # Trace all system calls
```

## Command Examples

### Compilation Commands
```bash
# Assemble
nasm -f elf32 file.s -o file.o

# Compile C
gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector file.c -o file.o

# Link
ld -m elf_i386 start.o main.o util.o -o program
```

### Testing Encoder
```bash
# Test with echo
echo "ABC" | ./task1

# Test with file
echo "HELLO" > input.txt
./task1 -iinput.txt -ooutput.txt
cat output.txt

# Test interactive
./task1
ABC
[Ctrl+D to end input]
```

### Testing Virus
```bash
# Create test file
echo "#!/bin/bash" > test_script.sh
echo "echo Original script" >> test_script.sh
chmod +x test_script.sh

# Attach virus
./task2 -atest_

# Test infected file
./test_script.sh
# Should print "Hello, Infected File" then "Original script"
```

## Little Endian Note
On x86, multi-byte values are stored little-endian:
```asm
; To check for "-i" (0x2D 0x69):
cmp word [eax], 0x692D    ; Compare with 'i' '-' (reversed)
```
