section .data
    msg db "hello world", 10   ; 10 is newline character
    msglen equ $ - msg

section .text
global _start

_start:
    ; write(1, msg, msglen)
    mov eax, 4          ; sys_write system call
    mov ebx, 1          ; stdout file descriptor
    mov ecx, msg        ; pointer to message
    mov edx, msglen     ; message length
    int 0x80            ; make system call

    ; exit(0)
    mov eax, 1          ; sys_exit system call
    mov ebx, 0          ; exit code 0
    int 0x80            ; make system call
