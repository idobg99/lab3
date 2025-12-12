section .data
    newline db 10                ; newline character
    
section .bss
    buffer resb 1                ; buffer for reading one character
    
section .rodata
    ; Error messages
    error_input db "Error: cannot open input file", 10
    error_input_len equ $ - error_input
    error_output db "Error: cannot open output file", 10
    error_output_len equ $ - error_output

section .data
    Infile dd 0                  ; file descriptor for input (0 = stdin)
    Outfile dd 1                 ; file descriptor for output (1 = stdout)

section .text
global main
extern strlen

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
    
    ; Save arguments
    mov ecx, [ebp+8]             ; argc
    mov esi, [ebp+12]            ; argv
    
    ; Task 1.A: Print all arguments to stdout
    xor edi, edi                 ; i = 0
    
.print_args_loop:
    cmp edi, ecx                 ; if (i >= argc)
    jge .parse_args              ; done printing
    
    ; Get argv[i]
    mov eax, [esi + edi*4]
    
    ; Push argument for strlen
    push eax
    call strlen
    add esp, 4
    
    ; Write argv[i]
    mov edx, eax                 ; length
    mov ecx, [esi + edi*4]       ; string pointer
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80
    
    ; Write newline
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    inc edi
    jmp .print_args_loop

.parse_args:
    ; Parse command line arguments for -i and -o
    mov edi, 1                   ; start from argv[1] (skip program name)
    mov ecx, [ebp+8]             ; argc
    
.arg_loop:
    cmp edi, ecx
    jge .encode                  ; done parsing arguments
    
    mov eax, [esi + edi*4]       ; get argv[i]
    
    ; Check for -i
    cmp word [eax], 0x692D       ; "-i" in little endian
    je .handle_input
    
    ; Check for -o
    cmp word [eax], 0x6F2D       ; "-o" in little endian
    je .handle_output
    
    inc edi
    jmp .arg_loop

.handle_input:
    mov eax, [esi + edi*4]       ; get argv[i]
    add eax, 2                   ; skip "-i" to get filename
    
    ; open(filename, O_RDONLY)
    mov ebx, eax                 ; filename
    mov ecx, O_RDONLY
    mov edx, 0
    mov eax, SYS_OPEN
    int 0x80
    
    ; Check for error
    cmp eax, 0
    jl .input_error
    
    mov [Infile], eax            ; save file descriptor
    inc edi
    jmp .arg_loop

.handle_output:
    mov eax, [esi + edi*4]       ; get argv[i]
    add eax, 2                   ; skip "-o" to get filename
    
    ; open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0644)
    mov ebx, eax                 ; filename
    mov ecx, O_WRONLY
    or ecx, O_CREAT
    or ecx, O_TRUNC
    mov edx, 0644o               ; permissions
    mov eax, SYS_OPEN
    int 0x80
    
    ; Check for error
    cmp eax, 0
    jl .output_error
    
    mov [Outfile], eax           ; save file descriptor
    inc edi
    jmp .arg_loop

.encode:
    ; Main encoding loop
.encode_loop:
    ; read(Infile, buffer, 1)
    mov eax, SYS_READ
    mov ebx, [Infile]
    mov ecx, buffer
    mov edx, 1
    int 0x80
    
    ; Check if we read anything
    cmp eax, 0
    jle .done                    ; EOF or error
    
    ; Encode the character
    mov al, [buffer]
    
    ; Check if it's in range 'A' to 'Z' (65 to 90)
    cmp al, 'A'
    jl .no_encode
    cmp al, 'Z'
    jg .no_encode
    
    ; Add 3 to the character
    add al, 3
    
    ; Handle wrap-around (if character > 'Z' after adding 3)
    cmp al, 'Z'
    jle .no_wrap
    ; Wrap around: subtract 26 to go back to beginning of alphabet
    sub al, 26
    
.no_wrap:
    mov [buffer], al

.no_encode:
    ; write(Outfile, buffer, 1)
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
    ; Close files if they're not stdin/stdout
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
    ; Exit normally
    mov eax, SYS_EXIT
    xor ebx, ebx                 ; exit code 0
    int 0x80
    
    ; Return 0 (shouldn't reach here)
    pop ebp
    xor eax, eax
    ret
