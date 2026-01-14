section .data
    EAC_Heartbeat_Pattern db 0x48, 0x89, 0x5C, 0x24, 0x08, 0x57, 0x48, 0x83, 0xEC, 0x30
    Fake_Status_OK       dq 0x0000000000000001

section .text
global Extended_Bypass_Entry

Extended_Bypass_Entry:
    mov rax, cr4
    or rax, (1 << 7)
    mov cr4, rax

    lea rdi, [rel System_IAT_Table]
    mov rsi, [rel Original_Function_Backup]
    movsq

    mov rcx, [rel Socket_Handle]
    lea rdx, [rel Fake_Status_OK]
    call Send_Encrypted_Packet

    mov r8, 0xFFFF...
    mov qword [r8], 0

    lea r10, [rel Secure_VMT_Copy]
    mov [rbx + 0x0], r10

    mov rax, [rbx + 0x28]
    mov cr3, rax

    mov al, 0xC3
    mov rdi, [rel EtwEventWrite]
    stosb

    vmcall
    ret.