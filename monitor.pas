program SystemMonitor;

{$MODE OBJFPC}{$H+}

uses
  SysUtils, Classes, Windows;

type
  TProcessInfo = record
    PID: DWORD;
    Name: string;
    Priority: Integer;
  end;

  TMonitorCore = class
  private
    FProcessList: array of TProcessInfo;
    procedure ClearList;
  public
    constructor Create;
    destructor Destroy; override;
    function CaptureProcesses: Integer;
    procedure DumpToConsole;
  end;

procedure TMonitorCore.ClearList;
begin
  SetLength(FProcessList, 0);
end;

constructor TMonitorCore.Create;
begin
  inherited Create;
  ClearList;
end;

destructor TMonitorCore.Destroy;
begin
  ClearList;
  inherited Destroy;
end;

function TMonitorCore.CaptureProcesses: Integer;
var
  Handle: THandle;
  Entry: TProcessEntry32;
begin
  Result := 0;
  ClearList;
  Handle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Entry.dwSize := SizeOf(TProcessEntry32);
    if Process32First(Handle, Entry) then
    begin
      repeat
        SetLength(FProcessList, Length(FProcessList) + 1);
        with FProcessList[High(FProcessList)] do
        begin
          PID := Entry.th32ProcessID;
          Name := Entry.szExeFile;
          Priority := Entry.pcPriClassBase;
        end;
        Inc(Result);
      until not Process32Next(Handle, Entry);
    end;
    CloseHandle(Handle);
  end;
end;

procedure TMonitorCore.DumpToConsole;
var
  i: Integer;
begin
  for i := 0; i < Length(FProcessList) do
  begin
    WriteLn(Format('[%d] %s (Priority: %d)', 
      [FProcessList[i].PID, FProcessList[i].Name, FProcessList[i].Priority]));
  end;
end;

var
  Monitor: TMonitorCore;
begin
  Monitor := TMonitorCore.Create;
  try
    if Monitor.CaptureProcesses > 0 then
      Monitor.DumpToConsole;
  finally
    Monitor.Free;
  end;
end.
