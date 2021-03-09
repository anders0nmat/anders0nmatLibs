unit TCPSocket;

interface

uses
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, ColorControl, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Menus, Generics.Collections, System.Classes, System.Types, winsock2, System.SysUtils, WinApi.Windows, WinApi.Messages;

type
  TErrorEvent = procedure(Sender: TObject; ErrorCode: Integer) of object;
  TReceiveEvent = procedure(Sender: TObject; buffer: TBytes) of object;

  TTCPSocket = class(TPersistent)
  private
    fHandle: HWND;
    fRaiseErrors: Boolean;
    fOnError: TErrorEvent;
    fOnReceive: TReceiveEvent;
    fPort: Word;
    fIPAddr: string;
    fMessages: TDictionary<TSocket, TBytes>;
    fSockAddr: TSockAddr;
    fAddrLen: Integer;
    const
      WM_SOCKET_MESSAGE = WM_APP + 7;

    procedure HandleError;
    procedure HandleMessage(var msg: TMessage);
    procedure UpdateAddr;
    procedure SetIPAddr(const Value: string);
    procedure SetPort(const Value: Word);
  public
    class constructor Create;
    class destructor Destroy;

    constructor Create(RaiseErrors: Boolean = false);
    destructor Destroy; override;

    procedure SendData(Buffer: TBytes); overload;
    procedure SendData(AStream: TStream); overload;

    property OnError: TErrorEvent read fOnError write fOnError;
    property OnReceive: TReceiveEvent read fOnReceive write fOnReceive;
    property Port: Word read fPort write SetPort;
    property IPAddresse: string read fIPAddr write SetIPAddr;
  end;

implementation

{$REGION 'TTCPSocket'}

class constructor TTCPSocket.Create;
var
  Data: WSAData;
begin
  WSAStartup(MakeWord(2, 2), Data);
end;

class destructor TTCPSocket.Destroy;
begin
  WSACleanup;
end;

constructor TTCPSocket.Create(RaiseErrors: Boolean);
begin
  fHandle := AllocateHWnd(HandleMessage);
  fMessages := TDictionary<TSocket, TBytes>.Create;
  fRaiseErrors := RaiseErrors;
end;

destructor TTCPSocket.Destroy;
var
  sock: TSocket;
begin
  for sock in fMessages.Keys do
    closesocket(sock);
  DeallocateHWnd(fHandle);
  inherited;
end;

procedure TTCPSocket.HandleError;
var
  err, Len: Integer;
  s: string;
begin
  err := WSAGetLastError;
  if err = WSAEWOULDBLOCK then
    exit;
  if Assigned(fOnError) then
    fOnError(Self, err);

  if not fRaiseErrors then
    exit;

  SetLength(s, 260);
  len := FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, err, 0, @s[1], length(s), nil);
  SetLength(s, len);
  raise Exception.Create('Socket Error: ' + s);
end;

procedure TTCPSocket.HandleMessage(var msg: TMessage);
var
  buffer: TBytes;
  len: integer;
begin
  case msg.LParamLo of
    FD_READ: begin
      if Assigned(fOnReceive) then
      begin
        SetLength(buffer, 1024);
        len := recv(msg.WParam, buffer[0], length(buffer), 0);
        if len = SOCKET_ERROR then
          HandleError
        else
        begin
          SetLength(buffer, len);
          fOnReceive(Self, buffer);
        end;
      end;
      fMessages.Remove(msg.WParam);
      closesocket(msg.WParam);
    end;
    FD_WRITE: begin
      if fMessages.ContainsKey(msg.WParam) then
      begin
        buffer := fMessages[msg.WParam];
        len := send(msg.WParam, buffer[0], length(buffer), 0);
        if len = SOCKET_ERROR then
          HandleError;
      end;
    end;
    FD_CLOSE: begin
      fMessages.Remove(msg.WParam);
      closesocket(msg.WParam);
    end;
    FD_CONNECT: begin

    end;
    else
      DefWindowProc(fHandle, msg.Msg, msg.wParam, msg.LParam);
  end;
end;

procedure TTCPSocket.SendData(buffer: TBytes);
var
  aSocket: TSocket;
begin
  aSocket := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if aSocket = INVALID_SOCKET then
    HandleError;

  if WSAAsyncSelect(aSocket, fHandle, WM_SOCKET_MESSAGE,
     FD_READ or FD_WRITE or FD_CLOSE or FD_CONNECT) = SOCKET_ERROR then
    HandleError;

  fMessages.Add(aSocket, buffer);

  if winsock2.connect(aSocket, fSockAddr, fAddrLen) = SOCKET_ERROR then
    HandleError;
end;

procedure TTCPSocket.SendData(AStream: TStream);
var
  buf: TBytes;
begin
  SetLength(buf, AStream.Size);
  AStream.Position := 0;
  AStream.ReadBuffer(buf, AStream.Size);

  SendData(buf);
end;

procedure TTCPSocket.SetIPAddr(const Value: string);
begin
  if Value <> fIPAddr then
  begin
    fIPAddr := Value;
    UpdateAddr;
  end;
end;

procedure TTCPSocket.SetPort(const Value: Word);
begin
  if Value <> fPort then
  begin
    fPort := Value;
    UpdateAddr;
  end;
end;

procedure TTCPSocket.UpdateAddr;
var
  SockAddr: TSockAddrIn;
  AddrLen: Integer;
begin
  AddrLen := SizeOf(SockAddr);
  SockAddr.sin_family := AF_INET;
  SockAddr.sin_port := htons(fPort);
  SockAddr.sin_addr.S_addr := inet_addr(PAnsiChar(AnsiString(fIPAddr)));
  fSockAddr := TSockAddr(SockAddr);
  fAddrLen := AddrLen;
end;

{$ENDREGION}

end.
