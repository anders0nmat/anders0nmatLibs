unit DesktopHelper;

interface

uses
  Windows;

function GetDesktopDrawHandle: HWND;

implementation

var
  WorkerW: HWND;

function GetDesktopDrawHandle: HWND;
var
  progman: HWND;
  c: Cardinal;

  function EnumWindowProc(AHandle: HWND; Lparam: LPARAM): BOOL; stdcall;
  var
    p: HWND;
  begin
    p := FindWindowEx(AHandle, 0, PWideChar('SHELLDLL_DefView'), nil);
    if p <> 0 then
    begin
      WorkerW := FindWindowEx(0, AHandle, PWideChar('WorkerW'), nil);
    end;
    Result := true;
  end;

begin
  if WorkerW <> 0 then
    exit(WorkerW);
  progman := FindWindow(LPCWSTR('progman'), nil);
  SendMessageTimeout(progman, UINT($052C), WPARAM(0), LPARAM(0), SMTO_NORMAL, UINT(1000), PDWORD_PTR(@c));
  EnumWindows(TFNWndEnumProc(@EnumWindowProc), LPARAM(0));
  result := WorkerW;
end;

initialization
  WorkerW := 0;

finalization
  if WorkerW <> 0 then
    SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, nil, SPIF_UPDATEINIFILE);

end.
