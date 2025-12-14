section .text
global _start
extern strlen

_start:
    pop    dword ecx    ; ecx = argc
    mov    esi,esp      ; esi = argv
    mov     eax,ecx     ; put the number of arguments into eax
    shl     eax,2       ; compute the size of argv in bytes
    add     eax,esi     ; add the size to the address of argv 
    add     eax,4       ; skip NULL at the end of argv
    push    dword eax   ; char *envp[]
    push    dword esi   ; char* argv[]
    push    dword ecx   ; int argc

    call    main        ; int main( int argc, char *argv[], char *envp[] )

    mov     ebx,eax
    mov     eax,1
    int     0x80
    nop

; ===== TASK 1: ENCODER =====

section .data
    newline db 10

section .bss
    buffer resb 1

section .rodata
    error_input db "Error: cannot open input file", 10
    error_input_len equ $ - error_input
    error_output db "Error: cannot open output file", 10
    error_output_len equ $ - error_output

section .data
    Infile dd 0
    Outfile dd 1

section .text

; System call numbers
%define SYS_EXIT 1
%define SYS_READ 3
%define SYS_WRITE 4
%define SYS_OPEN 5
%define SYS_CLOSE 6

; File descriptor constants
%define STDIN 0
%define STDOUT 1
%define STDERR 2

; Open flags
%define O_RDONLY 0
%define O_WRONLY 1
%define O_RDWR 2
%define O_CREAT 64
%define O_TRUNC 512

main:
    push ebp
    mov ebp, esp
    sub esp, 4
    
    mov eax, [ebp+8]
    mov [ebp-4], eax
    mov esi, [ebp+12]
    
    xor edi, edi
    
.print_args_loop:
    mov eax, [ebp-4]
    cmp edi, eax
    jge .parse_args
    
    mov eax, [esi + edi*4]
    
    push eax
    call strlen
    add esp, 4
    
    mov edx, eax
    mov ecx, [esi + edi*4]
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80
    
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    inc edi
    jmp .print_args_loop

.parse_args:
    mov edi, 1
    
.arg_loop:
    mov eax, [ebp-4]
    cmp edi, eax
    jge .encode
    
    mov eax, [esi + edi*4]
    
    cmp word [eax], 0x692D
    je .handle_input
    
    cmp word [eax], 0x6F2D
    je .handle_output
    
    inc edi
    jmp .arg_loop

.handle_input:
    mov eax, [esi + edi*4]
    add eax, 2
    
    mov ebx, eax
    mov ecx, O_RDONLY
    mov edx, 0
    mov eax, SYS_OPEN
    int 0x80
    
    cmp eax, 0
    jl .input_error
    
    mov [Infile], eax
    inc edi
    jmp .arg_loop

.handle_output:
    mov eax, [esi + edi*4]
    add eax, 2
    
    mov ebx, eax
    mov ecx, O_WRONLY
    or ecx, O_CREAT
    or ecx, O_TRUNC
    mov edx, 0644o
    mov eax, SYS_OPEN
    int 0x80
    
    cmp eax, 0
    jl .output_error
    
    mov [Outfile], eax
    inc edi
    jmp .arg_loop

.encode:
.encode_loop:
    mov eax, SYS_READ
    mov ebx, [Infile]
    mov ecx, buffer
    mov edx, 1
    int 0x80
    
    cmp eax, 0
    jle .done
    
    mov al, [buffer]
    
    cmp al, 'A'
    jl .no_encode
    cmp al, 'Z'
    jg .no_encode
    
    add al, 3
    
    cmp al, 'Z'
    jle .no_wrap
    sub al, 26
    
.no_wrap:
    mov [buffer], al

.no_encode:
    mov eax, SYS_WRITE
    mov ebx, [Outfile]
    mov ecx, buffer
    mov edx, 1
    int 0x80
    
    jmp .encode_loop

.input_error:
    mov eax, SYS_WRITE
    mov ebx, STDERR
    mov ecx, error_input
    mov edx, error_input_len
    int 0x80
    jmp .error_exit

.output_error:
    mov eax, SYS_WRITE
    mov ebx, STDERR
    mov ecx, error_output
    mov edx, error_output_len
    int 0x80
    jmp .error_exit

.error_exit:
    mov eax, SYS_EXIT
    mov ebx, 0x55
    int 0x80

.done:
    mov eax, [Infile]
    cmp eax, STDIN
    je .skip_close_in
    
    mov ebx, eax
    mov eax, SYS_CLOSE
    int 0x80

.skip_close_in:
    mov eax, [Outfile]
    cmp eax, STDOUT
    je .skip_close_out
    
    mov ebx, eax
    mov eax, SYS_CLOSE
    int 0x80

.skip_close_out:
    mov eax, SYS_EXIT
    xor ebx, ebx
    int 0x80
    
    add esp, 4
    pop ebp
    xor eax, eax
    ret
