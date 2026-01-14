using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace HookCLN.Core
{
    public unsafe class MemoryEngine : IDisposable
    {
        private readonly IntPtr _processHandle;
        private readonly Process _targetProcess;

        [DllImport("kernel32.dll")]
        private static extern IntPtr OpenProcess(uint dwDesiredAccess, bool bInheritHandle, int dwProcessId);

        [DllImport("kernel32.dll")]
        private static extern bool CloseHandle(IntPtr hObject);

        [DllImport("kernel32.dll")]
        private static extern bool ReadProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, int dwSize, out int lpNumberOfBytesRead);

        public MemoryEngine(string processName)
        {
            _targetProcess = Process.GetProcessesByName(processName).FirstOrDefault() ?? throw new Exception("Process not found");
            _processHandle = OpenProcess(0x001F0FFF, false, _targetProcess.Id);
        }

        public byte[] Read(IntPtr address, int size)
        {
            var buffer = new byte[size];
            ReadProcessMemory(_processHandle, address, buffer, size, out _);
            return buffer;
        }

        public T Read<T>(IntPtr address) where T : unmanaged
        {
            var size = Marshal.SizeOf<T>();
            var buffer = Read(address, size);
            fixed (byte* p = buffer)
            {
                return Marshal.PtrToStructure<T>((IntPtr)p);
            }
        }

        public IntPtr Scan(string pattern, string mask, IntPtr start, int size)
        {
            var data = Read(start, size);
            var patternBytes = ParsePattern(pattern);
            
            for (int i = 0; i < data.Length - patternBytes.Length; i++)
            {
                bool found = true;
                for (int j = 0; j < patternBytes.Length; j++)
                {
                    if (mask[j] == 'x' && data[i + j] != patternBytes[j])
                    {
                        found = false;
                        break;
                    }
                }
                if (found) return start + i;
            }
            return IntPtr.Zero;
        }

        private byte[] ParsePattern(string pattern)
        {
            return pattern.Split(' ').Select(x => x == "?" ? (byte)0 : Convert.ToByte(x, 16)).ToArray();
        }

        public void Dispose()
        {
            if (_processHandle != IntPtr.Zero) CloseHandle(_processHandle);
        }
    }

    public static class ExtensionVault
    {
        public static string ToHexString(this byte[] data)
        {
            var sb = new StringBuilder(data.Length * 2);
            foreach (var b in data) sb.AppendFormat("{0:X2} ", b);
            return sb.ToString().Trim();
        }

        public static IEnumerable<T> QueryStructure<T>(this MemoryEngine engine, IntPtr baseAddr, int count, int stride) where T : unmanaged
        {
            for (int i = 0; i < count; i++)
            {
                yield return engine.Read<T>(baseAddr + (i * stride));
            }
        }
    }
}
