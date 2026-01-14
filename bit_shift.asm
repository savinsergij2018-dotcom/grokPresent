section .text
global bit_reverse

bit_reverse:
    mov rax, rdi
    mov rcx, 64
.loop:
    shl rax, 1
    rcr rdx, 1
    loop .loop
    mov rax, rdx
    ret

rotate_left:
    mov rax, rdi
    rol rax, cl
    ret
