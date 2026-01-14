section .text
global hook_entry

hook_entry:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    lea rcx, [rip + original_func]
    jmp [rcx]

section .data
    original_func dq 0x0
