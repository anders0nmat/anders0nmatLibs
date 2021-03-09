unit ColorControl;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, windows, graphics, math, system.uitypes, winapi.messages, System.Types;

type
  TRectColor = class(TPersistent)
  private
    fNotifyEvent: TNotifyEvent;
    fBrush, fPen: TColor;
    procedure SetColor(Index: Integer; Value: TColor);
  public
    constructor Create(AColor: TColor); overload;
    constructor Create(BrushColor, PenColor: TColor); overload;
  published
    property Brush: TColor index 0 read fBrush write SetColor;
    property Pen: TColor index 1 read fPen write SetColor;
    property OnChange: TNotifyEvent read fNotifyEvent write fNotifyEvent;
  end;

  TRGBColor = record
  private
    fRaw: array[0..2] of Byte;
    function GetRaw(Index: Integer): Byte;
    procedure SetRaw(Index: Integer; Value: Byte);
  public
    class operator Implicit(A: TColor): TRGBColor;
    class operator Implicit(A: TRGBColor): TColor;

    class operator Equal(A, B: TRGBColor): Boolean;
    class operator NotEqual(A, B: TRGBColor): Boolean;

    property Raw[Index: Integer]: Byte read GetRaw write SetRaw; default;
    property R: Byte index 0 read GetRaw write SetRaw;
    property G: Byte index 1 read GetRaw write SetRaw;
    property B: Byte index 2 read GetRaw write SetRaw;
  end;

  TRGBWColor = record
  private
    fRaw: array[0..3] of Byte;
    function GetRaw(Index: Integer): Byte;
    procedure SetRaw(Index: Integer; Value: Byte);
  public
    class operator Implicit(A: TColor): TRGBWColor;
    class operator Implicit(A: TRGBColor): TRGBWColor;

    class operator Explicit(A: TRGBWColor): TRGBColor;
    class operator Explicit(A: TRGBWColor): TColor;

    class operator Equal(A, B: TRGBWColor): Boolean;
    class operator NotEqual(A, B: TRGBWColor): Boolean;

    property Raw[Index: Integer]: Byte read GetRaw write SetRaw; default;
    property R: Byte index 0 read GetRaw write SetRaw;
    property G: Byte index 1 read GetRaw write SetRaw;
    property B: Byte index 2 read GetRaw write SetRaw;
    property W: Byte index 3 read GetRaw write SetRaw;
  end;

  TButtonState = (bsIdle, bsHover, bsClick);

  TBGR = packed record
    private
      function GetRaw(Index: Integer): Byte;
      procedure SetRaw(Index: Integer; Value: Byte);
    public

    property Raw[index: integer]: Byte read GetRaw write SetRaw; default;
    case Byte of
      0: (b, g, r: Byte);
      1: (fraw: array[0..2] of Byte);
  end;

  TOrientation = (toHorizontal, toVertical);
  TMarkPosition = (mpLeft, mpRight, mpTop, mpBottom);

  TDrawFunc = procedure (ABitmap: TBitmap; X, Y: Integer) of object;
  TDrawFuncGradient = procedure (ABitmap: TBitmap; position, foffset: Integer; MarkPosition: TMarkPosition; Hover: Boolean) of object;
  TDrawBit = procedure (ABitmap: TBitmap; MarkPosition: TMarkPosition) of object;

  TColorPalette = class(TGraphicControl)
  private
    { Private-Deklarationen }

    fRotation: Cardinal;
    fOffset: Cardinal;
    fMirror: Boolean;
    fColor: TColor;
    fbgColor: TColor;
    fColorCircle: TBitmap;
    fDrawFunc: TDrawFunc;
    fDown: Boolean;
    fChange: TNotifyEvent;
    fDoubleBuffered: Boolean;
    fParentColor: Boolean;
    fColValue: Byte;
    posx, posy: Integer;

    rad, mid: Integer;

    procedure SetRotation(Value: Cardinal);
    procedure SetMirror(Value: Boolean);
    procedure SetColor(Value: TColor);
    procedure SetbgColor(Value: TColor);
    procedure SetOffset(Value: Cardinal);
    procedure SetDoubleBuffered(Value: Boolean);
    procedure SetParentColor(Value: Boolean);
    procedure SetColValue(Value: Byte);

    procedure DrawDefaultMark(x, y: integer);
    procedure DrawMark(x, y: Integer);
    procedure GenBitmap;
  protected
    { Protected-Deklarationen }
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;

    procedure Change;
    procedure Resize; override;
  public
    { Public-Deklarationen }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Canvas;
    property PopupMenu;
  published
    { Published-Deklarationen }
    property Rotation: Cardinal read fRotation write SetRotation;
    property Mirror: Boolean read fMirror write SetMirror;
    property SelectedColor: TColor read fColor write SetColor;
    property BackgroundColor: TColor read fbgColor write SetbgColor;
    property Offset: Cardinal read fOffset write SetOffset;
    property DoubleBuffered: Boolean read FDoubleBuffered write SetDoubleBuffered;
    property ParentColor: Boolean read fParentColor write SetParentColor;
    property ColorValue: Byte read fColValue write SetColValue;
    property Visible;
    property Enabled;

    property OnClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnDrawSel: TDrawFunc read fDrawFunc write fDrawFunc;
    property OnChange: TNotifyEvent read fChange write fChange;
  end;

  TColorBar = class(TGraphicControl)
  private
    fDrawBit: TDrawBit;
    fStartColor: TColor;
    fStopColor: TColor;
    fbgColor: TColor;
    fParentColor: Boolean;
    fOffset: INteger;
    fChange: TNotifyEvent;
    fGradient: TBitmap;
    fOrientation: TOrientation;
    fSelectedColor: TColor;
    fMarkPosition: TMarkPosition;
    fMarkOffset: Integer;
    fPosition: Word;
    fDrawFunc: TDrawFuncGradient;
    fDown: Boolean;
    updateEnabled: Boolean;
    fLimit: Word;
    fHover: Boolean;
    fEnter: Boolean;


    procedure SetColor(Index: Integer; Value: TColor);
    procedure SetParentColor(Value: Boolean);
    procedure SetOffset(Value: Integer);
    procedure SetOrientation(Value: TOrientation);
    procedure SetMarkPosition(Value: TMarkPosition);
    procedure SetMarkOffset(Value: Integer);
    procedure SetLimit(Value: Word);

    procedure SetPosition(Value: Word);

    procedure DrawDefaultMark(position, fOffset: Integer; MarkPosition: TMarkPosition; Hover: Boolean);
    procedure DrawMark(vposition, foffset: Integer; MarkPosition: TMarkPosition);

    procedure GenBitmap;

    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;

    procedure Change;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Canvas;
    property PopupMenu;
    property SelectedColor: TColor read fSelectedColor;
  published
    property StartColor: TColor index 0 read fStartColor write SetColor;
    property StopColor: TColor index 1 read fStopColor write SetColor;
    property bgColor: TColor index 2 read fbgColor write SetColor;
    property ParentColor: Boolean read fParentColor write SetParentColor;
    property Offset: Integer read fOffset write SetOffset;
    property Orientation: TOrientation read fOrientation write SetOrientation;
    property MarkPosition: TMarkPosition read fMarkPosition write SetMarkPosition;
    property MarkOffset: Integer read fMarkOffset write SetMarkOffset;
    property Position: Word read fPosition write SetPosition;
    property Max: Word read fLimit write SetLimit;

    property OnClick;
    property OnChange: TNotifyEvent read fChange write fChange;
    property OnDrawSel: TDrawFuncGradient read fDrawFunc write fDrawFunc;
    property OnGradient: TDrawBit read fDrawBit write fDrawBit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
  end;

  TFlatButton = class(TGraphicControl)
  private
    fIdleColor: TRectColor;
    fHoverColor: TRectColor;
    fClickColor: TRectColor;
    fBitmap: TBitmap;
    fTextOffset: Integer;
    fPicOffset: Integer;
    fChecked: Boolean;
    fCanCheck: Boolean;

    ButtonState: TButtonState;

    procedure SetColor(Index: Integer; Value: TRectColor);
    procedure ColorChanged(Sender: TObject);
    procedure SetBitmap(Value: TBitmap);
    procedure SetOffset(Index: Integer; Value: INteger);
    procedure SetChecked(Value: Boolean);
    procedure SetCanCheck(Value: Boolean);
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
  protected
    procedure Paint; override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;

    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Canvas;
  published
    property Caption;
    property Enabled;
    property Font;
    property Visible;
    property ColorIdle: TRectColor index 0 read fIdleColor write SetColor;
    property ColorHover: TRectColor index 1 read fHoverColor write SetColor;
    property ColorClick: TRectColor index 2 read fClickColor write SetColor;
    property Picture: TBitmap read fBitmap write SetBitmap;
    property TextOffset: Integer index 0 read fTextOffset write SetOffset;
    property PicOffset: Integer index 1 read fPicOffset write SetOffset;
    property PopupMenu;
    property ParentFont;
    property Checked: Boolean read fChecked write SetChecked;
    property CanCheck: Boolean read fCanCheck write SetCanCheck;

    property OnClick;
    property OnDblClick;
    property OnResize;
    property OnMouseActivate;
    property OnMouseEnter;
    property OnMouseDown;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

  TColorDifference = class(TGraphicControl)
  private
    fColorReference: TColor;
    fColorCompare: TColor;
    fBorderColor: TColor;
    fOrientation: TOrientation;

    procedure SetColor(Index: integer; Value: TColor);
    procedure SetOrientation(Value: TOrientation);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ColorReference: TColor index 0 read fColorReference write SetColor;
    property ColorCompare: TColor index 1 read fColorCompare write SetColor;
    property Orientation: TOrientation read fOrientation write SetOrientation;
    property BorderColor: TColor index 2 read fBorderColor write SetColor;

    property Visible;
  end;

{$REGION 'DEF'}

procedure Register;

function RGBColor(R, G, B: Byte): TRGBColor;
function RGBWColor(R, G, B, W: Byte): TRGBWColor; overload;
function RGBWColor(RGBColor: TRGBColor; W: Byte): TRGBWColor; overload;

procedure Limit(var Value: Cardinal; Min, Max: Cardinal); overload;
procedure Limit(var Value: Integer; Min, Max: Integer); overload;
procedure Limit(var Value: Word; Min, Max: Word); overload;

procedure RGBtoHSV(Red, Green, Blue: Byte; var Hue: Integer; var Saturation, Value: Byte); overload;
procedure RGBtoHSV(Color: TColor; var Hue: Integer; var Saturation, Value: Byte); overload;
procedure RGBtoHSV(RGBColor: TRGBColor; var Hue: Integer; var Saturation, Value: Byte); overload;

function HSVtoRGB(H: Integer; S, V: Byte): TRGBColor;

function BGRT(r, g, b: Byte): TBGR; overload;
function BGRT(Color: Cardinal): TBGR; overload;

function GetGradientProgress(StartColor, StopColor: TColor; Progress: Single): TColor;
function Brighten(AColor: TColor; Value: Byte): TColor;

{$ENDREGION}

implementation

{$REGION 'MISC'}

procedure Register;
begin
  RegisterComponents('Color', [TColorPalette, TColorBar, TFlatButton, TColorDifference]);
end;

function RGBColor(R, G, B: Byte): TRGBColor;
begin
  Result.R := R;
  Result.G := G;
  Result.B := B;
end;

function RGBWColor(R, G, B, W: Byte): TRGBWColor;
begin
  Result.R := R;
  Result.G := G;
  Result.B := B;
  Result.W := W;
end;

function RGBWColor(RGBColor: TRGBColor; W: Byte): TRGBWColor;
begin
  Result := RGBColor;
  Result.W := w;
end;

function Brighten(AColor: TColor; Value: Byte): TColor;
var
  r, g, b: Word;
begin
  r := GetRValue(AColor) + Value;
  g := GetGValue(AColor) + Value;
  b := GetBValue(AColor) + Value;
  Limit(r, 0, 255);
  limit(g, 0, 255);
  Limit(b, 0, 255);
  Result := RGB(Byte(R), Byte(G), Byte(B));
end;

function GetGradientProgress(StartColor, StopColor: TColor; Progress: Single): TColor;
var
  tmpR, tmpG, tmpB: Word;
begin
  tmpR := trunc(GetRValue(StartColor) * (1 - Progress) + GetRValue(StopColor) * Progress);
  tmpG := trunc(GetGValue(StartColor) * (1 - Progress) + GetGValue(StopColor) * Progress);
  tmpB := trunc(GetBValue(StartColor) * (1 - Progress) + GetBValue(StopColor) * Progress);
  Result := RGB(tmpR, tmpG, tmpB);
end;

procedure Limit(var Value: Word; Min, Max: Word);
begin
  if Value < Min then
  begin
    Value := Min;
    exit;
  end
  else if Value > Max then
  begin
    Value := Max;
    exit;
  end;
end;

procedure Limit(var Value: Cardinal; Min, Max: Cardinal);
begin
  if Value < Min then
  begin
    Value := Min;
    exit;
  end
  else if Value > Max then
  begin
    Value := Max;
    exit;
  end;
end;

procedure Limit(var Value: Integer; Min, Max: Integer);
begin
  if Value < Min then
  begin
    Value := Min;
    exit;
  end
  else if Value > Max then
  begin
    Value := Max;
    exit;
  end;
end;

procedure RGBtoHSV(RGBColor: TRGBColor; var Hue: Integer; var Saturation, Value: Byte);
var
  Maximum, Minimum, Red, Green, Blue: Byte;
  Rc, Gc, Bc: Single;
  H: Single;
begin
  Red := RGBColor.R;
  Green := RGBColor.G;
  Blue := RGBColor.B;
  Maximum := Max(Red, Max(Green, Blue));
  Minimum := Min(Red, Min(Green, Blue));
  Value := Maximum;
  if Maximum <> 0 then
    Saturation := MulDiv(Maximum - Minimum, 255, Maximum)
  else
    Saturation := 0;
  if Saturation = 0 then
    Hue := 0 // arbitrary value
  else
  begin
    Assert(Maximum <> Minimum);
    Rc := (Maximum - Red) / (Maximum - Minimum);
    Gc := (Maximum - Green) / (Maximum - Minimum);
    Bc := (Maximum - Blue) / (Maximum - Minimum);
    if Red = Maximum then
      H := Bc - Gc
    else if Green = Maximum then
      H := 2 + Rc - Bc
    else
    begin
      Assert(Blue = Maximum);
      H := 4 + Gc - Rc;
    end;
    H := H * 60;
    if H < 0 then
      H := H + 360;
    Hue := Round(H);
  end;
end;

procedure RGBtoHSV(Red, Green, Blue: Byte; var Hue: Integer; var Saturation, Value: Byte);
var
  Maximum, Minimum: Byte;
  Rc, Gc, Bc: Single;
  H: Single;
begin
  Maximum := Max(Red, Max(Green, Blue));
  Minimum := Min(Red, Min(Green, Blue));
  Value := Maximum;
  if Maximum <> 0 then
    Saturation := MulDiv(Maximum - Minimum, 255, Maximum)
  else
    Saturation := 0;
  if Saturation = 0 then
    Hue := 0 // arbitrary value
  else
  begin
    Assert(Maximum <> Minimum);
    Rc := (Maximum - Red) / (Maximum - Minimum);
    Gc := (Maximum - Green) / (Maximum - Minimum);
    Bc := (Maximum - Blue) / (Maximum - Minimum);
    if Red = Maximum then
      H := Bc - Gc
    else if Green = Maximum then
      H := 2 + Rc - Bc
    else
    begin
      Assert(Blue = Maximum);
      H := 4 + Gc - Rc;
    end;
    H := H * 60;
    if H < 0 then
      H := H + 360;
    Hue := Round(H);
  end;
end;

procedure RGBtoHSV(Color: TColor; var Hue: Integer; var Saturation, Value: Byte);
var
  Maximum, Minimum, Red, Green, Blue: Byte;
  Rc, Gc, Bc: Single;
  H: Single;
begin
  Red := GetRValue(Color);
  Green := GetGValue(Color);
  Blue := GetBValue(Color);
  Maximum := Max(Red, Max(Green, Blue));
  Minimum := Min(Red, Min(Green, Blue));
  Value := Maximum;
  if Maximum <> 0 then
    Saturation := MulDiv(Maximum - Minimum, 255, Maximum)
  else
    Saturation := 0;
  if Saturation = 0 then
    Hue := 0 // arbitrary value
  else
  begin
    Assert(Maximum <> Minimum);
    Rc := (Maximum - Red) / (Maximum - Minimum);
    Gc := (Maximum - Green) / (Maximum - Minimum);
    Bc := (Maximum - Blue) / (Maximum - Minimum);
    if Red = Maximum then
      H := Bc - Gc
    else if Green = Maximum then
      H := 2 + Rc - Bc
    else
    begin
      Assert(Blue = Maximum);
      H := 4 + Gc - Rc;
    end;
    H := H * 60;
    if H < 0 then
      H := H + 360;
    Hue := Round(H);
  end;
end;

function HSVtoRGB(H: Integer; S, V: Byte): TRGBColor;
var
  ht, d, t1, t2, t3:Integer;
  R, G, B:Word;
begin
  if S = 0 then
   begin
    R := V; G := V; B := V;
   end
  else
   begin
    ht := H * 6;
    d := ht mod 360;

    t1 := round(V * (255 - S) / 255);
    t2 := round(V * (255 - S * d / 360) / 255);
    t3 := round(V * (255 - S * (360 - d) / 360) / 255);

    case ht div 360 of
    0:  begin
        R := V;  G := t3; B := t1;
      end;
    1:  begin
        R := t2; G := V;  B := t1;
      end;
    2:  begin
        R := t1; G := V;  B := t3;
      end;
    3:  begin
        R := t1; G := t2; B := V;
      end;
    4:  begin
        R := t3; G := t1; B := V;
      end;
    else
      begin
        R := V;  G := t1; B := t2;
      end;
    end;
   end;
  Result := RGBColor(R,G,B);
end;

function BGRT(r, g, b: Byte): TBGR;
begin
  Result.r := r;
  Result.g := g;
  Result.b := b;
end;

function BGRT(Color: Cardinal): TBGR;
begin
  Result.r := GetRValue(Color);
  Result.g := GetGValue(Color);
  Result.b := GetBValue(Color);
end;

{$ENDREGION}

{$REGION 'TColorPalette'}

procedure TColorPalette.Change;
begin
  inherited changed;
  if Assigned(fChange) then fChange(Self);
end;

constructor TColorPalette.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 100;
  height := 100;
  fColValue := 255;
  GenBitmap;
  posx := mid;
  posy := mid;
end;

destructor TColorPalette.Destroy;
begin
  fColorCircle.free;
  inherited;
end;

procedure TColorPalette.DrawDefaultMark(x, y: integer);
begin
  Canvas.Brush.Style := bsClear;
  canvas.Pen.Color := clwhite;
  canvas.Pen.Style := psSolid;
  Canvas.Ellipse(x - 3, y - 3, x + 3, y + 3);
  canvas.Pen.Color := clBlack;
  Canvas.Ellipse(x - 4, y - 4, x + 4, y + 4);
end;

procedure TColorPalette.DrawMark(x, y: integer);
begin
  if Assigned(fDrawFunc) then
    fDrawFunc(fColorCircle, x, y)
  else
    DrawDefaultMark(x, y);
end;

procedure TColorPalette.GenBitmap;
var
  radius, radsqr, h: integer;
  s: Byte;
  i: Integer;
  j: Integer;
  bgColor: TColor;
  p: ^TBGR;
begin
  fColorCircle.Free;
  fColorCircle := TBitmap.Create;
  fColorCircle.PixelFormat := pf24bit;
  fColorCircle.width := Min(width, height) - Integer(fOffset) * 2;
  fColorCircle.height := Min(width, height) - Integer(fOffset) * 2;
  radius := fColorCircle.width div 2;
  radsqr := radius * radius;

  rad := radius;
  mid := radius + Integer(fOffset);

  if fParentColor then
  bgColor := ColorToRGB(Parent.Brush.Color)
  else
  bgColor := fbgColor;

  for i := 0 to fColorCircle.height - 1 do
  begin
    p := fColorCircle.ScanLine[i];
    for j := 0 to fColorCircle.width - 1 do
    begin
      if radsqr < sqr(radius - j) + sqr(radius - i) then
      begin
        p^ := BGRT(ColorToRGB(bgColor));
        inc(p);
        continue;
      end;

      H := round(180 * arctan2(j - radius, i - radius) / PI);
      S := round((sqrt(sqr(radius - j) + sqr(radius - i)) / radius) * 255);

      if h < 0 then
      h := 359 - abs(h);

      h := h - Integer(fRotation);
      if h < 0 then
        h := h + 359;

      if fMirror then
        h := 359 - h;

      p^ := BGRT(HSVtoRGB(H, s, fColValue));
      inc(p);
    end;
  end;
end;

procedure TColorPalette.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  colX, colY: Integer;
begin
  if Button <> mbLeft then
  begin
    inherited;
    exit;
  end;

  if sqr(X - mid) + sqr(Y - mid) <= sqr(rad) then
  begin
    colX := X;
    colY := Y;
    fDown := true;
  end
  else
    exit;

  fColor := fColorCircle.Canvas.Pixels[colx - Integer(fOffset), coly - Integer(fOffset)];
  posx := colx;
  posy := coly;
  change;
  invalidate;
  inherited;
end;

procedure TColorPalette.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  colX, colY: Integer;
  a, ax, ay: Extended;
begin
  if not fDown then
  begin
    inherited;
    exit;
  end;

  if sqr(X - mid) + sqr(Y - mid) <= sqr(rad) then
  begin
    colX := X;
    colY := Y;
  end
  else
  begin
    ax := x - mid;
    ay := y - mid;
    a := sqrt(sqr(ax) + sqr(ay));

    colx := mid + trunc((ax / a) * rad);
    coly := mid + trunc((ay / a) * rad);
  end;

  fColor := fColorCircle.Canvas.Pixels[colx - Integer(fOffset), coly - Integer(fOffset)];
  posx := colx;
  posy := coly;
  invalidate;
  change;
  inherited;
end;

procedure TColorPalette.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    fDown := false;
  inherited;
end;

procedure TColorPalette.Paint;
begin
  inherited;
  if (fColorCircle <> nil) and (Canvas <> nil) then
  begin
    if fParentColor then
      Canvas.Brush.Color := Parent.Brush.Color
    else
      Canvas.Brush.Color := fbgColor;
    Canvas.FillRect(rect(0, 0, width, height));
    Canvas.Draw(fOffset, fOffset, fColorCircle);
    DrawMark(posx, posy);
  end;
end;

procedure TColorPalette.Resize;
begin
  GenBitmap;
  invalidate;
  inherited;
end;

procedure TColorPalette.SetbgColor(Value: TColor);
begin
  if Value <> fbgColor then
  begin
    fbgColor := Value;
    fParentColor := false;
    genBitmap;
    invalidate;
  end;
end;

procedure TColorPalette.SetOffset(Value: Cardinal);
begin
  if Value <> fOffset then
  begin
    fOffset := Value;
    GenBitmap;
    invalidate;
  end;
end;

procedure TColorPalette.SetParentColor(Value: Boolean);
begin
  if Value <> fParentColor then
  begin
    fParentColor := Value;
    if fParentColor then
    begin
      GenBitmap;
      invalidate;
      fbgColor := parent.Brush.Color;
    end;
  end;
end;

procedure TColorPalette.SetColor(Value: TColor);
var
  h, x, y: Integer;
  s, v: Byte;
  hd: double;
begin
  if Value <> fColor then
  begin
    fColor := Value;

    if fColor = clBlack then
    begin
      fColValue := 0;
      posx := mid;
      posy := mid;
      invalidate;
      exit;
    end;

    RGBtoHSV(fColor, h, s, v);
    if fMirror then
    h := 359 - h;
    h := h + Integer(fRotation);
    h := h mod 360;
    {if h < 0 then
    h := h + 359; }

    hd := h * PI / 180;
    x := trunc(sin(hd) * (rad * (s / 255))) + mid;
    y := trunc(cos(hd) * (rad * (s / 255))) + mid;
    posx := x;
    posy := y;
    invalidate;
  end;
end;

procedure TColorPalette.SetColValue(Value: Byte);
begin
  if value <> fColValue then
  begin
    fColValue := value;
    GenBitmap;
    if fColValue = 0 then
    begin
      posx := mid;
      posy := mid;
    end;
    Invalidate;
  end;
end;

procedure TColorPalette.SetDoubleBuffered(Value: Boolean);
begin

end;

procedure TColorPalette.SetMirror(Value: Boolean);
begin
  if Value <> fMirror then
  begin
    fMirror := Value;
    GenBitmap;
    invalidate;
  end;
end;

procedure TColorPalette.SetRotation(Value: Cardinal);
begin
  if Value <> fRotation then
  begin
    Limit(Value, 0, 359);
    fRotation := Value;
    GenBitmap;
    invalidate;
  end;
end;

{$ENDREGION}

{$REGION 'TBGR'}

function TBGR.GetRaw(Index: Integer): Byte;
begin
  Result := 0;
  if (Index >= 0) and (Index <= 2) then
  Result := fRaw[index];
end;

procedure TBGR.SetRaw(Index: Integer; Value: Byte);
begin
  if (Index >= 0) and (Index <= 2) then
  fRaw[index] := Value;
end;

{$ENDREGION}

{$REGION 'TColorBar'}

procedure TColorBar.Change;
begin
  inherited Changed;
  if Assigned(fChange) then fChange(Self);
end;

procedure TColorBar.CMMouseEnter(var Message: TMessage);
begin
  fEnter := true;
end;

procedure TColorBar.CMMouseLeave(var Message: TMessage);
begin
  fHover := false;
  fEnter := false;
  invalidate;
end;

constructor TColorBar.Create(AOwner: TComponent);
begin
  updateEnabled := false;
  inherited Create(AOwner);
  fOrientation := toHorizontal;
  width := 300;
  height := 70;
  fStartColor := clBlack;
  fStopColor := clWhite;
  fMarkPosition := mpBottom;
  Position := 0;
  fLimit := 1000;
  GenBitmap;
  updateEnabled := true;
end;

destructor TColorBar.Destroy;
begin
  fGradient.Free;
  inherited;
end;

procedure TColorBar.DrawDefaultMark(position, fOffset: Integer; MarkPosition: TMarkPosition; Hover: Boolean);
begin
  canvas.Pen.Color := clBlack;
  if Hover then
  begin
    canvas.Brush.Color := clBlue;
    canvas.Pen.Color := clWhite;
  end
  else
  begin
    canvas.Brush.Color := clWhite;
    canvas.Pen.Color := clGray;
  end;

  case MarkPosition of
    mpLeft: Canvas.Polygon([Point(width - fOffset - fGradient.Width - 7, position - 5),
                            Point(width - fOffset - fGradient.Width - 7, position + 5),
                            Point(width - fOffset - fGradient.Width + 1, position)]);
    mpRight: Canvas.Polygon([Point(width - fMarkOffset + 7, position - 5),
                            Point(width - fMarkOffset + 7, position + 5),
                            Point(width - fMarkOffset - 1, position)]);
    mpTop: Canvas.Polygon([Point(position - 5, height - fOffset - fGradient.height - 7),
                            Point(position + 5, height - fOffset - fGradient.height - 7),
                            Point(position, height - fOffset - fGradient.height + 1)]);
    mpBottom: Canvas.Polygon([Point(position - 5, height - fMarkOffset + 7),
                            Point(position + 5, height - fMarkOffset + 7),
                            Point(position, height - fMarkOffset - 1)]);
  end;
end;

procedure TColorBar.DrawMark(vposition, foffset: Integer;
  MarkPosition: TMarkPosition);
begin
  if ord(MarkPosition) < 2 then
  vposition := 255 - trunc(vposition * fGradient.Height / fLimit + foffset)
  else
  vposition := trunc(vposition * fGradient.width / fLimit + foffset);

  if Assigned(fDrawFunc) then
    case MarkPosition of
      mpLeft: fDrawFunc(fGradient, vposition, fOffset, fMarkPosition, fHover);
      mpRight: fDrawFunc(fGradient, vposition, fOffset, fMarkPosition, fHover);
      mpTop: fDrawFunc(fGradient, vposition, fOffset, fMarkPosition, fHover);
      mpBottom: fDrawFunc(fGradient, vposition, fOffset, fMarkPosition, fHover);
    end
  else
    DrawDefaultMark(vposition, fOffset, fMarkPosition, fHover);
end;

procedure TColorBar.GenBitmap;
var
  i: Integer;
begin
  fGradient.Free;
  fGradient := TBitmap.Create;

  if Assigned(fDrawBit) then
  begin
    fDrawBit(fGradient, fMarkPosition);
    exit;
  end;

  if ord(fMarkPosition) < 2 then
  begin
    fGradient.Width := width - fOffset - fMarkOffset;
    fGradient.Height := height - 2 * fOffset;
    for i := 0 to fGradient.Height do
    begin
      fGradient.Canvas.Pen.Color := GetGradientProgress(fStartColor,fStopColor, i / fGradient.Height);
      fGradient.Canvas.MoveTo(0, i);
      fGradient.Canvas.LineTo(fGradient.Width, i);
    end;
  end
  else
  begin
    fGradient.Width := width - 2 * fOffset;
    fGradient.Height := height - fOffset - fMarkOffset;
    for i := 0 to fGradient.width do
    begin
      fGradient.Canvas.Pen.Color := GetGradientProgress(fStartColor,fStopColor,i / fGradient.width);
      fGradient.Canvas.MoveTo(i, 0);
      fGradient.Canvas.LineTo(i, fGradient.Height);
    end;
  end;
end;

procedure TColorBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Button <> mbLeft then
  begin
    inherited;
    exit;
  end;
  case fOrientation of
    toHorizontal: begin
      if (x >= fOffset) and (x <= width - fOffset) and
      (((fMarkPosition = mpTop) and (y <= height - fOffset)) or ((fMarkPosition = mpBottom) and (y >= foffset))) then
      begin
        fDown := true;
        fPosition := trunc(fLimit / fGradient.Width * (x - fOffset));
        invalidate;
      end;
    end;
    toVertical: begin
      if (y >= fOffset) and (y <= height - fOffset) and
      (((fMarkPosition = mpLeft) and (x <= width - fOffset)) or ((fMarkPosition = mpRight) and (x >= foffset))) then
      begin
        fDown := true;
        fPosition := trunc(fLimit / fGradient.height * (y - fOffset));
        invalidate;
      end;
    end;
  end;
  change;
  inherited;
end;

procedure TColorBar.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if fEnter then
  begin
    if ((x >= fOffset) and (x <= width - fOffset) and
    (((fMarkPosition = mpTop) and (y <= height - fOffset)) or ((fMarkPosition = mpBottom) and (y >= foffset))))
    or
    ((y >= fOffset) and (y <= height - fOffset) and
    (((fMarkPosition = mpLeft) and (x <= width - fOffset)) or ((fMarkPosition = mpRight) and (x >= foffset)))) then
    begin
      fHover := true;
      fEnter := false;
      invalidate;
    end;
  end;

  if not fDown then
  begin
    inherited;
    exit;
  end;

  case fOrientation of
    toHorizontal: begin
      limit(x,fOffset, width - fOffset);
      fPosition := trunc(fLimit / fGradient.Width * (x - fOffset));
    end;
    toVertical: begin
      limit(y,fOffset, Height - fOffset);
      fPosition := trunc(fLimit / fGradient.height * (y - fOffset));
    end;
  end;
  invalidate;
  Change;
  inherited;
end;

procedure TColorBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Button = mbLeft then
    fDown := false;
  inherited;
end;

procedure TColorBar.Paint;
var
  i, w, h, m1, m2: Integer;
begin
  inherited;
  if (fGradient <> nil) and (Canvas <> nil) then
  begin
    if fParentColor then
      Canvas.Brush.Color := Parent.Brush.Color
    else
      Canvas.Brush.Color := fbgColor;
    Canvas.FillRect(rect(0, 0, width, height));
    case fMarkPosition of
      mpLeft: Canvas.Draw(fMarkOffset, fOffset, fGradient);
      mpRight: Canvas.Draw(fOffset, fOffset, fGradient);
      mpTop: Canvas.Draw(fOffset, fMarkOffset, fGradient);
      mpBottom: Canvas.Draw(fOffset, fOffset, fGradient);
    end;

    {case fMarkPosition of
      mpLeft: begin
        m1 := fMarkOffset;
        m2 := fOffset;
      end;
      mpRight: begin
        m1 := fOffset;
        m2 := fMarkOffset;
      end;
      mpTop: begin
        m1 := fMarkOffset;
        m2 := fOffset;
      end;
      mpBottom: begin
        m1 := fOffset;
        m2 := fMarkOffset;
      end;
    end;

    if ord(fMarkPosition) < 2 then
    begin
      w := width - fOffset - fMarkOffset;
      h := height - 2 * fOffset;
      for i := 0 to h do
      begin
        Canvas.Pen.Color := GetGradientProgress(fStartColor,fStopColor, i / h);
        Canvas.MoveTo(m1, i + fOffset);
        Canvas.LineTo(width - m2, i + fOffset);
      end;
    end
    else
    begin
      w := width - 2 * fOffset;
      h := height - fOffset - fMarkOffset;
      for i := 0 to w do
      begin
        Canvas.Pen.Color := GetGradientProgress(fStartColor,fStopColor,i / w);
        Canvas.MoveTo(i + fOffset, m1);
        Canvas.LineTo(i + fOffset, height - m2 );
      end;
    end;}


    DrawMark(fPosition, fOffset, fMarkPosition);
  end;
end;

procedure TColorBar.Resize;
begin
  if not updateEnabled then
    exit;
  GenBitmap;
  invalidate;
  inherited;
end;

procedure TColorBar.SetColor(Index: Integer; Value: TColor);
begin
  case Index of
  0: begin
    if Value <> fStartColor then
    begin
      fStartColor := Value;
      GenBitmap;
      fSelectedColor := GetGradientProgress(fStartColor, fStopColor, position / fLimit);
      invalidate;
    end;
  end;
  1: begin
    if Value <> fStopColor then
    begin
      fStopColor := Value;
      GenBitmap;
      fSelectedColor := GetGradientProgress(fStartColor, fStopColor, position / fLimit);
      invalidate;
    end;
  end;
  2: begin
    if Value <> fbgColor then
    begin
      fbgColor := Value;
      fParentColor := false;
      invalidate;
    end;
  end;
  end;
end;

procedure TColorBar.SetLimit(Value: Word);
var
  w: word;
begin
  if Value <> fLimit then
  begin
    fLimit := Value;
    w := fPosition;
    Limit(w, 0, fLimit);
    Position := w;
  end;
end;

procedure TColorBar.SetMarkOffset(Value: INteger);
begin
  if Value <> fMarkOffset then
  begin
    fMarkOffset := value;
    GenBitmap;
    invalidate;
  end;
end;

procedure TColorBar.SetMarkPosition(Value: TMarkPosition);
begin
  if Value <> fMarkPosition then
  begin
    if (ord(Value) < 2) and (fOrientation = toVertical) then
    begin
      fMarkPosition := Value;
      invalidate;
    end
    else if (ord(Value) > 1) and (fOrientation = toHorizontal) then
    begin
      fMarkPosition := Value;
      invalidate;
    end;
  end;
end;

procedure TColorBar.SetOffset(Value: Integer);
begin
  if Value <> fOffset then
  begin
    fOffset := Value;
    GenBitmap;
    Invalidate;
  end;
end;

procedure TColorBar.SetOrientation(Value: TOrientation);
begin
  if Value <> fOrientation then
  begin
    fOrientation := Value;
    if fOrientation = toHorizontal then
      fMarkPosition := mpBottom
    else
      fMarkPosition := mpRight;
    GenBitmap;
    Invalidate;
  end;
end;

procedure TColorBar.SetParentColor(Value: Boolean);
begin
  if Value <> fParentColor then
  begin
    fParentColor := Value;
    if fParentColor then
    begin
      invalidate;
      fbgColor := parent.Brush.Color;
    end;
  end;
end;

procedure TColorBar.SetPosition(Value: Word);
begin
  if (Value <> fPosition) and (value <= fLimit) then
  begin
    fPosition := Value;
    fSelectedColor := GetGradientProgress(fStartColor,fStopColor,fPosition / fLimit);
    invalidate;
  end;
end;

{$ENDREGION}

{$REGION 'TFlatButton'}

procedure TFlatButton.Click;
begin
  if fCanCheck then
    fChecked := not fChecked;

  inherited;
  invalidate;
end;

procedure TFlatButton.CMMouseLeave(var Message: TMessage);
begin
  ButtonState := bsIdle;
  repaint;
  inherited;
end;

procedure TFlatButton.CMTextChanged(var Message: TMessage);
begin
  invalidate;
end;

procedure TFlatButton.ColorChanged(Sender: TObject);
begin
  invalidate;
end;

constructor TFlatButton.Create(AOwner: TComponent);
begin
  inherited;
  ButtonState := bsIdle;
  fIdleColor := TRectColor.Create(clBlack);
  fHoverColor := TRectColor.Create(clGray);
  fClickColor := TRectColor.Create(clSilver);
  fIdleColor.OnChange := ColorChanged;
  fHoverColor.OnChange := ColorChanged;
  fClickColor.OnChange := ColorChanged;
  fBitmap := TBitmap.Create;
  fBitmap.OnChange := ColorChanged;
  fTextOffset := 0;
  fPicOffset := 0;
end;

destructor TFlatButton.Destroy;
begin
  fIdleColor.Free;
  fHoverColor.Free;
  fClickColor.Free;
  inherited;
end;

procedure TFlatButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Button = mbLeft then
  begin
    ButtonState := bsClick;
    Repaint;
  end;
  inherited;
end;

procedure TFlatButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if ButtonState = bsIdle then
  begin
    ButtonState := bsHover;
    Repaint;
  end;
  inherited;
end;

procedure TFlatButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if (ButtonState <> bsIdle) and (Button = mbLeft) then
  begin
    if PtInRect(ClientRect, Point(x, y)) then
      ButtonState := bsHover
    else
      ButtonState := bsIdle;
    Repaint;
  end;
  inherited;
end;

procedure TFlatButton.Paint;
begin
  inherited;
  case ButtonState of
    bsIdle: begin
      if (fCanCheck) and (fChecked) then
      begin
        Canvas.Brush.Color := fHoverColor.Brush;
        Canvas.Pen.Color := fHoverColor.Pen;
      end
      else
      begin
        Canvas.Brush.Color := fIdleColor.Brush;
        Canvas.Pen.Color := fIdleColor.Pen;
      end;
    end;
    bsHover: begin
      Canvas.Brush.Color := fHoverColor.Brush;
      Canvas.Pen.Color := fHoverColor.Pen;
    end;
    bsClick: begin
      Canvas.Brush.Color := fClickColor.Brush;
      Canvas.Pen.Color := fClickColor.Pen;
    end;
  end;



  Canvas.Rectangle(ClientRect);

  if not fBitmap.Empty then
  begin
    fBitmap.Transparent := true;
    fBitmap.TransparentMode := tmAuto;
    Canvas.Draw((width - fBitmap.Width) div 2, (Height - fBitmap.Height) div 2 + fPicOffset, fBitmap);
  end;

  Canvas.Brush.Style := bsClear;
  Canvas.Font := Font;
  Canvas.TextOut((Width - Canvas.TextWidth(Caption)) div 2, (Height - Canvas.TextHeight(Caption)) div 2 + fTextOffset, Caption);
end;

procedure TFlatButton.SetBitmap(Value: TBitmap);
begin
  fBitmap.Assign(Value);
end;

procedure TFlatButton.SetCanCheck(Value: Boolean);
begin
  if Value <> fCanCheck then
  begin
    fCanCheck := Value;
    invalidate;
  end;
end;

procedure TFlatButton.SetChecked(Value: Boolean);
begin
  if Value <> fChecked then
  begin
    fChecked := Value;
    invalidate;
  end;
end;

procedure TFlatButton.SetColor(Index: Integer; Value: TRectColor);
begin
  case Index of
  0: begin
    fIdleColor.Assign(Value);
  end;
  1: begin
    fHoverColor.assign(Value);
  end;
  2: begin
    fClickColor.assign(Value);
  end;
  end;
  invalidate;
end;

procedure TFlatButton.SetOffset(Index: Integer; Value: INteger);
begin
  case Index of
  0: begin
    if Value <> fTextOffset then
    begin
      fTextOffset := Value;
    end;
  end;
  1: begin
    if Value <> fPicOffset then
    begin
      fPicOffset := Value;
    end;
  end;
  end;
  invalidate;
end;

{$ENDREGION}

{$REGION 'TRectColor'}

constructor TRectColor.Create(BrushColor, PenColor: TColor);
begin
  fBrush := BrushColor;
  fPen := PenColor;
end;

procedure TRectColor.SetColor(Index: Integer; Value: TColor);
begin
  case Index of
  0: fBrush := Value;
  1: fPen := Value;
  end;
  if Assigned(fNotifyEvent) then
    fNotifyEvent(Self);
end;

constructor TRectColor.Create(AColor: TColor);
begin
  fBrush := AColor;
  fPen := AColor;
end;

{$ENDREGION}

{$REGION 'TColorDifference'}

constructor TColorDifference.Create(AOwner: TComponent);
begin
  inherited;
  fColorReference := clBlack;
  fColorCompare := clBlack;
  fOrientation := toHorizontal;
end;

procedure TColorDifference.Paint;
begin
  inherited;
  Canvas.Brush.Color := fColorReference;
  if fOrientation = toHorizontal then
    Canvas.FillRect(Rect(0, 0, Width - 1, (Height - 1) div 2))
  else
    Canvas.FillRect(Rect(0, 0, (width - 1) div 2, Height - 1));

  canvas.Brush.Color := fColorCompare;
  if fOrientation = toHorizontal then
    Canvas.FillRect(Rect(0,(Height - 1) div 2, Width - 1, height - 1))
  else
    Canvas.FillRect(Rect((Width - 1) div 2, 0, width - 1, height - 1));

  Canvas.Brush.Color := fBorderColor;
  Canvas.FrameRect(ClientRect);
end;

procedure TColorDifference.SetColor(Index: integer; Value: TColor);
begin
  case Index of
  0: begin
    if Value <> fColorReference then
      fColorReference := Value;
  end;
  1: begin
    if Value <> fColorCompare then
      fColorCompare := Value;
  end;
  2: begin
    if Value <> fBorderColor then
      fBorderColor := Value;
  end;
  end;
  Invalidate;
end;

procedure TColorDifference.SetOrientation(Value: TOrientation);
begin
  if Value <> fOrientation then
  begin
    fOrientation := Value;
    invalidate;
  end;
end;

{$ENDREGION}

{$REGION 'TRGBWColor'}

class operator TRGBWColor.Equal(A, B: TRGBWColor): Boolean;
begin
  Result := (A.R = B.R) and (A.G = B.G) and (A.B = B.B) and (A.W = B.W);
end;

class operator TRGBWColor.Explicit(A: TRGBWColor): TRGBColor;
begin
  Result.R := A.R;
  Result.G := A.G;
  Result.B := A.B;
end;

class operator TRGBWColor.Explicit(A: TRGBWColor): TColor;
begin
  Result := RGB(A.R, a.G, a.B);
end;

function TRGBWColor.GetRaw(Index: Integer): Byte;
begin
  Result := 0;
  if (Index >= Low(fRaw)) and (Index <= High(fRaw)) then
    Result := fraw[Index];
end;

class operator TRGBWColor.Implicit(A: TColor): TRGBWColor;
begin
  Result.R := GetRValue(A);
  Result.G := GetGValue(A);
  Result.B := GetBValue(A);
  Result.W := 0;
end;

class operator TRGBWColor.Implicit(A: TRGBColor): TRGBWColor;
begin
  Result.R := A.R;
  Result.G := A.G;
  Result.B := A.B;
  Result.W := 0;
end;

class operator TRGBWColor.NotEqual(A, B: TRGBWColor): Boolean;
begin
  Result := (A.R <> B.R) or (A.G <> B.G) or (A.B <> B.B) or (A.W <> B.W);
end;

procedure TRGBWColor.SetRaw(Index: Integer; Value: Byte);
begin
  if (Index >= Low(fRaw)) and (Index <= High(fRaw)) then
    fraw[Index] := Value;
end;

{$ENDREGION}

{$REGION 'TRGBColor'}

class operator TRGBColor.Equal(A, B: TRGBColor): Boolean;
begin
  Result := (A.R = B.R) and (A.G = B.G) and (A.B = B.B);
end;

function TRGBColor.GetRaw(Index: Integer): Byte;
begin
  Result := 0;
  if (Index >= Low(fRaw)) and (Index <= High(fRaw)) then
    Result := fraw[Index];
end;

class operator TRGBColor.Implicit(A: TColor): TRGBColor;
begin
  Result.R := GetRValue(A);
  Result.G := GetGValue(A);
  Result.B := GetBValue(A);
end;

class operator TRGBColor.Implicit(A: TRGBColor): TColor;
begin
  Result := RGB(A.R, a.G, a.B);
end;

class operator TRGBColor.NotEqual(A, B: TRGBColor): Boolean;
begin
  Result := (A.R <> B.R) or (A.G <> b.G) or (a.B <> b.B);
end;

procedure TRGBColor.SetRaw(Index: Integer; Value: Byte);
begin
  if (Index >= Low(fRaw)) and (Index <= High(fRaw)) then
    fraw[Index] := Value;
end;

{$ENDREGION}

end.
