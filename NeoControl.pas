unit NeoControl;

interface

uses ColorControl, System.Classes, System.SysUtils, System.Generics.Collections,
     WinApi.Windows, TCPSocket, lz4d;

type
  TLEDLine = (llWR, llWB, llWL, llWF,             //Window Panel
              llDL, llDF, llDR, llDB,             //Door Panel
              llTW, llTC, llTP, llTS, llTB,       //Desk
              llB);                               //Bed

  TLEDLines = set of TLEDLine;

  TLEDMode = (lmColor, lmEffect, lmCustom);

  TNeoStatus = (sError, sChanges, sOff, sOK);

  TLEDs = record
    Mode: TLEDMode;
    Color: TRGBWColor;
    HasChanged: Boolean;
  end;

  TLEDLineArray = array[TLEDLine] of TLEDs;

  TErrorEvent = procedure(Sender: TObject; ErrorCode: Integer) of object;
  TReceiveEvent = procedure(Sender: TObject; buffer: TBytes) of object;

// -------------------- CLASS DEFINITION -------------------- \\

  TRGBWList = TList<TRGBWColor>;

  TOptimizedColorList = class
  private
    fList: TRGBWList;
  public
    constructor Create;
    destructor Destroy; override;

    function AddRange(AList: TRGBWList; var Start, Length, Offset: Word): Boolean;

    procedure GetSmallestStream(AStream: TStream; var IsCompressed: Boolean);

    property List: TRGBWList read fList;
  end;

/////////////////////////////////////////////////////////////////
///                   LED Update Protocol
///
///  Aufbau:
///    Header (1 Byte)
///    Command (1 Byte)
///    Message Size in Bytes (2 Bytes) Max Value: 8192
///
///  if Command = C_RGBW:
///    Nr. Modules n (1 Byte)
///
///    1st Module StartIndex (2 Bytes)
///    1st Module IndexLength (2 Bytes)
///    1st Module Type Bitmask (1 Byte)
///    1st Module Time (4 Bytes)
///    1st Module LED Data RangeStart (2 Bytes)
///    1st Module LED Data RangeLength (2 Bytes)
///    1st Module LED Data RangeOffset (2 Bytes)
///
///    2nd Module StartIndex (2 Bytes)
///    2nd Module IndexLength (2 Bytes)
///    2nd Module Type Bitmask (1 Byte)
///    2nd Module Time (4 Bytes)
///    2nd Module LED Data RangeStart (2 Bytes)
///    2nd Module LED Data RangeLength (2 Bytes)
///    2nd Module LED Data RangeOffset (2 Bytes)
///
///             [ ... ]
///
///    n-th Module StartIndex (2 Bytes)
///    n-th Module IndexLength (2 Bytes)
///    n-th Module Type Bitmask (1 Byte)
///    n-th Module Time (4 Bytes)
///    n-th Module LED Data RangeStart (2 Bytes)
///    n-th Module LED Data RangeLength (2 Bytes)
///    n-th Module LED Data RangeOffset (2 Bytes)
///
///    Check Byte (1 Byte) = $DC (Not compressed)
///                          $DD (LZ4 compressed)
///    LED Color count (2 Bytes)
///    LED Data RGBW (4 Bytes x (Message Size - 4 - 15 * Nr Modules))
///
///  Verhalten:
///    Bei Fehlern in der Nachricht wird die Bearbeitung abgebrochen.
///    Werden weniger Module als n ausgelesen, wird die Bearbeitung abgebrochen.
///    Werden weniger als x * IndexLength RGBW-Farben ausgelesen (bei 0-Bit = 1),
///    so werden (x - 1) * IndexLength RGBW-Farben genutzt.
///    Es wird der Status aller LEDs übertragen. Nicht zugewiesene LEDs werden ausgeschalten.
///    Wenn LED Data RangeLength = 0 dann wird der Bereich schwarz geschrieben.
///
///  Type Bitmask:
///    RtL Bit Order
///    0-Bit : IsCustom  1 - Up to IndexLength Entries in LED Data set Colors, more is ignored
///                      0 - First Entry in LED Data sets Color, more is ignored
///    1-Bit : IsAnimated  1 - LEDs are animated (Max 32 simultaneously are accepted)
///                        0 - LEDs are not animated
///    2-Bit : AnimationMode  1 - Rotate LEDs (0 Bit = 1 only) (Rotates through LED Data!)
///                           0 - Switch between given color sequences
///    3-Bit : ModeSpecifier  1 - (2 Bit = 1) RoL
///                           1 - (2 Bit = 0) Fade
///                           0 - (2 Bit = 1) RoR
///                           0 - (2 Bit = 0) HardSwitch
///    4-Bit
///    5-Bit
///    6-Bit
///    7-Bit
///
///    0000 = Same RGBW Values
///    0001 = Individual RGBW Values
///    0010 = Hard Switch, Same RGBW Values
///    0011 = Hard Switch, Individual RGBW Values
///    0100 = Same RGBW Values (= 0000)
///    0101 = Individual RGBW Vaules (= 0001)
///    0110 = Hard Switch, Same RGBW Values (= 0010)
///    0111 = RoR, Individual RGBW Values
///    1000 = Same RGBW Values (= 0000)
///    1001 = Individual RGBW Vaules (= 0001)
///    1010 = Fade, Same RGBW Values
///    1011 = Fade, Individual RGBW Vaules
///    1100 = Same RGBW Values (= 0000)
///    1101 = Individual RGBW Vaules (= 0001)
///    1110 = Fade, Same RGBW Values (= 1010)
///    1111 = RoL, Individual RGBW Values
///
/////////////////////////////////////////////////////////////////

  TLEDModule = class
  private
    fStartIndex: Word;
    fIndexLength: Word;

    fIsAnimated: Boolean;
    fIsCustom: Boolean;
    fIsRotate: Boolean;
    fModeSpecifier: Boolean;

    fTime: Single;

    fLEDColor: TList<TRGBWColor>;

    procedure SetIndexLength(const Value: Word);
    procedure SetStartIndex(const Value: Word);
    procedure SetTime(const Value: Single);
    procedure SetTypeBitmask(const Index: Integer; const Value: Boolean);
    function GetIndexLength: Word;
  public
    constructor Create;
    destructor Destroy; override;

    procedure GetBinaryHeader(AStream: TStream);

    property StartIndex: Word read fStartIndex write SetStartIndex;
    property IndexLength: Word read fIndexLength write SetIndexLength;
    property IsAnimated: Boolean index 0 read fIsAnimated write SetTypeBitmask;
    property IsCustom: Boolean index 1 read fIsCustom write SetTypeBitmask;
    property IsRotate: Boolean index 2 read fIsRotate write SetTypeBitmask;
    property ModeSpecifier: Boolean index 3 read fModeSpecifier write SetTypeBitmask;
    property AnimationTime: Single read fTime write SetTime;
    property LEDColors: TList<TRGBWColor> read fLEDColor;
  end;

  TLEDMessage = class
  private
    fModules: TObjectList<TLEDModule>;
  public
    constructor Create;
    destructor Destroy; override;

    class procedure MessageOnOff(AStream: TStream; State: Boolean);
    class procedure MessageStatus(AStream: TStream);
    procedure MessageColor(AStream: TStream);

    procedure AddModule(AModule: TLEDModule);
    procedure Clear;

    property List: TObjectList<TLEDModule> read fModules;
  end;

  TNeoControl = class
  private
    fTCP: TTCPSocket;
    fLEDs: TLEDLineArray;
    fStatus: set of TNeoStatus;
    FOnStatusChange: TNotifyEvent;
    fIsOn: Boolean;
    fSnapshot: array of TPair<TLEDLine, TLEDs>;

    procedure DoStatusChange;

    function GetLEDs(Index: TLEDLine): TLEDs;
    function GetStatus: TNeoStatus;
    function HasChanges: Boolean;
    procedure SetLEDs(Index: TLEDLine; const Value: TLEDs);
    procedure OnReceive(Sender: TObject; Data: TBytes);
  public
    constructor Create(IP: string; Port: Word);
    destructor Destroy; override;

    procedure SetColor(AColor: TRGBWColor; Lines: TLEDLines);
    procedure SaveSnapshot(Lines: TLEDLines);
    procedure LoadSnapshot;
    procedure LoadLEDArray(arr: TLEDLineArray);
    function GetLEDArray: TLEDLineArray;

    procedure Update;
    procedure Switch(State: Boolean);
    procedure Refresh;
    procedure ForceChange;

    property LEDs[Index: TLEDLine]: TLEDs read GetLEDs write SetLEDs;
    property Status: TNeoStatus read GetStatus;
    property OnStatusChange: TNotifyEvent read FOnStatusChange write FOnStatusChange;
    property IsOn: Boolean read fIsOn;
  end;

const
  COLARR_BEGIN = $DC;

  MSG_BEGIN = $F0;
  C_ACTIVE = $C0;
  C_OFF    = $C1;
  C_ON     = $C2;
  C_RGBW   = $C3;
  C_STATUS = $C4;
  C_EXPERIMENTAL = $CF;

  CA_OK = $A0;
  CA_STATUS = $A1;

{$REGION 'DEFINITION'}

function LEDs(AColor: TRGBWColor; AMode: TLEDMode = lmColor; AHasChanged: Boolean = true): TLEDs;
function CreateLEDLineArray(WR, WB, WL, WF,
                            DL, DF, DR, DB,
                            TW, TC, TP, TS, TB,
                            B: TRGBWColor): TLEDLineArray;

{$ENDREGION}

implementation

{$REGION 'DECLARATION'}
function CreateLEDLineArray(WR, WB, WL, WF,
                            DL, DF, DR, DB,
                            TW, TC, TP, TS, TB,
                            B: TRGBWColor): TLEDLineArray;
begin
  Result[llWR] := LEDs(WR);
  Result[llWB] := LEDs(WB);
  Result[llWL] := LEDs(WL);
  Result[llWF] := LEDs(WF);

  Result[llDL] := LEDs(DL);
  Result[llDF] := LEDs(DF);
  Result[llDR] := LEDs(DR);
  Result[llDB] := LEDs(DB);

  Result[llTW] := LEDs(TW);
  Result[llTC] := LEDs(TC);
  Result[llTP] := LEDs(TP);
  Result[llTS] := LEDs(TS);
  Result[llTB] := LEDs(TB);

  Result[llB] := LEDs(B);
end;

function LEDs(AColor: TRGBWColor; AMode: TLEDMode = lmColor; AHasChanged: Boolean = true): TLEDs;
begin
  Result.Mode := AMode;
  Result.HasChanged := AHasChanged;
  Result.Color := AColor;
end;

{$ENDREGION}

{$REGION 'TNeoControl'}

constructor TNeoControl.Create(IP: string; Port: Word);
var
  i: TLEDLine;
begin
  fTCP := TTCPSocket.Create;
  fTCP.IPAddresse := IP;
  fTCP.Port := Port;
  fTCP.OnReceive := OnReceive;
  for i := low(TLEDLine) to high(TLEDLine) do
  begin
    fLEDs[i].Mode := lmColor;
    fLEDs[i].Color := RGBWColor(0, 0, 0, 0);
    fLEDs[i].HasChanged := false;
  end;
  fStatus := [sOK];
  fIsOn := true;
end;

destructor TNeoControl.Destroy;
begin
  fTCP.Free;
  inherited;
end;

procedure TNeoControl.DoStatusChange;
begin
  if Assigned(FOnStatusChange) then
    FOnStatusChange(Self);
end;

procedure TNeoControl.ForceChange;
var
  i: TLEDLine;
begin
  for i := Low(TLEDLine) to High(TLEDLine) do
    fLEDs[i].HasChanged := true;
  fStatus := fStatus + [sChanges];
end;

function TNeoControl.GetLEDArray: TLEDLineArray;
begin
  Result := fLEDs;
end;

function TNeoControl.GetLEDs(Index: TLEDLine): TLEDs;
begin
  Result := fLEDs[Index];
end;

function TNeoControl.GetStatus: TNeoStatus;
begin
  for Result := low(Result) to High(Result) do
    if Result in fStatus then
      exit;
  Result := sOK;
end;

function TNeoControl.HasChanges: Boolean;
var
  i: TLEDLine;
begin
  for i := Low(TLEDLine) to High(TLEDLine) do
    if fLEDs[i].HasChanged then
      exit(true);
  Result := false;
end;

procedure TNeoControl.LoadLEDArray(arr: TLEDLineArray);
var
  i: TLEDLine;
begin
  for i := Low(TLEDLine) to High(TLEDLine) do
  begin
    fLEDs[i] := arr[i];
    fLEDs[i].HasChanged := true;
  end;

  fStatus := fStatus + [sChanges];
  DoStatusChange;
end;

procedure TNeoControl.LoadSnapshot;
var
  pair: TPair<TLEDLine, TLEDs>;
begin
  for pair in fSnapshot do
  begin
    fLEDs[pair.Key] := pair.Value;
    fLEDs[pair.Key].HasChanged := true;
  end;
  SetLength(fSnapshot, 0);

  fStatus := fStatus + [sChanges];
  DoStatusChange;
end;

procedure TNeoControl.OnReceive(Sender: TObject; Data: TBytes);

  function MaskToSet(Mask: Word): TLEDLines;
  var
    i: TLEDLine;
  begin
    Result := [];
    for i := Low(TLEDLine) to High(TLEDLine) do
    begin
      if Mask and (1 shl Ord(i)) > 0 then
        Result := Result + [i];
    end;
  end;

var
  Lines: TLEDLines;
  i: Integer;
  line: TLEDLine;
begin
  if (Length(Data) < 2) or (Data[0] <> MSG_BEGIN) then
    exit;

  if Data[1] = CA_STATUS then
  begin
    fIsOn := Boolean(Data[2]);
    i := 3;

    repeat
      if i + 5 > High(Data) then
        break;
      Lines := MaskToSet(Data[i] shl 8 or Data[i + 1]);
      for line in Lines do
      begin
        fLEDs[line].Color := RGBWColor(Data[i + 2], Data[i + 3], Data[i + 4], Data[i + 5]);
        fLEDS[line].HasChanged := false;
      end;
      Inc(i, 6);
    until (i > High(Data));

    if fIsOn then
      fStatus := fStatus - [sOff]
    else
      fStatus := fStatus + [sOff];

    fStatus := fStatus - [sChanges];
    DoStatusChange;
  end;
end;

procedure TNeoControl.Refresh;
begin
  fTCP.SendData([MSG_BEGIN, C_STATUS]);
end;

procedure TNeoControl.SaveSnapshot(Lines: TLEDLines);
var
  Line: TLEDLine;
begin
  SetLength(fSnapshot, 0);
  for Line in Lines do
  begin
    SetLength(fSnapshot, Length(fSnapshot) + 1);
    fSnapshot[High(fSnapshot)] := TPair<TLEDLine, TLEDs>.Create(Line, fLEDs[Line]);
  end;
end;

procedure TNeoControl.SetColor(AColor: TRGBWColor; Lines: TLEDLines);
var
  Line: TLEDLine;
begin
  for Line in Lines do
  begin
    fLEDs[Line].Color := AColor;
    fLEDs[Line].HasChanged := true;
  end;

  if HasChanges then
    fStatus := fStatus + [sChanges]
  else
    fStatus := fStatus - [sChanges];
  DoStatusChange;
end;

procedure TNeoControl.SetLEDs(Index: TLEDLine; const Value: TLEDs);
begin
  fLEDs[Index] := Value;
end;

procedure TNeoControl.Switch(State: Boolean);
begin
  fTCP.SendData([MSG_BEGIN, C_OFF + Ord(State)]);
end;

procedure TNeoControl.Update;
var
  colMask: TDictionary<TRGBWColor, Word>;
  i: TLEDLine;
  Item: TPair<TRGBWColor, Word>;
  b: TBytes;
begin
  if (not (sChanges in fStatus)) then
    exit;

  SetLength(b, 2);
  b[0] := MSG_BEGIN;
  b[1] := C_RGBW;
  colMask := TDictionary<TRGBWColor, Word>.Create;
  try
    for i := Low(TLEDLine) to High(TLEDLine) do
    begin
    {$MESSAGE HINT 'No other color modes implemented'}
      if (not fLEDs[i].HasChanged) or (fLEDs[i].Mode <> lmColor) then
        continue;

      if colMask.ContainsKey(fLEDs[i].Color) then
        colMask.Items[fLEDs[i].Color] := colMask.Items[fLEDs[i].Color] or (1 shl ord(i))
      else
        colMask.Add(fLEDs[i].Color, Word(1 shl Ord(i)));
    end;

    for Item in colMask do
    begin
      SetLength(b, Length(b) + 6);
      b[High(b) - 5] := Hi(Item.Value);
      b[High(b) - 4] := Lo(Item.Value);
      b[High(b) - 3] := Item.Key.R;
      b[High(b) - 2] := Item.Key.G;
      b[High(b) - 1] := Item.Key.B;
      b[High(b)    ] := Item.Key.W;
    end;
  finally
    colMask.Free;
  end;

  fTCP.SendData(b);
end;

{$ENDREGION}

{$REGION 'TTCPSocket'}
 {
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
  fMessages.Free;
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

procedure TTCPSocket.SendData(ABuffer: TBytes);
var
  aSocket: TSocket;
begin
  aSocket := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if aSocket = INVALID_SOCKET then
    HandleError;

  if WSAAsyncSelect(aSocket, fHandle, WM_SOCKET_MESSAGE,
     FD_READ or FD_WRITE or FD_CLOSE or FD_CONNECT) = SOCKET_ERROR then
    HandleError;

  fMessages.Add(aSocket, ABuffer);

  if winsock2.connect(aSocket, fSockAddr, fAddrLen) = SOCKET_ERROR then
    HandleError;
end;

procedure TTCPSocket.SendData(AStream: TStream);
var
  buf: TBytes;
begin
  if not Assigned(AStream) then
    raise Exception.Create('Stream not assigned');

  AStream.Position := 0;
  SetLength(buf, AStream.Size);
  AStream.Read(buf[0], AStream.Size);
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
   }
{$ENDREGION}

{$REGION 'TLEDModule'}

constructor TLEDModule.Create;
begin
  fLEDColor := TList<TRGBWColor>.Create;

  fStartIndex := 0;
  IndexLength := 0;
  fIsAnimated := false;
  fIsCustom := false;
  fIsRotate := false;
  fModeSpecifier := false;
  fTime := 0.0;
end;

destructor TLEDModule.Destroy;
begin
  fLEDColor.Free;
  inherited;
end;

procedure TLEDModule.GetBinaryHeader(AStream: TStream);
var
  len: Word;
  wr: TBinaryWriter;
  Mask: Byte;
  e: TRGBWColor;
begin
  wr := TBinaryWriter.Create(AStream);
  try
    wr.Write(fStartIndex); // Start Index
    wr.Write(fIndexLength); // Index Length

    // Type Bitmask
    Mask := (fIsCustom.ToInteger) or (fIsAnimated.ToInteger shl 1) or
      (fIsRotate.ToInteger shl 2) or (fModeSpecifier.ToInteger shl 3);
    wr.Write(Mask);

    wr.Write(fTime); // Animation Time
  finally
    wr.Free;
  end;
end;

function TLEDModule.GetIndexLength: Word;
begin
  Result := fLEDColor.Count;
end;

procedure TLEDModule.SetIndexLength(const Value: Word);
begin
  if Value <> fIndexLength then
    fIndexLength := Value;
end;

procedure TLEDModule.SetStartIndex(const Value: Word);
begin
  if Value <> fStartIndex then
  begin
    fStartIndex := Value;
  end;
end;

procedure TLEDModule.SetTime(const Value: Single);
begin
  if Value <> fTime then
    fTime := Value;
end;

procedure TLEDModule.SetTypeBitmask(const Index: Integer; const Value: Boolean);
begin
  case Index of
  0: if Value <> fIsAnimated then
       fIsAnimated := Value;
  1: if Value <> fIsCustom then
       fIsCustom := Value;
  2: if Value <> fIsRotate then
       fIsRotate := Value;
  3: if Value <> fModeSpecifier then
       fModeSpecifier := Value;
  else exit;
  end;
end;

{$ENDREGION}

{$REGION 'TOptimizedColorList'}

function TOptimizedColorList.AddRange(AList: TRGBWList; var Start, Length,
  Offset: Word): Boolean;

  function FindLastColor(AItem: TRGBWColor): Integer;
  var
    i: Integer;
  begin
    Result := -1;
    for i := fList.Count - 1 downto 0 do
      if fList[i] = AItem then
        exit(i);
  end;

type
  TWordPair = TPair<Word, Word>;

var
  last: Integer;
  highestEff: TWordPair;
  off, i: Integer;
begin
  Result := false;
  if AList.Count < 1 then
    exit;

  highestEff := TWordPair.Create(0, 0); // Worst Case, append AList

  for off := 0 to AList.Count - 1 do
  begin
    last := FindLastColor(AList[off]);
    if last = -1 then
      continue;
    i := 1;
    while i + last < fList.Count do
    begin
      if fList[last + i] <> AList[(off + i) mod AList.Count] then
      begin
        i := 0;
        break;
      end;
      Inc(i);
    end;
    if i > highestEff.Key then
      highestEff := TWordPair.Create(i, off);
  end;

  length := AList.Count;
  start := fList.Count - highestEff.Key;
  offset := (AList.Count - highestEff.Value) mod AList.Count;

  for i := 0 to AList.Count - 1 do
  begin
    if i < highestEff.Key then
      continue;
    fList.Add(AList[(highestEff.Value + i) mod AList.Count]);
  end;
  Result := true;
end;

constructor TOptimizedColorList.Create;
begin
  fList := TRGBWList.Create;
end;

destructor TOptimizedColorList.Destroy;
begin
  fList.Free;
  inherited;
end;

procedure TOptimizedColorList.GetSmallestStream(AStream: TStream;
  var IsCompressed: Boolean);
var
  m1, m2: TMemoryStream;
  buf: TArray<TRGBWColor>;

  CompressSize: Int64;
begin
  if not Assigned(AStream) then
    raise EStreamError.Create('Stream not assigned');

  buf := fList.ToArray;
  m1 := TMemoryStream.Create;
  m2 := TMemoryStream.Create;
  try
    m1.WriteData(@buf[0], Length(buf) * Sizeof(buf[0]));
    m1.Position := 0;

    //TLZ4.Stream_Encode(m1, m2, TLZ4.TStreamBlockSize.sbs64K);  // Gives LZ4 Frame Format
    CompressSize := TLZ4.CompressionBound(m1.Size);
    m2.Size := CompressSize;
    m2.Position := 0;
    CompressSize := TLZ4.Encode(m1.Memory, m2.Memory, m1.Size, m2.Size);
    m2.Size := CompressSize;

    IsCompressed := (m2.Size < m1.Size) and (m2.Size > 0);
    if IsCompressed then
      AStream.CopyFrom(m2, 0)
    else
      AStream.CopyFrom(m1, 0);
  finally
    m1.Free;
    m2.Free;
  end;
end;

{$ENDREGION}

{$REGION 'TLEDMessage'}

procedure TLEDMessage.AddModule(AModule: TLEDModule);
begin
  fModules.Add(AModule);
end;

procedure TLEDMessage.Clear;
begin
  fModules.Clear;
end;

constructor TLEDMessage.Create;
begin
  fModules := TObjectList<TLEDModule>.Create;
end;

destructor TLEDMessage.Destroy;
begin
  fModules.Free;
  inherited;
end;


procedure TLEDMessage.MessageColor(AStream: TStream);
var
  wr: TBinaryWriter;
  colors: TOptimizedColorList;
  sbuf: TMemoryStream;

  e: TLEDModule;
  lenPos, sizeBefore: Cardinal;
  s, l, o: Word;
  isCompressed: Boolean;
begin
  if not Assigned(AStream) then
    raise EStreamError.Create('Stream not assigned');

  if fModules.Count > 255 then
    raise Exception.Create('Max Module count is 255');

  colors := nil;
  wr := TBinaryWriter.Create(AStream);
  try
    sizeBefore := AStream.Size;

    colors := TOptimizedColorList.Create;

    wr.Write(MSG_BEGIN);
    wr.Write(C_EXPERIMENTAL);
    lenPos := AStream.Position;
    wr.Write(Word(0)); // Placeholder for Message Length
    wr.Write(Byte(fModules.Count));
    for e in fModules do
    begin
      e.GetBinaryHeader(AStream); // Write everything except LEDDataRange
      if not colors.AddRange(e.LEDColors, s, l, o) then
      begin
        s := 0;
        l := 0;
        o := 0;
      end;
      wr.Write(s);
      wr.Write(l);
      wr.Write(o);
    end;

    sbuf := TMemoryStream.Create;
    colors.GetSmallestStream(sbuf, isCompressed);

    wr.Write(Byte(COLARR_BEGIN + isCompressed.ToInteger));
    wr.Write(Word(colors.List.Count));
    AStream.CopyFrom(sbuf, 0);

    AStream.Position := lenPos;
    wr.Write(Word(AStream.Size - sizeBefore));

    wr.Close;
    AStream.Seek(0, soFromEnd);
  finally
    sbuf.Free;
    colors.Free;
    wr.Free;
  end;
end;

class procedure TLEDMessage.MessageOnOff(AStream: TStream; State: Boolean);
var
  wr: TBinaryWriter;
begin
  if not Assigned(AStream) then
    raise EStreamError.Create('Stream not assigned');

  wr := TBinaryWriter.Create(AStream);
  try
    wr.Write(MSG_BEGIN);
    wr.Write(C_OFF + State.ToInteger);
    wr.Write(Word(4));
  finally
    wr.Free;
  end;
end;

class procedure TLEDMessage.MessageStatus(AStream: TStream);
var
  wr: TBinaryWriter;
begin
  if not Assigned(AStream) then
    raise EStreamError.Create('Stream not assigned');

  wr := TBinaryWriter.Create(AStream);
  try
    wr.Write(MSG_BEGIN);
    wr.Write(C_STATUS);
    wr.Write(Word(4));
  finally
    wr.Free;
  end;
end;

{$ENDREGION}

end.
