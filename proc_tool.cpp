#include <windows.h>
#include <tlhelp32.h>
#include <string>

class ProcessHelper {
public:
    static DWORD find_pid(const std::wstring& process_name) {
        DWORD pid = 0;
        HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
        if (snapshot != INVALID_HANDLE_VALUE) {
            PROCESSENTRY32W entry;
            entry.dwSize = sizeof(entry);
            if (Process32FirstW(snapshot, &entry)) {
                do {
                    if (process_name == entry.szExeFile) {
                        pid = entry.th32ProcessID;
                        break;
                    }
                } while (Process32NextW(snapshot, &entry));
            }
            CloseHandle(snapshot);
        }
        return pid;
    }
};
