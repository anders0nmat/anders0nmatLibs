unit StringHelper;

interface

uses
  Windows, SysUtils, Registry, Vcl.Graphics, System.Hash, System.Classes, StrUtils, Generics.Collections, Math;

type
  TSystemPath = (Desktop, StartMenu,
    Programs, Startup, Personal, AppData,
    Fonts, SendTo, Recent, Favorites, Cache,
    Cookies, History, NetHood, PrintHood,
    Templates, LocADat, WindRoot, WindSys,
    TempPath, RootDir, ProgFiles, ComFiles,
    ConfigPath, DevicePath, MediaPath, WallPaper);

  TCompletionRec = record
    Total: Integer;
    Overhead: Integer;
    Complete: Integer;

    function ToString: String;

    class operator Add(A, B: TCompletionRec): TCompletionRec;
    private const
      FORMAT_STRING = '(%d/%d) [%d]';
  end;

  TCompletionRecHelper = record helper for TCompletionRec
  public const
    Empty: TCompletionRec = (Total: 0; Overhead: 0; Complete: 0);
  end;

function Path(Parts: array of String): String;

function FindStringMatches(ASrc, ADest: TStringList; ASrcPrefix, ADestPrefix: String): TCompletionRec;
function FindMatches(ASrc, ADest: String): TCompletionRec;
function GetSystemPath(SystemPath: TSystemPath): string;

function GetFileHashSHA256(FileName: WideString): String;
function GetStreamHashSHA256(AStream: TStream): String;

procedure FindFiles(Directory: String; WildCard: string; out Result: TStringList; SubDirs: Boolean = true);
procedure FindDirs(Directory: String; out Result: TStringList; SubDirs: Boolean = true);

function GetLastPath(Str: String): String;
function DeleteLastPath(Str: String): String;
function GetPathDifference(APath, AReference: String): String;
function DeleteFirstPath(Str: String): String;
function GetLeftPath(APath: String; Parts: Cardinal): String;
function GetRightPath(APath: String; Parts: Cardinal): String;
function FitStrLabel(ACanvas: TCanvas; var AString: String; MaxWidth: Integer; StaticLeft: Integer = 2): Boolean;
function FindDirContent(Directory: String): TStringList; deprecated;
function DirList(Directory: String; SubDirectories: Boolean = false): TStringList; deprecated 'Use FindDirs';

function FindDirectories(Directory: String; WildCard: string; List: TStringlist; PrePath: String): TStringList; deprecated 'Use FindFiles';
function AppendStrEx(Parts: array of String; Delimiter: String): String;
function LevenshteinDistance(const s, t: string): integer; inline;

implementation

function LevenshteinDistance(const s, t: string): integer; inline;
var
  d: array of array of integer;
  n, m, i, j: integer;
begin
  n := length(s);
  m := length(t);
  if n = 0 then Exit(m);
  if m = 0 then Exit(n);

  SetLength(d, n + 1, m + 1);
  for i := 0 to n do d[i, 0] := i;
  for j := 0 to m do d[0, j] := j;

  for i := 1 to n do
    for j := 1 to m do
      d[i, j] := Min(Min(d[i-1, j]+1, d[i,j-1]+1), d[i-1,j-1]+Integer(s[i] <> t[j]));

  Result := d[n, m];
end;

function AppendStrEx(Parts: array of String; Delimiter: String): String;
var
  i, index, len: Integer;
begin
  Result := '';
  for i := 0 to High(Parts) do
  begin
    index := 1;
    len := Length(Parts[i]);
    if StartsText(Delimiter, Parts[i]) then
    begin
      inc(index);
      Dec(len);
    end;
    if EndsText(Delimiter, Parts[i]) then
      Dec(len);

    if Result <> '' then
      Result := Result + Delimiter + Copy(Parts[i], index, len)
    else
      Result := Copy(Parts[i], index, len);
  end;
end;

function FindMatches(ASrc, ADest: String): TCompletionRec;
var
  ss, sd: TStringList;
begin
  if not DirectoryExists(ASrc) or not DirectoryExists(ADest) then
    raise Exception.Create('Invalid Dir');

  ss := TStringList.Create;
  sd := TStringList.Create;
  FindFiles(ASrc, '*.*', ss);
  FindFiles(ADest, '*.*', sd);
  Result := FindStringMatches(ss, sd, ASrc, ADest);
  ss.Free;
  sd.Free;
end;

function FindStringMatches(ASrc, ADest: TStringList; ASrcPrefix, ADestPrefix: String): TCompletionRec;
var
  s: String;
  hsl: TDictionary<String, Boolean>;
begin
  if not Assigned(ASrc) and not Assigned(ADest) then
    raise Exception.Create('No valid StringList');

  Result := TCompletionRec.Empty;
  Result.Total := ASrc.Count;
  hsl := TDictionary<String, Boolean>.Create;
  for s in ASrc do
    hsl.Add(GetPathDifference(s, ASrcPrefix), false);
  for s in ADest do
    if hsl.ContainsKey(GetPathDifference(s, ADestPrefix)) then
      Inc(Result.Complete)
    else
      Inc(Result.Overhead);
  hsl.Free;
end;

function Path(Parts: array of String): String;
begin
  Result := AppendStrEx(Parts, PathDelim);
end;

function GetStreamHashSHA256(AStream: TStream): String;
var
  HashSHA: THashSHA2;
  Stream: TStream;
  Readed: Integer;
  Buffer: PByte;
  BufLen: Integer;
begin
  HashSHA := THashSHA2.Create(SHA256);
  BufLen := 16 * 1024;
  Buffer := AllocMem(BufLen);
  try
    AStream.Position := 0;
    Stream := AStream;
    while Stream.Position < Stream.Size do
    begin
      Readed := Stream.Read(Buffer^, BufLen);
      if Readed > 0 then
      begin
        HashSHA.update(Buffer^, Readed);
      end;
    end;
  finally
    FreeMem(Buffer)
  end;
  result := HashSHA.HashAsString;
end;

function GetFileHashSHA256(FileName: WideString): String;
var
  HashSHA: THashSHA2;
  Stream: TStream;
  Readed: Integer;
  Buffer: PByte;
  BufLen: Integer;
begin
  HashSHA := THashSHA2.Create(SHA256);
  BufLen := 16 * 1024;
  Buffer := AllocMem(BufLen);
  try
    Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      while Stream.Position < Stream.Size do
      begin
        Readed := Stream.Read(Buffer^, BufLen);
        if Readed > 0 then
        begin
          HashSHA.update(Buffer^, Readed);
        end;
      end;
    finally
      Stream.Free;
    end;
  finally
    FreeMem(Buffer)
  end;
  result := HashSHA.HashAsString;
end;

function DirList(Directory: String; SubDirectories: Boolean): TStringList;
var
  DirRec: TSearchRec;
  SubDirs: array of string;
  i: Integer;
begin
  Result := TStringList.Create;
  SetCurrentDir(Directory);
  SetLength(SubDirs, 0);

  if FindFirst('*',faDirectory,DirRec) = 0 then
  begin
    repeat
      if (DirRec.Attr and faDirectory = faDirectory) and (DirRec.Name <> '.') and (DirRec.Name <> '..') then
      begin
        if SubDirectories then
        begin
          SetLength(SubDirs,Length(SubDirs) + 1);
          SubDirs[Length(SubDirs)-1] := DirRec.Name;
        end;
        Result.Add(DirRec.Name);
      end;
    until FindNext(DirRec) <> 0;
    FindClose(DirRec);
  end;

  if not SubDirectories then
    exit;

  if Length(SubDirs) > 0 then
  begin
    for i := 0 to High(SubDirs) do
    begin
      Result.AddStrings(DirList(Directory + '\' + SubDirs[i], true));
    end;
  end;
end;

function FindDirContent(Directory: String): TStringList;
var
  DirRec: TSearchRec;
begin
  Result := TStringList.Create;
  SetCurrentDir(Directory);

  if FindFirst('*', faAnyFile, DirRec) = 0 then
  begin
    repeat
      Result.Add(Path([Directory, DirRec.Name]));
    until FindNext(DirRec) <> 0;
    FindClose(DirRec);
  end;
end;

procedure FindFiles(Directory: String; WildCard: string; out Result: TStringList; SubDirs: Boolean);
var
  Dirs: TList<String>;
  FindRec: TSearchRec;
  d: String;
begin
  if not Assigned(Result) then
    raise Exception.Create('No valid TStringList');
  if not DirectoryExists(Directory) then
    raise Exception.Create('No valid Folder');

  SetCurrentDir(Directory);

  if FindFirst(WildCard, faAnyFile, FindRec) = 0 then
  begin
    repeat
      if (FindRec.Attr and faDirectory <> faDirectory) and not MatchText(FindRec.Name, ['.', '..']) then
        Result.Add(Path([Directory, FindRec.Name]));
    until FindNext(FindRec) <> 0;
    FindClose(FindRec);
  end;

  if not SubDirs then
    exit;

  Dirs := TList<String>.Create;
  try
    if FindFirst('*', faDirectory, FindRec) = 0 then
    begin
      repeat
        if (FindRec.Attr and faDirectory = faDirectory) and not MatchText(FindRec.Name, ['.', '..']) then
          Dirs.Add(Path([Directory, FindRec.Name]));
      until FindNext(FindRec) <> 0;
      FindClose(FindRec);
    end;

    for d in Dirs do
      FindFiles(d, WildCard, Result);
  finally
    Dirs.Free;
  end;
end;

procedure FindDirs(Directory: String; out Result: TStringList; SubDirs: Boolean = true);
var
  Dirs: TList<String>;
  DirRec: TSearchRec;
  d: String;
begin
  if not Assigned(Result) then
    raise Exception.Create('No valid TStringList');
  if not DirectoryExists(Directory) then
    raise Exception.Create('No valid Folder');

  SetCurrentDir(Directory);

  Dirs := TList<String>.Create;
  try
    if FindFirst('*', faDirectory, DirRec) = 0 then
    begin
      repeat
        if not MatchText(DirRec.Name, ['.', '..']) then
          Dirs.Add(Path([Directory, DirRec.Name]));
      until FindNext(DirRec) <> 0;
      FindClose(DirRec);
    end;

    Result.AddStrings(Dirs.ToArray);

    if not SubDirs then
      exit;

    for d in Dirs do
      FindDirs(d, Result);
  finally
    Dirs.Free;
  end;
end;

function FindDirectories(Directory: String; WildCard: string; List: TStringlist; PrePath: String): TStringList;
var
  DirRec: TSearchRec;
  SubDirs: array of String;
  i: Integer;
begin
  Result := TStringList.Create;
  SetCurrentDir(Directory);
  SetLength(SubDirs,0);

  //Search for SubDirectories
  if FindFirst('*', faDirectory, DirRec) = 0 then
  begin
    repeat
      if (DirRec.Attr and faDirectory = faDirectory) and (DirRec.Name <> '.') and (DirRec.Name <> '..') then
      begin
        SetLength(SubDirs,Length(SubDirs) + 1);
        SubDirs[Length(SubDirs)-1] := DirRec.Name;
      end;
    until FindNext(DirRec) <> 0;
    FindClose(DirRec);
  end;

  //List Files
  if FindFirst(WildCard, faAnyFile, DirRec) = 0 then
  begin
    repeat
      if (DirRec.Attr and faDirectory <> faDirectory) and (DirRec.Name <> '.') and (DirRec.Name <> '..') then
      begin
        Result.Add(Directory + '\' + DirRec.Name);
        List.Add('\' + Prepath + '\' + DirRec.Name);
      end;
    until FindNext(DirRec) <> 0;
    FindClose(DirRec);
  end;

  //List Files in SubDirectories
  if Length(SubDirs) > 0 then
  begin
    for i := 0 to Length(SubDirs) - 1 do
    begin
      Result.AddStrings(FindDirectories(Directory + '\' + SubDirs[i], WildCard, List, Prepath + '\' + SubDirs[i]));
    end;
  end;
end;

function FitStrLabel(ACanvas: TCanvas; var AString: String; MaxWidth: Integer; StaticLeft: Integer = 2): Boolean;
var
  StrWidth, i: Integer;
  LeftStr, RightStr: String;
begin
  StrWidth := ACanvas.TextWidth(AString);
  if StrWidth > MaxWidth then
  begin
    i := 1;
    repeat
      LeftStr := GetLeftPath(AString, StaticLeft);
      Dec(StaticLeft);
    until ACanvas.TextWidth(LeftStr) < MaxWidth;

    repeat
      RightStr := GetRightPath(AString, i);
      Inc(i);
      StrWidth := ACanvas.TextWidth(LeftStr + '...' + RightStr);
    until StrWidth > MaxWidth;
    RightStr := GetRightPath(AString, i - 2);
    AString := LeftStr + '...' + RightStr;
    Result := true;
  end
  else
  begin
    Result := false;
  end;
end;

function GetLeftPath(APath: String; Parts: Cardinal): String;
var
  i: Integer;
begin
  Result := '';
  if Parts = 0 then
    exit;

  for i := 1 to Length(APath) do
  begin
    if APath[i] <> '\' then
      continue;

    dec(Parts);
    if Parts = 0 then
    begin
      Result := Copy(APath, 1, i);
      exit;
    end;
  end;
end;

function GetRightPath(APath: String; Parts: Cardinal): String;
var
  i: Integer;
begin
  Result := '';
  if Parts = 0 then
    exit;

  for i := Length(APath) downto 1 do
  begin
    if APath[i] <> '\' then
      continue;

    dec(Parts);
    if Parts = 0 then
      Result := Copy(APath, i, Length(APath) - i + 1);
  end;
end;

function GetPathDifference(APath, AReference: String): String;
var
  i: Integer;
begin
  Result := APath;
  if APath = '' then
    exit('');
  if AReference = '' then
    exit(APath);

  for i := 1 to Length(APath) do
  begin
    if APath[i] = AReference[i] then
      continue;
    break;
  end;
  for i := i downto 1 do
    if APath[i] = '\' then
      break;
  Delete(Result, 1, i);
end;

function DeleteFirstPath(Str: String): String;
var
  i: Integer;
begin
  Result := Str;
  if Length(Str) < 2 then
    Exit;
  for i := 2 to Length(Str) do
  begin
    if Str[i] = '\' then
    begin
      Delete(Result, 1, i - 1);
      break;
    end;
  end;
end;

function DeleteLastPath(Str: String): String;
var
  x: Integer;
begin
  Result := Str;
  for x := Length(Str) downto 1 do
  begin
    if Str[x] = '\' then
    begin
      Delete(Result,x,Length(Str) - x + 1);
      break;
    end;
  end;
end;

function GetLastPath(Str: String): String;
var
  x: Integer;
begin
  Result := Str;
  for x := Length(Str) downto 1 do
  begin
    if Str[x] = '\' then
    begin
      Delete(Result,1,x);
      break;
    end;
  end;
end;

function GetSystemPath(SystemPath: TSystemPath): string;
var
  ph: PChar;
begin
  with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;
      OpenKey('\Software\Microsoft\Windows\CurrentVersion\' +
        'Explorer\Shell Folders', True);
      case SystemPath of
        Desktop: Result   := ReadString('Desktop');
        StartMenu: Result := ReadString('Start Menu');
        Programs: Result  := ReadString('Programs');
        Startup: Result   := ReadString('Startup');
        Personal: Result  := ReadString('Personal');
        AppData: Result   := ReadString('AppData');
        Fonts: Result     := ReadString('Fonts');
        SendTo: Result    := ReadString('SendTo');
        Recent: Result    := ReadString('Recent');
        Favorites: Result := ReadString('Favorites');
        Cache: Result     := ReadString('Cache');
        Cookies: Result   := ReadString('Cookies');
        History: Result   := ReadString('History');
        NetHood: Result   := ReadString('NetHood');
        PrintHood: Result := ReadString('PrintHood');
        Templates: Result := ReadString('Templates');
        LocADat: Result   := ReadString('Local AppData');
        WindRoot:
          begin
            GetMem(ph, 255);
            GetWindowsDirectory(ph, 254);
            Result := Strpas(ph);
            Freemem(ph);
          end;
        WindSys:
          begin
            GetMem(ph, 255);
            GetSystemDirectory(ph, 254);
            Result := Strpas(ph);
            Freemem(ph);
          end;
        TempPath:
          begin
            GetMem(ph, 255);
            GetTempPath(254, ph);
            Result := Strpas(ph);
            Freemem(ph);
          end;
        RootDir:
          begin
            GetMem(ph, 255);
            GetSystemDirectory(ph, 254);
            Result := (Copy(Strpas(ph), 1, 2));
            Freemem(ph);
          end;
      end;
      RootKey := HKEY_LOCAL_MACHINE;
      OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion', True);
      case SystemPath of
        ProgFiles: Result := ReadString('ProgramFilesDir');
        ComFiles: Result := ReadString('CommonFilesDir');
        ConfigPath: Result := ReadString('ConfigPath');
        DevicePath: Result := ReadString('DevicePath');
        MediaPath: Result := ReadString('MediaPath');
        WallPaper: Result := ReadString('WallPaperDir');
      end;
    finally
      CloseKey;
      Free;
    end;
  if (Result <> '') and (Result[Length(Result)] <> '\') then
    Result := Result + '\';
end;

{$REGION 'TCompletionRec'}

class operator TCompletionRec.Add(A, B: TCompletionRec): TCompletionRec;
begin
  with Result do
  begin
    Total := A.Total + B.Total;
    Complete := A.Complete + B.Complete;
    Overhead := A.Overhead + B.Overhead;
  end;
end;

function TCompletionRec.ToString: String;
begin
  Result := Format(FORMAT_STRING, [Complete, Total, Overhead]);
end;

{$ENDREGION}

end.
