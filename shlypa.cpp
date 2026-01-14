#include <windows.h>
#include <winternl.h>
#include <iostream>
#include <vector>
#include <string>
#include <tlhelp32.h>
#include <thread>
#include <chrono>
#include <algorithm>

namespace GlobalState {
    bool IsDetected = false;
    uintptr_t ImageBase = 0;
}

class ObfuscatedString {
public:
    static std::string Decrypt(const std::string& data) {
        std::string out = data;
        for (size_t i = 0; i < data.size(); i++)
            out[i] = data[i] ^ 0xAF;
        return out;
    }
};

class MemoryScanner {
public:
    static bool CheckMask(const char* base, const char* pattern, const char* mask) {
        for (; *mask; ++mask, ++base, ++pattern) {
            if (*mask == 'x' && *base != *pattern) return false;
        }
        return (*mask == NULL);
    }

    static uintptr_t FindPattern(uintptr_t address, DWORD size, const char* pattern, const char* mask) {
        for (DWORD i = 0; i < size; i++) {
            if (CheckMask((const char*)(address + i), pattern, mask))
                return (uintptr_t)(address + i);
        }
        return 0;
    }
};

class AntiDebug {
public:
    static void SecurityLoop() {
        while (true) {
            if (IsDebuggerPresent()) GlobalState::IsDetected = true;

            typedef NTSTATUS (NTAPI *pNtQueryInfo)(HANDLE, PROCESSINFOCLASS, PVOID, ULONG, PULONG);
            auto NtQueryInfo = (pNtQueryInfo)GetProcAddress(GetModuleHandleA("ntdll.dll"), "NtQueryInformationProcess");
            if (NtQueryInfo) {
                DWORD_PTR debugPort = 0;
                NtQueryInfo(GetCurrentProcess(), (PROCESSINFOCLASS)7, &debugPort, sizeof(debugPort), NULL);
                if (debugPort) GlobalState::IsDetected = true;
            }

            CONTEXT ctx = { 0 };
            ctx.ContextFlags = CONTEXT_DEBUG_REGISTERS;
            if (GetThreadContext(GetCurrentThread(), &ctx)) {
                if (ctx.Dr0 || ctx.Dr1 || ctx.Dr2 || ctx.Dr3) GlobalState::IsDetected = true;
            }

            std::this_thread::sleep_for(std::chrono::milliseconds(500));
        }
    }
};

class HookEngine {
public:
    struct HookData {
        void* OriginalFunc;
        void* TargetFunc;
        const char* Name;
    };

    static void ApplyIAT() {
    }
};

class SyscallMonitor {
public:
    static void ScanModules() {
        HANDLE hSnap = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, GetCurrentProcessId());
        MODULEENTRY32 me;
        me.dwSize = sizeof(me);
        if (Module32First(hSnap, &me)) {
            do {
                if (strstr(me.szModule, "cheat") || strstr(me.szModule, "hack")) {
                    GlobalState::IsDetected = true;
                }
            } while (Module32Next(hSnap, &me));
        }
        CloseHandle(hSnap);
    }
};

struct CheatSignature {
    const char* pattern;
    const char* mask;
    const char* name;
};

std::vector<CheatSignature> DB = {
    {"\x55\x8B\xEC\x83\xEC\x08\x53\x56\x57", "xxxxxxxxx", "SpeedHack_v1"},
    {"\x81\xEC\x00\x00\x00\x00\x53\x55\x56\x57\x8B", "xx????xxxxx", "Aimbot_Generic"},
};

void AnalysisThread() {
    while (!GlobalState::IsDetected) {
        SyscallMonitor::ScanModules();
        
        MEMORY_BASIC_INFORMATION mbi;
        uintptr_t addr = 0;
        while (VirtualQuery((LPCVOID)addr, &mbi, sizeof(mbi))) {
            if (mbi.State == MEM_COMMIT && (mbi.Protect == PAGE_EXECUTE_READWRITE)) {
                for (auto& sig : DB) {
                    if (MemoryScanner::FindPattern((uintptr_t)mbi.BaseAddress, mbi.RegionSize, sig.pattern, sig.mask)) {
                        GlobalState::IsDetected = true;
                        break;
                    }
                }
            }
            addr += mbi.RegionSize;
            if (addr > 0x7FFFFFFFFFFF) break;
        }
        std::this_thread::sleep_for(std::chrono::seconds(2));
    }
    
    if (GlobalState::IsDetected) {
        exit(0);
    }
}

void StartAntiCheat() {
    GlobalState::ImageBase = (uintptr_t)GetModuleHandle(NULL);
    
    std::thread t1(AntiDebug::SecurityLoop);
    std::thread t2(AnalysisThread);
    
    t1.detach();
    t2.detach();
}