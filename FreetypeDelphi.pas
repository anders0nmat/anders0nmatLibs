unit FreetypeDelphi;

interface

uses
  FreetypeDelphi.dllImports, SysUtils, Classes, FMX.Graphics;

type
  EFreeTypeException = class(Exception);

  TFreeTypeChar = record
    Width, Height: Integer;
    BearingX, BearingY: Integer;
    Advance: Single;
    BitmapData: TBytes;
    function GetDataAsBitmap: TBitmap;
  end;

  TFreeType = class
  private
    fLib: FT_Library;
    fFaceLoaded: Boolean;
    fFace: FT_Face;
    fPixelSize: Integer;
    fFontMemory: TMemoryStream;
    procedure SetPixelSize(const Value: Integer);
  public
    constructor Create; overload;
    constructor CreateFromFile(AFile: String); overload;
    constructor CreateFromStream(AStream: TStream); overload;
    destructor Destroy; override;

    procedure LoadFromFile(AFile: String);
    procedure LoadFromStream(AStream: TStream);

    function GetChar(Char: WideChar; resolutionDPI: Word; APixelSize: Integer = 0): TFreeTypeChar;

    property PixelSize: Integer read fPixelSize write SetPixelSize;
  end;

implementation

{$REGION 'TFreeType'}

constructor TFreeType.Create;
begin
  if FT_Init_FreeType(@fLib) <> 0 then
    raise EFreeTypeException.Create('Initialisation failed');
  fFontMemory := TMemoryStream.Create;
  fFaceLoaded := false;
end;

constructor TFreeType.CreateFromFile(AFile: String);
begin
  Create;
  LoadFromFile(AFile);
end;

constructor TFreeType.CreateFromStream(AStream: TStream);
var
  ms: TMemoryStream;
begin
  Create;
  LoadFromStream(AStream);
end;

destructor TFreeType.Destroy;
begin
  if fFaceLoaded then
    if FT_Done_Face(fFace) <> 0 then
      raise EFreeTypeException.Create('Freeing face failed');
  if FT_Done_FreeType(fLib) <> 0 then
    raise EFreeTypeException.Create('Freeing lib failed');

  fFontMemory.Free;
  inherited;
end;

function TFreeType.GetChar(Char: WideChar; resolutionDPI: Word; APixelSize: Integer = 0): TFreeTypeChar;
var
  i: Integer;
  y, x: Integer;
begin
  if APixelSize = 0 then
    FT_Set_Char_Size(fFace, 0, fPixelSize * 64, resolutionDPI, resolutionDPI)
  else
    FT_Set_Char_Size(fFace, 0, APixelSize * 64, resolutionDPI, resolutionDPI);

  i := FT_Load_Char(fFace, Cardinal(Char), FT_LOAD_RENDER);
  if i <> 0 then
    raise EFreeTypeException.Create('Loading Char failed');

  with Result do
  begin
    Width := fFace.glyph.bitmap.width;
    Height := fFace.glyph.bitmap.rows;
    BearingX := fFace.glyph.bitmap_left;
    BearingY := fFace.glyph.bitmap_top;
    Advance := fFace.glyph.advance.x / 64;

    if Width * height > 0 then
    begin
      SetLength(BitmapData, width * height);
      for y := 0 to Height - 1 do
        Move(fFace.glyph.bitmap.buffer[y * abs(fFace.glyph.bitmap.pitch)], BitmapData[y * Width], Width);
      //    BitmapData[y * width + x] :=
      //      fFace.glyph.bitmap.buffer[y * abs(fFace.glyph.bitmap.pitch) + x];
    end;
  end;
end;

procedure TFreeType.LoadFromFile(AFile: String);
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(AFile, fmOpenRead);
  try
    LoadFromStream(fs);
  finally
    fs.Free;
  end;
end;

procedure TFreeType.LoadFromStream(AStream: TStream);
begin
  if fFaceLoaded then
    if FT_Done_Face(fFace) <> 0 then
      raise EFreeTypeException.Create('Freeing face failed');

  fFontMemory.LoadFromStream(AStream);
  if FT_New_Memory_Face(fLib, fFontMemory.Memory, fFontMemory.Size, 0, @fFace) <> 0 then
    raise EFreeTypeException.Create('Creating new face failed');

  fFaceLoaded := true;
end;

procedure TFreeType.SetPixelSize(const Value: Integer);
begin
  if fPixelSize <> Value then
  begin
    if Value < 1 then
      fPixelSize := 1
    else
      fPixelSize := Value;
  end;
end;

{$REGION 'TFreeTypeChar'}

function TFreeTypeChar.GetDataAsBitmap: TBitmap;
var
  bitPointer: TBitmapData;
  y: Integer;
  x: Integer;
begin
  Result := TBitmap.Create(Width, Height);
  Result.Map(TMapAccess.Write, bitPointer);
  for y := 0 to Height - 1 do
    for x := 0 to Width - 1 do
      bitPointer.SetPixel(x, y, BitmapData[y * Width + x] shl 24);
  //Move(BitmapData[0], bitPointer.GetScanline(y)^, Width);
  Result.Unmap(bitPointer);
end;

{$ENDREGION}

end.
