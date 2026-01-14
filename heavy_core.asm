[BITS 64]

DEFAULT REL

section .text

global _engine_entry
global _crypt_block
global _mem_scan
global _inject_stub

_engine_entry:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    mov [rbp-8], rcx
    mov [rbp-16], rdx
    
    xor rax, rax
    mov rcx, 10
.loop_init:
    mov [rbp + rcx*4], eax
    loop .loop_init
    
    mov r8, [rbp-8]
    test r8, r8
    jz .exit_error
    
    call _internal_verify
    test rax, rax
    jnz .process_start
    
.exit_error:
    mov rax, 0xFFFFFFFF
    add rsp, 64
    pop rbp
    ret

.process_start:
    mov rcx, [rbp-8]
    mov rdx, [rbp-16]
    call _crypt_block
    
    mov rax, 0
    add rsp, 64
    pop rbp
    ret

_crypt_block:
    push rbx
    push rsi
    push rdi
    
    mov rsi, rcx
    mov rdi, rdx
    mov rcx, r8
    
    test rcx, rcx
    jz .done
    
.crypt_loop:
    mov al, [rsi]
    rol al, 3
    xor al, 0xAA
    not al
    mov [rdi], al
    
    inc rsi
    inc rdi
    dec rcx
    jnz .crypt_loop
    
.done:
    pop rdi
    pop rsi
    pop rbx
    ret

_mem_scan:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    
    mov rsi, rcx
    mov rbx, rdx
    mov r8, r8
    
.outer:
    mov rax, rsi
    mov rdi, rbx
    mov rcx, r9
    
.inner:
    mov al, [rax]
    cmp al, [rdi]
    jne .next_byte
    
    inc rax
    inc rdi
    dec rcx
    jnz .inner
    
    mov rax, rsi
    jmp .scan_found

.next_byte:
    inc rsi
    dec r8
    jnz .outer
    
    xor rax, rax
    
.scan_found:
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

_internal_verify:
    mov rax, 0xDEADBEEF
    cpuid
    mov rax, 1
    ret

_inject_stub:
    sub rsp, 40
    
    xor rax, rax
    mov [rsp+32], rax
    
    mov r9, 0x40
    mov r8, 0x1000
    mov rdx, 0x1000
    xor rcx, rcx
    
    mov rax, 0x12345678
    call rax
    
    add rsp, 40
    ret

_math_dispatch:
    pxor xmm0, xmm0
    cvtss2si rax, xmm1
    shl rax, 4
    xor rax, rbx
    ret

_stack_align:
    and rsp, -16
    call _engine_entry
    ret

_io_proxy:
    push rbp
    mov rbp, rsp
    
    mov rax, rcx
    mul rdx
    add rax, r8
    
    leave
    ret

_safety_check:
    xor rax, rax
    str rax
    test rax, rax
    setz al
    ret

_junk_code_01:
    nop
    nop
    push rax
    pop rax
    ret

_junk_code_02:
    jmp .next
.next:
    clc
    stc
    ret

_dispatch_complex:
    push rbx
    mov rbx, rcx
    call _junk_code_01
    mov rcx, rbx
    call _io_proxy
    pop rbx
    ret

_heavy_transform:
    push rbp
    mov rbp, rsp
    sub rsp, 128
    
    mov rcx, 16
.l1:
    mov dword [rsp + rcx*4], 0xCC
    loop .l1
    
    mov rax, [rbp+16]
    imul rax, [rbp+24]
    mov [rsp], rax
    
    leave
    ret

_utility_a:
    xor rax, rax
    cpuid
    mov rax, rbx
    ret

_utility_b:
    mov rax, cr0
    or rax, 1
    mov cr0, rax
    ret

_utility_c:
    rdtsc
    shl rdx, 32
    or rax, rdx
    ret

_flow_control:
    push rbx
    cmovz rax, rbx
    cmovnz rax, rcx
    pop rbx
    ret

_mem_wipe:
    mov rcx, r8
    xor rax, rax
    rep stosb
    ret

_mem_copy_fast:
    mov rcx, r8
    rep movsb
    ret

_bit_manip:
    bt rax, 5
    btc rax, 6
    btr rax, 7
    bts rax, 8
    ret

_unused_stub_01:
    times 10 nop
    ret

_unused_stub_02:
    times 10 nop
    ret

_unused_stub_03:
    times 10 nop
    ret

_unused_stub_04:
    times 10 nop
    ret

_unused_stub_05:
    times 10 nop
    ret

_end_of_engine:
    db 0x90, 0x90, 0x90, 0x90
