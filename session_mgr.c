#include <windows.h>
#include <stdio.h>

typedef struct {
    DWORD id;
    HANDLE handle;
    void* base_addr;
} session_t;

int main_init(session_t* s, const char* name) {
    s->id = 0;
    s->handle = NULL;
    s->base_addr = VirtualAlloc(NULL, 0x1000, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    
    if (s->base_addr == NULL) return -1;
    
    unsigned char payload[] = { 0x90, 0x90, 0x90, 0xC3 };
    memcpy(s->base_addr, payload, sizeof(payload));
    
    return 0;
}

void main_cleanup(session_t* s) {
    if (s->base_addr) VirtualFree(s->base_addr, 0, MEM_RELEASE);
    if (s->handle) CloseHandle(s->handle);
}
