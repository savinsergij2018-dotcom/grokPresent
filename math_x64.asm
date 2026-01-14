section .text
global add_numbers
global multiply_fast

add_numbers:
    mov rax, rdi
    add rax, rsi
    ret

multiply_fast:
    mov rax, rdi
    shl rax, 3
    ret

square_root_approx:
    pxor xmm0, xmm0
    sqrtss xmm0, xmm1
    ret
