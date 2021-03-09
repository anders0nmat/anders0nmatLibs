unit OpenMath;

interface

uses Math, SysUtils, Variants, StrUtils;

type
  TVec2 = record
  private

    procedure SetVec(Index: Integer; Value: Single);
    function GetVec(Index: Integer): Single;

  public

    constructor Create(x, y: Single);

    class operator Equal(A, B: TVec2): Boolean;
    class operator NotEqual(A, B: TVec2): Boolean;

    class operator Negative(A: TVec2): TVec2;

    class operator Add(A: TVec2; B: Single): TVec2;
    class operator Add(A: Single; B: TVec2): TVec2;
    class operator Add(A, B: TVec2): TVec2;

    class operator Subtract(A: TVec2; B: Single): TVec2;
    class operator Subtract(A: Single; B: TVec2): TVec2;
    class operator Subtract(A, B: TVec2): TVec2;

    class operator Multiply(A: TVec2; B: Single): TVec2;
    class operator Multiply(A: Single; B: TVec2): TVec2;
    class operator Multiply(A, B: TVec2): TVec2;

    class operator Divide(A: TVec2; B: Single): TVec2;
    class operator Divide(A: Single; B: TVec2): TVec2;
    class operator Divide(A, B: TVec2): TVec2;

    function Dot(B: TVec2): Double;
    function Cross: TVec2;
    function Length: Double;
    function LengthSqr: Double;
    function Normal: TVec2;

    property Vector[Index: Integer] : Single read GetVec write SetVec; default;

    case Byte of
    0: (x, y: Single);
    1: (r, g: Single);
    2: (u, v: Single);
    3: (raw: array[0..1] of Single);
  end;

  TVec2i = record
  private

    procedure SetVec(Index: Integer; Value: Integer);
    function GetVec(Index: Integer): Integer;

  public

    constructor Create(x, y: Integer);

    class operator Implicit(A: TVec2i): TVec2;

    class operator Explicit(A: TVec2): TVec2i;

    class operator Equal(A, B: TVec2i): Boolean;
    class operator NotEqual(A, B: TVec2i): Boolean;

    class operator Negative(A: TVec2i): TVec2i;

    class operator Add(A: TVec2i; B: Integer): TVec2i;
    class operator Add(A: Integer; B: TVec2i): TVec2i;
    class operator Add(A, B: TVec2i): TVec2i;

    class operator Subtract(A: TVec2i; B: Integer): TVec2i;
    class operator Subtract(A: Integer; B: TVec2i): TVec2i;
    class operator Subtract(A, B: TVec2i): TVec2i;

    class operator Multiply(A: TVec2i; B: Integer): TVec2i;
    class operator Multiply(A: Integer; B: TVec2i): TVec2i;
    class operator Multiply(A, B: TVec2i): TVec2i;

    class operator Divide(A: TVec2i; B: Single): TVec2;
    class operator Divide(A: Single; B: TVec2i): TVec2;
    class operator Divide(A, B: TVec2i): TVec2;

    class operator Add(A: TVec2i; B: Single): TVec2;
    class operator Add(A: Single; B: TVec2i): TVec2;

    class operator Subtract(A: TVec2i; B: Single): TVec2;
    class operator Subtract(A: Single; B: TVec2i): TVec2;

    class operator Multiply(A: TVec2i; B: Single): TVec2;
    class operator Multiply(A: Single; B: TVec2i): TVec2;

    function Dot(B: TVec2): Double;
    function Cross: TVec2i;
    function Length: Double;
    function LengthSqr: Double;
    function Normal: TVec2;

    property Vector[Index: Integer] : Integer read GetVec write SetVec; default;

    case Byte of
    0: (x, y: Integer);
    1: (r, g: Integer);
    2: (u, v: Integer);
    3: (raw: array[0..1] of Integer);
  end;

  TVec3 = record
  private

    procedure SetVec(Index: Integer; Value: Single);
    function GetVec(Index: Integer): Single;

  public

    constructor Create(x, y, z: Single);

    class operator Implicit(A: TVec2): TVec3;
    class operator Implicit(A: TVec2i): TVec3;

    class operator Explicit(A: TVec3): TVec2;
    class operator Explicit(A: TVec3): TVec2i;

    class operator Equal(A, B: TVec3): Boolean;
    class operator NotEqual(A, B: TVec3): Boolean;

    class operator Negative(A: TVec3): TVec3;

    class operator Add(A: TVec3; B: Single): TVec3;
    class operator Add(A: Single; B: TVec3): TVec3;
    class operator Add(A, B: TVec3): TVec3;

    class operator Subtract(A: TVec3; B: Single): TVec3;
    class operator Subtract(A: Single; B: TVec3): TVec3;
    class operator Subtract(A, B: TVec3): TVec3;

    class operator Multiply(A: TVec3; B: Single): TVec3;
    class operator Multiply(A: Single; B: TVec3): TVec3;
    class operator Multiply(A, B: TVec3): TVec3;

    class operator Divide(A: TVec3; B: Single): TVec3;
    class operator Divide(A: Single; B: TVec3): TVec3;
    class operator Divide(A, B: TVec3): TVec3;

    function Dot(B: TVec3): Double;
    function Cross(B: TVec3): TVec3;
    function Length: Double;
    function LengthSqr: Double;
    function Normal: TVec3;

    property Vector[Index: Integer] : Single read GetVec write SetVec; default;

    case Byte of
    0: (x, y, z: Single);
    1: (r, g, b: Single);
    2: (u, v, s: Single);
    3: (raw: array[0..2] of Single);
  end;

  TVec3i = record
  private

    procedure SetVec(Index: Integer; Value: Integer);
    function GetVec(Index: Integer): Integer;

  public

    constructor Create(x, y, z: Integer);

    class operator Implicit(A: TVec2i): TVec3i;
    class operator Implicit(A: TVec3i): TVec3;

    class operator Explicit(A: TVec3): TVec3i;
    class operator Explicit(A: TVec3i): TVec2i;
    class operator Explicit(A: TVec2): TVec3i;
    class operator Explicit(A: TVec3i): TVec2;

    class operator Equal(A, B: TVec3i): Boolean;
    class operator NotEqual(A, B: TVec3i): Boolean;

    class operator Negative(A: TVec3i): TVec3i;

    class operator Add(A: TVec3i; B: Integer): TVec3i;
    class operator Add(A: Integer; B: TVec3i): TVec3i;
    class operator Add(A, B: TVec3i): TVec3i;

    class operator Subtract(A: TVec3i; B: Integer): TVec3i;
    class operator Subtract(A: Integer; B: TVec3i): TVec3i;
    class operator Subtract(A, B: TVec3i): TVec3i;

    class operator Multiply(A: TVec3i; B: Integer): TVec3i;
    class operator Multiply(A: Integer; B: TVec3i): TVec3i;
    class operator Multiply(A, B: TVec3i): TVec3i;

    class operator Divide(A: TVec3i; B: Single): TVec3;
    class operator Divide(A: Single; B: TVec3i): TVec3;
    class operator Divide(A, B: TVec3i): TVec3;

    function Dot(B: TVec3): Double;
    function Cross(B: TVec3i): TVec3i;
    function Length: Double;
    function LengthSqr: Double;
    function Normal: TVec3;

    property Vector[Index: Integer] : Integer read GetVec write SetVec; default;

    case Byte of
    0: (x, y, z: Integer);
    1: (r, g, b: Integer);
    2: (u, v, s: Integer);
    3: (raw: array[0..2] of Integer);
  end;

  TVec4 = record
  private

    procedure SetVec(Index: Integer; Value: Single);
    function GetVec(Index: Integer): Single;

  public

    constructor Create(x, y, z, w: Single);

    class operator Implicit(A: TVec2): TVec4;
    class operator Implicit(A: TVec2i): TVec4;
    class operator Implicit(A: TVec3): TVec4;
    class operator Implicit(A: TVec3i): TVec4;

    class operator Explicit(A: TVec4): TVec2;
    class operator Explicit(A: TVec4): TVec2i;
    class operator Explicit(A: TVec4): TVec3;
    class operator Explicit(A: TVec4): TVec3i;

    class operator Equal(A, B: TVec4): Boolean;
    class operator NotEqual(A, B: TVec4): Boolean;

    class operator Negative(A: TVec4): TVec4;

    class operator Add(A: TVec4; B: Single): TVec4;
    class operator Add(A: Single; B: TVec4): TVec4;
    class operator Add(A, B: TVec4): TVec4;

    class operator Subtract(A: TVec4; B: Single): TVec4;
    class operator Subtract(A: Single; B: TVec4): TVec4;
    class operator Subtract(A, B: TVec4): TVec4;

    class operator Multiply(A: TVec4; B: Single): TVec4;
    class operator Multiply(A: Single; B: TVec4): TVec4;
    class operator Multiply(A, B: TVec4): TVec4;

    class operator Divide(A: TVec4; B: Single): TVec4;
    class operator Divide(A: Single; B: TVec4): TVec4;
    class operator Divide(A, B: TVec4): TVec4;

    property Vector[Index: Integer] : Single read GetVec write SetVec; default;

    case Byte of
    0: (x, y, z, w: Single);
    1: (r, g, b, a: Single);
    2: (u, v, s, t: Single);
    3: (raw: array[0..3] of Single);
  end;

  TVec4i = record
  private

    procedure SetVec(Index: Integer; Value: Integer);
    function GetVec(Index: Integer): Integer;

  public

    constructor Create(x, y, z, w: Integer);

    class operator Implicit(A: TVec2i): TVec4i;
    class operator Implicit(A: TVec3i): TVec4i;
    class operator Implicit(A: TVec4i): TVec4;

    class operator Explicit(A: TVec4i): TVec2i;
    class operator Explicit(A: TVec4i): TVec3i;
    class operator Explicit(A: TVec4i): TVec3;
    class operator Explicit(A: TVec4i): TVec2;
    class operator Explicit(A: TVec2): TVec4i;
    class operator Explicit(A: TVec3): TVec4i;
    class operator Explicit(A: TVec4): TVec4i;

    class operator Equal(A, B: TVec4i): Boolean;
    class operator NotEqual(A, B: TVec4i): Boolean;

    class operator Negative(A: TVec4i): TVec4i;

    class operator Add(A: TVec4i; B: Integer): TVec4i;
    class operator Add(A: Integer; B: TVec4i): TVec4i;
    class operator Add(A, B: TVec4i): TVec4i;

    class operator Subtract(A: TVec4i; B: Integer): TVec4i;
    class operator Subtract(A: Integer; B: TVec4i): TVec4i;
    class operator Subtract(A, B: TVec4i): TVec4i;

    class operator Multiply(A: TVec4i; B: Integer): TVec4i;
    class operator Multiply(A: Integer; B: TVec4i): TVec4i;
    class operator Multiply(A, B: TVec4i): TVec4i;

    class operator Divide(A: TVec4i; B: Single): TVec4;
    class operator Divide(A: Single; B: TVec4i): TVec4;
    class operator Divide(A, B: TVec4i): TVec4;

    property Vector[Index: Integer] : Integer read GetVec write SetVec; default;

    case Byte of
    0: (x, y, z, w: Integer);
    1: (r, g, b, a: Integer);
    2: (u, v, s, t: Integer);
    3: (raw: array[0..3] of Integer);
  end;

  TMat4 = record
  private

    procedure SetMat(Column, Row: Integer; Value: Single);
    function GetMat(Column, Row: Integer): Single;

  public

    constructor Create(x, y, z, w: TVec4); overload;
    constructor Create(Am11, Am21, Am31, Am41,
                       Am12, Am22, Am32, Am42,
                       Am13, Am23, Am33, Am43,
                       Am14, Am24, Am34, Am44: Single); overload;

    class function Ortho(Left, Right, Bottom, Top, zNear, zFar: Single): TMat4; static;
    class function Perspective(AngleYDeg, Ratio, zNear, zFar: Single): TMat4; static;
    class function LookAt(Pos, Target, Up: TVec3): TMat4; static;

    class operator Equal(A, B: TMat4): Boolean;
    class operator NotEqual(A, B: TMat4): Boolean;

    class operator Add(A: TMat4; B: Single): TMat4;
    class operator Add(A: Single; B: TMat4): TMat4;
    class operator Add(A, B: TMat4): TMat4;

    class operator Subtract(A: TMat4; B: Single): TMat4;
    class operator Subtract(A: Single; B: TMat4): TMat4;
    class operator Subtract(A, B: TMat4): TMat4;

    class operator Multiply(A: TMat4; B: Single): TMat4;
    class operator Multiply(A: Single; B: TMat4): TMat4;
    class operator Multiply(A, B: TMat4): TMat4;

    class operator Divide(A: TMat4; B: Single): TMat4;
    class operator Divide(A: Single; B: TMat4): TMat4;
    class operator Divide(A, B: TMat4): TMat4;

    function Translate(x, y, z: Single): TMat4; overload;
    function Translate(vec: TVec3): TMat4; overload;

    function Rotate(AngleDEG: Single; x, y, z: Single): TMat4; overload;
    function Rotate(AngleDEG: Single; vec: TVec3): TMat4; overload;

    function Scale(x, y, z: Single): TMat4; overload;
    function Scale(Vec: TVec3): TMat4; overload;
    function Scale(Factor: Single): TMat4; overload;

    function GetPointer: Pointer;

    property Matrix[Column, Row: Integer] : Single read GetMat write SetMat; default;

    case Byte of
    0: (vec: array[0..3] of TVec4);
    1: (m11, m21, m31, m41,
        m12, m22, m32, m42,
        m13, m23, m33, m43,
        m14, m24, m34, m44: Single);
    2: (raw: array[0..15] of Single);
    // First Column then Row (Meaning [1, 2] goes to ( 0  0  0  0 )
    //                                               ( 0  0  0  0 )
    //                                               ( 0 [0] 0  0 )
    //                                               ( 0  0  0  0 )
    3: (mat: array[0..3, 0..3] of Single);
  end;

  TVec = record  // Wrapper for advanced vector operations
    class function Dot(A, B: TVec2): Double; overload; static;
    class function Dot(A, B: TVec3): Double; overload; static;

    class function Cross(A, B: TVec2): TVec2; overload; static;
    class function Cross(A, B: TVec3): TVec3; overload; static;

    class function Normalize(A: TVec2): TVec2; overload; static;
    class function Normalize(A: TVec3): TVec3; overload; static;

    class function VecInCube(Vec, A, B: TVec3): Boolean; static;
  end;

  TMat = record
    class function Mat434(A: TMat4): TMat4; static;
  end;

//---------------- TO BE CONTINUED ----------------\\

function vec2(x, y: Single): TVec2; overload;
function vec2(Value: Single): TVec2; overload;

function vec3(x, y, z: Single): TVec3; overload;
function vec3(Value: Single): TVec3; overload;

function vec4(x, y, z, w: Single): TVec4;

function vec2i(x, y: Integer): TVec2i;

function vec3i(x, y, z: Integer): TVec3i;

function vec4i(x, y, z, w: Integer): TVec4i; overload;
function vec4i(Value: Integer): TVec4i; overload;


function StrToVec2(Str: String; Default: Single = 0; Delimiter: Char = ' '): TVec2; overload;
function StrToVec2(Str: String; const AFormatSettings: TFormatSettings; Default: Single = 0; Delimiter: Char = ' '): TVec2; overload;
function StrToVec3(Str: String; Default: Single = 0; Delimiter: Char = ' '): TVec3; overload;
function StrToVec3(Str: String; const AFormatSettings: TFormatSettings; Default: Single = 0; Delimiter: Char = ' '): TVec3; overload;
function StrToVec4i(Str: String; Default: Integer = 0; Delimiter: Char = ' '): TVec4i;


function Ortho(Left, Right, Bottom, Top: Single): TMat4;
function Perspective(AngleYDeg, Ratio, zNear, zFar: Single): TMat4;
function LookAt(Pos, Target, Up: TVec3): TMat4;

const
  IdentityMat: TMat4 = (raw : (1, 0, 0, 0,
                               0, 1, 0, 0,
                               0, 0, 1, 0,
                               0, 0, 0, 1));
  EmptyMat: TMat4 = (raw : (0, 0, 0, 0,
                            0, 0, 0, 0,
                            0, 0, 0, 0,
                            0, 0, 0, 0));

implementation

{$REGION 'TVec2'}

class operator TVec2.Add(A, B: TVec2): TVec2;
begin
  Result.x := A.x + B.x;
  Result.y := A.y + B.y;
end;

function TVec2.GetVec(Index: Integer): Single;
begin
  if (Index > -1) and (Index < 4) then
  Result := raw[Index]
  else
  raise Exception.Create('Reading out of Range');
end;

procedure TVec2.SetVec(Index: Integer; Value: Single);
begin
  if (Index > -1) and (Index < 4) then
  raw[Index] := Value
  else
  raise Exception.Create('Reading out of Range');
end;

class operator TVec2.Add(A: Single; B: TVec2): TVec2;
begin
  Result.x := A + B.x;
  Result.y := A + B.y;
end;

class operator TVec2.Add(A: TVec2; B: Single): TVec2;
begin
  Result.x := A.x + B;
  Result.y := A.y + B;
end;

constructor TVec2.Create(x, y: Single);
begin
  raw[0] := x;
  raw[1] := y;
end;

function TVec2.Cross: TVec2;
begin
  Result.x := y;
  Result.y := -x;
end;

class operator TVec2.Divide(A: TVec2; B: Single): TVec2;
begin
  Result.x := A.x / B;
  Result.y := A.y / B;
end;

class operator TVec2.Divide(A: Single; B: TVec2): TVec2;
begin
  Result.x := A / B.x;
  Result.y := A / B.y;
end;

class operator TVec2.Divide(A, B: TVec2): TVec2;
begin
  Result.x := A.x / B.x;
  Result.y := A.y / B.y;
end;

function TVec2.Dot(B: TVec2): Double;
begin
  Result := (x * B.x) + (y + B.y);
end;

class operator TVec2.Equal(A, B: TVec2): Boolean;
begin
  Result := (SameValue(A.x, B.x)) and (SameValue(A.y, B.y));
end;

function TVec2.Length: Double;
begin
  Result := sqrt(sqr(x) + sqr(y));
end;

function TVec2.LengthSqr: Double;
begin
  Result := sqr(x) + sqr(y);
end;

class operator TVec2.Multiply(A, B: TVec2): TVec2;
begin
  Result.x := A.x * B.x;
  Result.y := A.y * B.y;
end;

class operator TVec2.Multiply(A: TVec2; B: Single): TVec2;
begin
  Result.x := A.x * B;
  Result.y := A.y * B;
end;

class operator TVec2.Multiply(A: Single; B: TVec2): TVec2;
begin
  Result.x := A * B.x;
  Result.y := A * B.y;
end;

class operator TVec2.Negative(A: TVec2): TVec2;
begin
  Result.x := -A.x;
  Result.y := -A.y;
end;

function TVec2.Normal: TVec2;
var
  d: Double;
begin
  d := Length;
  if d = 0 then
  exit;
  Result := Self / Length;
end;

class operator TVec2.NotEqual(A, B: TVec2): Boolean;
begin
  Result := not ((SameValue(A.x, B.x)) and (SameValue(A.y, B.y)));
end;

class operator TVec2.Subtract(A: TVec2; B: Single): TVec2;
begin
  Result.x := A.x - B;
  Result.y := A.y - B;
end;

class operator TVec2.Subtract(A: Single; B: TVec2): TVec2;
begin
  Result.x := A - B.x;
  Result.y := A - B.y;
end;

class operator TVec2.Subtract(A, B: TVec2): TVec2;
begin
  Result.x := A.x - B.x;
  Result.y := A.y - B.y;
end;

{$ENDREGION}

{$REGION 'TVec2i'}

class operator TVec2i.Add(A, B: TVec2i): TVec2i;
begin
  Result.x := A.x + B.x;
  Result.y := A.y + B.y;
end;

function TVec2i.GetVec(Index: Integer): Integer;
begin
  if (Index > -1) and (Index < 2) then
  Result := raw[Index]
  else
  raise Exception.Create('Reading out of Range');
end;

procedure TVec2i.SetVec(Index, Value: Integer);
begin
  if (Index > -1) and (Index < 2) then
  raw[Index] := Value
  else
  raise Exception.Create('Reading out of Range');
end;

class operator TVec2i.Add(A: Integer; B: TVec2i): TVec2i;
begin
  Result.x := A + B.x;
  Result.y := A + B.y;
end;

class operator TVec2i.Add(A: TVec2i; B: Integer): TVec2i;
begin
  Result.x := A.x + B;
  Result.y := A.y + B;
end;

class operator TVec2i.Add(A: Single; B: TVec2i): TVec2;
begin
  Result.x := A + B.x;
  Result.y := A + B.y;
end;

class operator TVec2i.Add(A: TVec2i; B: Single): TVec2;
begin
  Result.x := A.x + B;
  Result.y := A.y + B;
end;

constructor TVec2i.Create(x, y: Integer);
begin
  raw[0] := x;
  raw[1] := y;
end;

function TVec2i.Cross: TVec2i;
begin
  Result.x := y;
  Result.y := -x;
end;

class operator TVec2i.Divide(A: TVec2i; B: Single): TVec2;
begin
  Result.x := A.x / B;
  Result.y := A.y / B;
end;

class operator TVec2i.Divide(A: Single; B: TVec2i): TVec2;
begin
  Result.x := A / B.x;
  Result.y := A / B.y;
end;

class operator TVec2i.Divide(A, B: TVec2i): TVec2;
begin
  Result.x := A.x / B.x;
  Result.y := A.y / B.y;
end;

function TVec2i.Dot(B: TVec2): Double;
begin
  Result := (x * B.x) + (y + B.y);
end;

class operator TVec2i.Equal(A, B: TVec2i): Boolean;
begin
  Result := (SameValue(A.x, B.x)) and (SameValue(A.y, B.y));
end;

class operator TVec2i.Explicit(A: TVec2): TVec2i;
begin
  Result.x := trunc(A.x);
  Result.y := trunc(A.y);
end;

class operator TVec2i.Implicit(A: TVec2i): TVec2;
begin
  Result.x := A.x;
  Result.y := A.y;
end;

function TVec2i.Length: Double;
begin
  Result := sqrt(sqr(x) + sqr(y));
end;

function TVec2i.LengthSqr: Double;
begin
  Result := sqr(x) + sqr(y);
end;

class operator TVec2i.Multiply(A, B: TVec2i): TVec2i;
begin
  Result.x := A.x * B.x;
  Result.y := A.y * B.y;
end;

class operator TVec2i.Multiply(A: TVec2i; B: Integer): TVec2i;
begin
  Result.x := A.x * B;
  Result.y := A.y * B;
end;

class operator TVec2i.Multiply(A: Integer; B: TVec2i): TVec2i;
begin
  Result.x := A * B.x;
  Result.y := A * B.y;
end;

class operator TVec2i.Multiply(A: TVec2i; B: Single): TVec2;
begin
  Result.x := A.x * B;
  Result.y := A.y * B;
end;

class operator TVec2i.Multiply(A: Single; B: TVec2i): TVec2;
begin
  Result.x := A * B.x;
  Result.y := A * B.y;
end;

class operator TVec2i.Negative(A: TVec2i): TVec2i;
begin
  Result.x := -A.x;
  Result.y := -A.y;
end;

function TVec2i.Normal: TVec2;
var
  d: Double;
begin
  d := Length;
  if d = 0 then
  exit;
  Result := Self / Length;
end;

class operator TVec2i.NotEqual(A, B: TVec2i): Boolean;
begin
  Result := not ((SameValue(A.x, B.x)) and (SameValue(A.y, B.y)));
end;

class operator TVec2i.Subtract(A: TVec2i; B: Integer): TVec2i;
begin
  Result.x := A.x - B;
  Result.y := A.y - B;
end;

class operator TVec2i.Subtract(A: Integer; B: TVec2i): TVec2i;
begin
  Result.x := A - B.x;
  Result.y := A - B.y;
end;

class operator TVec2i.Subtract(A: TVec2i; B: Single): TVec2;
begin
  Result.x := A.x - B;
  Result.y := A.y - B;
end;

class operator TVec2i.Subtract(A: Single; B: TVec2i): TVec2;
begin
  Result.x := A - B.x;
  Result.y := A - B.y;
end;

class operator TVec2i.Subtract(A, B: TVec2i): TVec2i;
begin
  Result.x := A.x - B.x;
  Result.y := A.y - B.y;
end;

{$ENDREGION}

{$REGION 'TVec3'}

class operator TVec3.Add(A, B: TVec3): TVec3;
begin
  Result.x := A.x + B.x;
  Result.y := A.y + B.y;
  Result.z := A.z + B.z;
end;

function TVec3.GetVec(Index: Integer): Single;
begin
  if (Index > -1) and (Index < 4) then
  Result := raw[Index]
  else
  raise Exception.Create('Reading out of Range');
end;

procedure TVec3.SetVec(Index: Integer; Value: Single);
begin
  if (Index > -1) and (Index < 4) then
  raw[Index] := Value
  else
  raise Exception.Create('Reading out of Range');
end;

class operator TVec3.Add(A: Single; B: TVec3): TVec3;
begin
  Result.x := A + B.x;
  Result.y := A + B.y;
  Result.z := A + B.z;
end;

class operator TVec3.Add(A: TVec3; B: Single): TVec3;
begin
  Result.x := A.x + B;
  Result.y := A.y + B;
  Result.z := A.z + B;
end;

constructor TVec3.Create(x, y, z: Single);
begin
  raw[0] := x;
  raw[1] := y;
  raw[2] := z;
end;

function TVec3.Cross(B: TVec3): TVec3;
begin
  Result.x := (y * B.z) - (z * B.y);
  Result.y := (z * B.x) - (x * B.z);
  Result.z := (x * B.y) - (y * B.x);
end;

class operator TVec3.Divide(A: TVec3; B: Single): TVec3;
begin
  Result.x := A.x / B;
  Result.y := A.y / B;
  Result.z := A.z / B;
end;

class operator TVec3.Divide(A: Single; B: TVec3): TVec3;
begin
  Result.x := A / B.x;
  Result.y := A / B.y;
  Result.z := A / B.z;
end;

class operator TVec3.Divide(A, B: TVec3): TVec3;
begin
  Result.x := A.x / B.x;
  Result.y := A.y / B.y;
  Result.z := A.z / B.z;
end;

function TVec3.Dot(B: TVec3): Double;
begin
  Result := (x * B.x) + (y * B.y) + (z * B.z);
end;

class operator TVec3.Equal(A, B: TVec3): Boolean;
begin
  Result := SameValue(A.x, B.x) and SameValue(A.y, B.y) and SameValue(A.z, B.z);
end;

class operator TVec3.Explicit(A: TVec3): TVec2i;
begin
  Result.x := trunc(A.x);
  Result.y := trunc(A.y);
end;

class operator TVec3.Explicit(A: TVec3): TVec2;
begin
  Result.x := A.x;
  Result.y := A.y;
end;

class operator TVec3.Implicit(A: TVec2i): TVec3;
begin
  Result.x := A.x;
  Result.y := A.y;
  Result.z := 0;
end;

class operator TVec3.Implicit(A: TVec2): TVec3;
begin
  Result.x := A.x;
  Result.y := A.y;
  Result.z := 0;
end;

function TVec3.Length: Double;
begin
  Result := sqrt(sqr(x) + sqr(y) + sqr(z));
end;

function TVec3.LengthSqr: Double;
begin
  Result := sqr(x) + sqr(y) + sqr(z);
end;

class operator TVec3.Multiply(A: Single; B: TVec3): TVec3;
begin
  Result.x := A * B.x;
  Result.y := A * B.y;
  Result.z := A * B.z;
end;

class operator TVec3.Multiply(A: TVec3; B: Single): TVec3;
begin
  Result.x := A.x * B;
  Result.y := A.y * B;
  Result.z := A.z * B;
end;

class operator TVec3.Multiply(A, B: TVec3): TVec3;
begin
  Result.x := A.x * B.x;
  Result.y := A.y * B.y;
  Result.z := A.z * B.z;
end;

class operator TVec3.Negative(A: TVec3): TVec3;
begin
  Result.x := -A.x;
  Result.y := -A.y;
  Result.z := -A.z;
end;

function TVec3.Normal: TVec3;
var
  d: Double;
begin
  d := Length;
  if d = 0 then
    exit;
  Result := Self / Length;
end;

class operator TVec3.NotEqual(A, B: TVec3): Boolean;
begin
  Result := not (SameValue(A.x, B.x) and SameValue(A.y, B.y) and SameValue(A.z, B.z));
end;

class operator TVec3.Subtract(A: TVec3; B: Single): TVec3;
begin
  Result.x := A.x - B;
  Result.y := A.y - B;
  Result.z := A.z - B;
end;

class operator TVec3.Subtract(A: Single; B: TVec3): TVec3;
begin
  Result.x := A - B.x;
  Result.y := A - B.y;
  Result.z := A - B.z;
end;

class operator TVec3.Subtract(A, B: TVec3): TVec3;
begin
  Result.x := A.x - B.x;
  Result.y := A.y - B.y;
  Result.z := A.z - B.z;
end;

{$ENDREGION}

{$REGION 'TVec3i'}

class operator TVec3i.Add(A, B: TVec3i): TVec3i;
begin
  Result.x := A.x + B.x;
  Result.y := A.y + B.y;
  Result.z := A.z + B.z;
end;

function TVec3i.GetVec(Index: Integer): Integer;
begin
  if (Index > -1) and (Index < 3) then
  Result := raw[Index]
  else
  raise Exception.Create('Reading out of Range');
end;

procedure TVec3i.SetVec(Index, Value: Integer);
begin
  if (Index > -1) and (Index < 3) then
  raw[Index] := Value
  else
  raise Exception.Create('Reading out of Range');
end;

class operator TVec3i.Add(A: Integer; B: TVec3i): TVec3i;
begin
  Result.x := A + B.x;
  Result.y := A + B.y;
  Result.z := A + B.z;
end;

class operator TVec3i.Add(A: TVec3i; B: Integer): TVec3i;
begin
  Result.x := A.x + B;
  Result.y := A.y + B;
  Result.z := A.z + B;
end;

constructor TVec3i.Create(x, y, z: Integer);
begin
  raw[0] := x;
  raw[1] := y;
  raw[2] := z;
end;

function TVec3i.Cross(B: TVec3i): TVec3i;
begin
  Result.x := (y * B.z) - (z * B.y);
  Result.y := (z * B.x) - (x * B.z);
  Result.z := (x * B.y) - (y * B.x);
end;

class operator TVec3i.Divide(A: TVec3i; B: Single): TVec3;
begin
  Result.x := A.x / B;
  Result.y := A.y / B;
  Result.z := A.z / B;
end;

class operator TVec3i.Divide(A: Single; B: TVec3i): TVec3;
begin
  Result.x := A / B.x;
  Result.y := A / B.y;
  Result.z := A / B.z;
end;

class operator TVec3i.Divide(A, B: TVec3i): TVec3;
begin
  Result.x := A.x / B.x;
  Result.y := A.y / B.y;
  Result.z := A.z / B.z;
end;

function TVec3i.Dot(B: TVec3): Double;
begin
  Result := (x * B.x) + (y * B.y) + (z * B.z);
end;

class operator TVec3i.Equal(A, B: TVec3i): Boolean;
begin
  Result := SameValue(A.x, B.x) and SameValue(A.y, B.y) and SameValue(A.z, B.z);
end;

class operator TVec3i.Explicit(A: TVec3): TVec3i;
begin
  Result.x := trunc(A.x);
  Result.y := trunc(A.y);
  Result.z := trunc(A.z);
end;

class operator TVec3i.Explicit(A: TVec3i): TVec2i;
begin
  Result.x := A.x;
  Result.y := A.y;
end;

class operator TVec3i.Explicit(A: TVec2): TVec3i;
begin
  Result.x := trunc(A.x);
  Result.y := trunc(A.y);
  Result.z := 0;
end;

class operator TVec3i.Explicit(A: TVec3i): TVec2;
begin
  Result.x := A.x;
  Result.y := A.y;
end;

class operator TVec3i.Implicit(A: TVec2i): TVec3i;
begin
  Result.x := A.x;
  Result.y := A.y;
  Result.z := 0;
end;

class operator TVec3i.Implicit(A: TVec3i): TVec3;
begin
  Result.x := A.x;
  Result.y := A.y;
  Result.z := A.z;
end;

function TVec3i.Length: Double;
begin
  Result := sqrt(sqr(x) + sqr(y) + sqr(z));
end;

function TVec3i.LengthSqr: Double;
begin
  Result := sqr(x) + sqr(y) + sqr(z);
end;

class operator TVec3i.Multiply(A: Integer; B: TVec3i): TVec3i;
begin
  Result.x := A * B.x;
  Result.y := A * B.y;
  Result.z := A * B.z;
end;

class operator TVec3i.Multiply(A: TVec3i; B: Integer): TVec3i;
begin
  Result.x := A.x * B;
  Result.y := A.y * B;
  Result.z := A.z * B;
end;

class operator TVec3i.Multiply(A, B: TVec3i): TVec3i;
begin
  Result.x := A.x * B.x;
  Result.y := A.y * B.y;
  Result.z := A.z * B.z;
end;

class operator TVec3i.Negative(A: TVec3i): TVec3i;
begin
  Result.x := -A.x;
  Result.y := -A.y;
  Result.z := -A.z;
end;

function TVec3i.Normal: TVec3;
var
  d: Double;
begin
  d := Length;
  if d = 0 then
  exit;
  Result := Self / Length;
end;

class operator TVec3i.NotEqual(A, B: TVec3i): Boolean;
begin
  Result := not (SameValue(A.x, B.x) and SameValue(A.y, B.y) and SameValue(A.z, B.z));
end;

class operator TVec3i.Subtract(A: TVec3i; B: Integer): TVec3i;
begin
  Result.x := A.x - B;
  Result.y := A.y - B;
  Result.z := A.z - B;
end;

class operator TVec3i.Subtract(A: Integer; B: TVec3i): TVec3i;
begin
  Result.x := A - B.x;
  Result.y := A - B.y;
  Result.z := A - B.z;
end;

class operator TVec3i.Subtract(A, B: TVec3i): TVec3i;
begin
  Result.x := A.x - B.x;
  Result.y := A.y - B.y;
  Result.z := A.z - B.z;
end;

{$ENDREGION}

{$REGION 'TVec4'}

class operator TVec4.Add(A, B: TVec4): TVec4;
begin
  Result.x := A.x + B.x;
  Result.y := A.y + B.y;
  Result.z := A.z + B.z;
  Result.w := A.w + B.w;
end;

function TVec4.GetVec(Index: Integer): Single;
begin
  if (Index > -1) and (Index < 4) then
  Result := raw[Index]
  else
  raise Exception.Create('Reading out of Range');
end;

procedure TVec4.SetVec(Index: Integer; Value: Single);
begin
  if (Index > -1) and (Index < 4) then
  raw[Index] := Value
  else
  raise Exception.Create('Reading out of Range');
end;

class operator TVec4.Add(A: Single; B: TVec4): TVec4;
begin
  Result.x := A + B.x;
  Result.y := A + B.y;
  Result.z := A + B.z;
  Result.w := A + B.w;
end;

class operator TVec4.Add(A: TVec4; B: Single): TVec4;
begin
  Result.x := A.x + B;
  Result.y := A.y + B;
  Result.z := A.z + B;
  Result.w := A.w + B;
end;

constructor TVec4.Create(x, y, z, w: Single);
begin
  raw[0] := x;
  raw[1] := y;
  raw[2] := z;
  raw[3] := w;
end;

class operator TVec4.Divide(A: TVec4; B: Single): TVec4;
begin
  Result.x := A.x / B;
  Result.y := A.y / B;
  Result.z := A.z / B;
  Result.w := A.w / B;
end;

class operator TVec4.Divide(A: Single; B: TVec4): TVec4;
begin
  Result.x := A / B.x;
  Result.y := A / B.y;
  Result.z := A / B.z;
  Result.w := A / B.w;
end;

class operator TVec4.Divide(A, B: TVec4): TVec4;
begin
  Result.x := A.x / B.x;
  Result.y := A.y / B.y;
  Result.z := A.z / B.z;
  Result.w := A.w / B.w;
end;

class operator TVec4.Equal(A, B: TVec4): Boolean;
begin
  Result := SameValue(A.x, B.x) and SameValue(A.y, B.y) and SameValue(A.z, B.z) and SameValue(A.w, B.w);
end;

class operator TVec4.Explicit(A: TVec4): TVec2;
begin
  Result.x := A.x;
  Result.y := A.y;
end;

class operator TVec4.Explicit(A: TVec4): TVec2i;
begin
  Result.x := trunc(A.x);
  Result.y := trunc(A.y);
end;

class operator TVec4.Explicit(A: TVec4): TVec3i;
begin
  Result.x := trunc(A.x);
  Result.y := trunc(A.y);
  Result.z := trunc(A.z);
end;

class operator TVec4.Explicit(A: TVec4): TVec3;
begin
  Result.x := A.x;
  Result.y := A.y;
  Result.z := A.z;
end;

class operator TVec4.Implicit(A: TVec3): TVec4;
begin
  Result.x := A.x;
  Result.y := A.y;
  Result.z := A.z;
  Result.w := 0;
end;

class operator TVec4.Implicit(A: TVec2i): TVec4;
begin
  Result.x := A.x;
  Result.y := A.y;
  Result.z := 0;
  Result.w := 0;
end;

class operator TVec4.Implicit(A: TVec2): TVec4;
begin
  Result.x := A.x;
  Result.y := A.y;
  Result.z := 0;
  Result.w := 0;
end;

class operator TVec4.Implicit(A: TVec3i): TVec4;
begin
  Result.x := A.x;
  Result.y := A.y;
  Result.z := A.z;
  Result.w := 0;
end;

class operator TVec4.Multiply(A, B: TVec4): TVec4;
begin
  Result.x := A.x * B.x;
  Result.y := A.y * B.y;
  Result.z := A.z * B.z;
  Result.w := A.w * B.w;
end;

class operator TVec4.Multiply(A: Single; B: TVec4): TVec4;
begin
  Result.x := A * B.x;
  Result.y := A * B.y;
  Result.z := A * B.z;
  Result.w := A * B.w;
end;

class operator TVec4.Multiply(A: TVec4; B: Single): TVec4;
begin
  Result.x := A.x * B;
  Result.y := A.y * B;
  Result.z := A.z * B;
  Result.w := A.w * B;
end;

class operator TVec4.Negative(A: TVec4): TVec4;
begin
  Result.x := -A.x;
  Result.y := -A.y;
  Result.z := -A.z;
  Result.w := -A.w;
end;

class operator TVec4.NotEqual(A, B: TVec4): Boolean;
begin
  Result := not (SameValue(A.x, B.x) and SameValue(A.y, B.y) and SameValue(A.z, B.z) and SameValue(A.w, B.w));
end;

class operator TVec4.Subtract(A, B: TVec4): TVec4;
begin
  Result.x := A.x * B.x;
  Result.y := A.y * B.y;
  Result.z := A.z * B.z;
  Result.w := A.w * B.w;
end;

class operator TVec4.Subtract(A: Single; B: TVec4): TVec4;
begin
  Result.x := A * B.x;
  Result.y := A * B.y;
  Result.z := A * B.z;
  Result.w := A * B.w;
end;

class operator TVec4.Subtract(A: TVec4; B: Single): TVec4;
begin
  Result.x := A.x * B;
  Result.y := A.y * B;
  Result.z := A.z * B;
  Result.w := A.w * B;
end;

{$ENDREGION}

{$REGION 'TVec4i'}

class operator TVec4i.Add(A, B: TVec4i): TVec4i;
begin
  Result.x := A.x + B.x;
  Result.y := A.y + B.y;
  Result.z := A.z + B.z;
  Result.w := A.w + B.w;
end;

class operator TVec4i.Add(A: Integer; B: TVec4i): TVec4i;
begin
  Result.x := A + B.x;
  Result.y := A + B.y;
  Result.z := A + B.z;
  Result.w := A + B.w;
end;

class operator TVec4i.Add(A: TVec4i; B: Integer): TVec4i;
begin
  Result.x := A.x + B;
  Result.y := A.y + B;
  Result.z := A.z + B;
  Result.w := A.w + B;
end;

constructor TVec4i.Create(x, y, z, w: Integer);
begin
  raw[0] := x;
  raw[1] := y;
  raw[2] := z;
  raw[3] := w;
end;

class operator TVec4i.Divide(A: TVec4i; B: Single): TVec4;
begin
  Result.x := A.x / B;
  Result.y := A.y / B;
  Result.z := A.z / B;
  Result.w := A.w / B;
end;

class operator TVec4i.Divide(A: Single; B: TVec4i): TVec4;
begin
  Result.x := A / B.x;
  Result.y := A / B.y;
  Result.z := A / B.z;
  Result.w := A / B.w;
end;

class operator TVec4i.Divide(A, B: TVec4i): TVec4;
begin
  Result.x := A.x / B.x;
  Result.y := A.y / B.y;
  Result.z := A.z / B.z;
  Result.w := A.w / B.w;
end;

class operator TVec4i.Equal(A, B: TVec4i): Boolean;
begin
  Result := SameValue(A.x, B.x) and SameValue(A.y, B.y) and SameValue(A.z, B.z) and SameValue(A.w, B.w);
end;

class operator TVec4i.Explicit(A: TVec4i): TVec2i;
begin
  Result.x := A.x;
  Result.y := A.y;
end;

class operator TVec4i.Explicit(A: TVec4i): TVec3i;
begin
  Result.x := A.x;
  Result.y := A.y;
  Result.z := A.z;
end;

class operator TVec4i.Explicit(A: TVec2): TVec4i;
begin
  Result.x := trunc(A.x);
  Result.y := trunc(A.y);
  Result.z := 0;
  Result.w := 0;
end;

class operator TVec4i.Explicit(A: TVec4): TVec4i;
begin
  Result.x := trunc(A.x);
  Result.y := trunc(A.y);
  Result.z := trunc(A.z);
  Result.w := trunc(A.w);
end;

function TVec4i.GetVec(Index: Integer): Integer;
begin
  if (Index > -1) and (Index < 4) then
  Result := raw[Index]
  else
  raise Exception.Create('Reading out of Range');
end;

class operator TVec4i.Explicit(A: TVec4i): TVec2;
begin
  Result.x := A.x;
  Result.y := A.y;
end;

class operator TVec4i.Explicit(A: TVec4i): TVec3;
begin
  Result.x := A.x;
  Result.y := A.y;
  Result.z := A.z;
end;

class operator TVec4i.Explicit(A: TVec3): TVec4i;
begin
  Result.x := trunc(A.x);
  Result.y := trunc(A.y);
  Result.z := trunc(A.z);
  Result.w := 0;
end;

class operator TVec4i.Implicit(A: TVec2i): TVec4i;
begin
  Result.x := A.x;
  Result.y := A.y;
  Result.z := 0;
  Result.w := 0;
end;

class operator TVec4i.Implicit(A: TVec3i): TVec4i;
begin
  Result.x := A.x;
  Result.y := A.y;
  Result.z := A.z;
  Result.w := 0;
end;

class operator TVec4i.Implicit(A: TVec4i): TVec4;
begin
  Result.x := A.x;
  Result.y := A.y;
  Result.z := A.z;
  Result.w := A.w;
end;

class operator TVec4i.Multiply(A, B: TVec4i): TVec4i;
begin
  Result.x := A.x * B.x;
  Result.y := A.y * B.y;
  Result.z := A.z * B.z;
  Result.w := A.w * B.w;
end;

class operator TVec4i.Multiply(A: Integer; B: TVec4i): TVec4i;
begin
  Result.x := A * B.x;
  Result.y := A * B.y;
  Result.z := A * B.z;
  Result.w := A * B.w;
end;

class operator TVec4i.Multiply(A: TVec4i; B: Integer): TVec4i;
begin
  Result.x := A.x * B;
  Result.y := A.y * B;
  Result.z := A.z * B;
  Result.w := A.w * B;
end;

class operator TVec4i.Negative(A: TVec4i): TVec4i;
begin
  Result.x := -A.x;
  Result.y := -A.y;
  Result.z := -A.z;
  Result.w := -A.w;
end;

class operator TVec4i.NotEqual(A, B: TVec4i): Boolean;
begin
  Result := not (SameValue(A.x, B.x) and SameValue(A.y, B.y) and SameValue(A.z, B.z) and SameValue(A.w, B.w));
end;

procedure TVec4i.SetVec(Index, Value: Integer);
begin
  if (Index > -1) and (Index < 4) then
  raw[Index] := Value
  else
  raise Exception.Create('Reading out of Range');
end;

class operator TVec4i.Subtract(A, B: TVec4i): TVec4i;
begin
  Result.x := A.x * B.x;
  Result.y := A.y * B.y;
  Result.z := A.z * B.z;
  Result.w := A.w * B.w;
end;

class operator TVec4i.Subtract(A: Integer; B: TVec4i): TVec4i;
begin
  Result.x := A * B.x;
  Result.y := A * B.y;
  Result.z := A * B.z;
  Result.w := A * B.w;
end;

class operator TVec4i.Subtract(A: TVec4i; B: Integer): TVec4i;
begin
  Result.x := A.x * B;
  Result.y := A.y * B;
  Result.z := A.z * B;
  Result.w := A.w * B;
end;

{$ENDREGION}

{$REGION 'TMat4'}

class operator TMat4.Add(A, B: TMat4): TMat4;
var
  i: Integer;
begin
  for i := 0 to 15 do
  begin
    Result.raw[i] := A.raw[i] + B.raw[i];
  end;
end;

constructor TMat4.Create(Am11, Am21, Am31, Am41, Am12, Am22, Am32, Am42, Am13,
  Am23, Am33, Am43, Am14, Am24, Am34, Am44: Single);
begin
  m11 := Am11;
  m21 := Am21;
  m31 := Am31;
  m41 := Am41;

  m12 := Am12;
  m22 := Am22;
  m32 := Am32;
  m42 := Am42;

  m13 := Am13;
  m23 := Am23;
  m33 := Am33;
  m43 := Am43;

  m14 := Am14;
  m24 := Am24;
  m34 := Am34;
  m44 := Am44;
end;

class operator TMat4.Add(A: Single; B: TMat4): TMat4;
var
  i: Integer;
begin
  for i := 0 to 15 do
  begin
    Result.raw[i] := A + B.raw[i];
  end;
end;

class operator TMat4.Add(A: TMat4; B: Single): TMat4;
var
  i: Integer;
begin
  for i := 0 to 15 do
  begin
    Result.raw[i] := A.raw[i] + B;
  end;
end;

constructor TMat4.Create(x, y, z, w: TVec4);
begin
  vec[0] := x;
  vec[1] := y;
  vec[2] := z;
  vec[3] := w;
end;

class operator TMat4.Divide(A, B: TMat4): TMat4;
var
  i: Integer;
begin
  for i := 0 to 15 do
  begin
    Result.raw[i] := A.raw[i] / B.raw[i];
  end;
end;

class operator TMat4.Divide(A: Single; B: TMat4): TMat4;
var
  i: Integer;
begin
  for i := 0 to 15 do
  begin
    Result.raw[i] := A / B.raw[i];
  end;
end;

class operator TMat4.Divide(A: TMat4; B: Single): TMat4;
var
  i: Integer;
begin
  for i := 0 to 15 do
  begin
    Result.raw[i] := A.raw[i] / B;
  end;
end;

class operator TMat4.Equal(A, B: TMat4): Boolean;
var
  i: Integer;
begin
  Result := true;
  for i := 0 to 15 do
  begin
    if not SameValue(A.raw[i], B.raw[i]) then
    begin
      Result := false;
      exit;
    end;
  end;
end;

function TMat4.GetMat(Column, Row: Integer): Single;
begin
  if (Column > -1) and (Column < 4) and (Row > -1) and (Row < 4) then
  result := mat[Column, Row]
  else
    raise Exception.Create('Reading from out-of-range index');
end;

function TMat4.GetPointer: Pointer;
begin
  result := @raw[0];
end;

class function TMat4.LookAt(Pos, Target, Up: TVec3): TMat4;
var
  f, s, u: TVec3;
begin
  f := (Target - Pos).Normal;
  s := f.Cross(Up).Normal;
  u := s.Cross(f);

  Result := IdentityMat;
  Result.mat[0, 0] := s.x;
  Result.mat[1, 0] := s.y;
  Result.mat[2, 0] := s.z;
  Result.mat[0, 1] := u.x;
  Result.mat[1, 1] := u.y;
  Result.mat[2, 1] := u.z;
  Result.mat[0, 2] := -f.x;
  Result.mat[1, 2] := -f.y;
  Result.mat[2, 2] := -f.z;
  Result.mat[3, 0] := -(TVec.Dot(s, Pos));
  Result.mat[3, 1] := -(TVec.Dot(u, Pos));
  Result.mat[3, 2] := TVec.Dot(f, Pos);
end;

class operator TMat4.Multiply(A, B: TMat4): TMat4;
var
  i, j: Integer;
begin
  for i := 0 to 3 do
  begin
    for j := 0 to 3 do
    begin
      Result.vec[i].raw[j] := A.vec[i].raw[0] * B.vec[0].raw[j] +
                              A.vec[i].raw[1] * B.vec[1].raw[j] +
                              A.vec[i].raw[2] * B.vec[2].raw[j] +
                              A.vec[i].raw[3] * B.vec[3].raw[j];
    end;
  end;
end;

class operator TMat4.Multiply(A: Single; B: TMat4): TMat4;
var
  i: Integer;
begin
  for i := 0 to 15 do
  begin
    Result.raw[i] := A * B.raw[i];
  end;
end;

class operator TMat4.Multiply(A: TMat4; B: Single): TMat4;
var
  i: Integer;
begin
  for i := 0 to 15 do
  begin
    Result.raw[i] := A.raw[i] * B;
  end;
end;

class operator TMat4.NotEqual(A, B: TMat4): Boolean;
var
  i: Integer;
begin
  Result := false;
  for i := 0 to 15 do
  begin
    if not SameValue(A.raw[i], B.raw[i]) then
    begin
      Result := true;
      exit;
    end;
  end;
end;

class function TMat4.Ortho(Left, Right, Bottom, Top, zNear, zFar: Single): TMat4;
begin
  Result := IdentityMat;
  Result.mat[0, 0] := 2 / (right - left);
  Result.mat[1, 1] := 2 / (top - bottom);
  Result.mat[2, 2] := -2 / (zFar - zNear);
  Result.mat[3, 0] := - (right + left) / (right - left);
  Result.mat[3, 1] := - (top + bottom) / (top - bottom);
  Result.mat[3, 2] := - (zFar + zNear) / (zFar - zNear);
end;

class function TMat4.Perspective(AngleYDeg, Ratio, zNear, zFar: Single): TMat4;
var
  t: Single;
begin
  Result := EmptyMat;
  t := tan(DegToRad(AngleYDeg) / 2);

  Result.mat[0, 0] := 1 / (ratio * t);
  Result.mat[1, 1] := 1 / t;
  Result.mat[2, 3] := -1;

  Result.mat[2, 2] := - (zFar + zNear) / (zFar - zNear);
  Result.mat[3, 2] := - (2 * zFar * zNear) / (zFar - zNear);
end;

function TMat4.Rotate(AngleDEG: Single; x, y, z: Single): TMat4;
var
  rads: Single;
  rotMat: TMat4;
  vecRot, tmpVec: TVec3;
  c, s: Single;
begin
  rotMat := IdentityMat;
  vecRot.Create(x,y,z);
  vecRot := vecRot.Normal;
  rads := DegToRad(AngleDEG);
  tmpVec := (1 - cos(rads)) * vecRot;
  c := cos(rads);
  s := sin(rads);

  rotMat.mat[0, 0] := c + tmpVec.x * vecRot.x;
  rotMat.mat[0, 1] := tmpVec.x * vecRot.y + s * vecRot.z;
  rotMat.mat[0, 2] := tmpVec.x * vecRot.z - s * vecRot.y;

  rotMat.mat[1, 0] := tmpVec.y * vecRot.x - s * vecRot.z;
  rotMat.mat[1, 1] := c + tmpVec.y * vecRot.y;
  rotMat.mat[1, 2] := tmpVec.y * vecRot.z + s * vecRot.x;

  rotMat.mat[2, 0] := tmpVec.z * vecRot.x + s * vecRot.y;
  rotMat.mat[2, 1] := tmpVec.z * vecRot.y - s * vecRot.x;
  rotMat.mat[2, 2] := c + tmpVec.z * vecRot.z;

  Result := rotMat * Self;
end;

function TMat4.Rotate(AngleDEG: Single; vec: TVec3): TMat4;
var
  rads: Single;
  rotMat: TMat4;
  vecRot, tmpVec: TVec3;
  c, s: Single;
begin
  rotMat := IdentityMat;
  vecRot := vec;
  vecRot := vecRot.Normal;
  rads := DegToRad(AngleDEG);
  tmpVec := (1 - cos(rads)) * vecRot;
  c := cos(rads);
  s := sin(rads);

  rotMat.mat[0, 0] := c + tmpVec.x * vecRot.x;
  rotMat.mat[0, 1] := tmpVec.x * vecRot.y + s * vecRot.z;
  rotMat.mat[0, 2] := tmpVec.x * vecRot.z - s * vecRot.y;

  rotMat.mat[1, 0] := tmpVec.y * vecRot.x - s * vecRot.z;
  rotMat.mat[1, 1] := c + tmpVec.y * vecRot.y;
  rotMat.mat[1, 2] := tmpVec.y * vecRot.z + s * vecRot.x;

  rotMat.mat[2, 0] := tmpVec.z * vecRot.x + s * vecRot.y;
  rotMat.mat[2, 1] := tmpVec.z * vecRot.y - s * vecRot.x;
  rotMat.mat[2, 2] := c + tmpVec.z * vecRot.z;

  Result := rotMat * self;
end;

function TMat4.Scale(x, y, z: Single): TMat4;
begin
  Result := Self.Scale(vec3(x, y, z));
end;

function TMat4.Scale(Vec: TVec3): TMat4;
var
  scaleMat: TMat4;
begin
  scaleMat := IdentityMat;
  scaleMat.mat[0, 0] := vec.x;
  scaleMat.mat[1, 1] := vec.y;
  scaleMat.mat[2, 2] := vec.z;
  scaleMat.mat[3, 3] := 1;

  Result := Self * scaleMat;
end;

function TMat4.Scale(Factor: Single): TMat4;
begin
  Result := Self.Scale(Factor, Factor, Factor);
end;

procedure TMat4.SetMat(Column, Row: Integer; Value: Single);
begin
  if (Column > -1) and (Column < 4) and (Row > -1) and (Row < 4) then
    mat[Column, Row] := Value
  else
    raise Exception.Create('Reading from out-of-range index');
end;

class operator TMat4.Subtract(A, B: TMat4): TMat4;
var
  i: Integer;
begin
  for i := 0 to 15 do
  begin
    Result.raw[i] := A.raw[i] - B.raw[i];
  end;
end;

class operator TMat4.Subtract(A: Single; B: TMat4): TMat4;
var
  i: Integer;
begin
  for i := 0 to 15 do
  begin
    Result.raw[i] := A - B.raw[i];
  end;
end;

class operator TMat4.Subtract(A: TMat4; B: Single): TMat4;
var
  i: Integer;
begin
  for i := 0 to 15 do
  begin
    Result.raw[i] := A.raw[i] - B;
  end;
end;

function TMat4.Translate(vec: TVec3): TMat4;
var
  translateMat: TMat4;
begin
  translateMat := IdentityMat;
  translateMat.mat[3, 0] := vec.x;
  translateMat.mat[3, 1] := vec.y;
  translateMat.mat[3, 2] := vec.z;
  translateMat.mat[3, 3] := 1;

  Result := Self * translateMat;
end;

function TMat4.Translate(x, y, z: Single): TMat4;
var
  translateMat: TMat4;
begin
  translateMat := IdentityMat;
  translateMat.mat[3, 0] := x;
  translateMat.mat[3, 1] := y;
  translateMat.mat[3, 2] := z;
  translateMat.mat[3, 3] := 1;

  Result := Self * translateMat;
end;

{$ENDREGION}

{$REGION 'Misc'}

function Ortho(Left, Right, Bottom, Top: Single): TMat4;
begin
  Result := IdentityMat;
  Result[0, 0] := 2 / (right - left);
  Result[1, 1] := 2 / (top - bottom);
  Result[2, 2] := -1;
  Result[3, 0] := - (right + left) / (right - left);
  Result[3, 1] := - (top + bottom) / (top - bottom);
end;

function Perspective(AngleYDeg, Ratio, zNear, zFar: Single): TMat4;
var
  t: Single;
begin
  Result := EmptyMat;
  t := tan(DegToRad(AngleYDeg) / 2);

  Result[0, 0] := 1 / (ratio * t);
  Result[1, 1] := 1 / t;
  Result[2, 3] := -1;

  Result[2, 2] := - (zFar + zNear) / (zFar - zNear);
  Result[3, 2] := - (2 * zFar * zNear) / (zFar - zNear);
end;

function LookAt(Pos, Target, Up: TVec3): TMat4;
var
  f, s, u: TVec3;
begin
  f := (Target - Pos).Normal;
  s := f.Cross(Up).Normal;
  u := s.Cross(f);

  Result := IdentityMat;
  Result[0, 0] := s.x;
  Result[1, 0] := s.y;
  Result[2, 0] := s.z;
  Result[0, 1] := u.x;
  Result[1, 1] := u.y;
  Result[2, 1] := u.z;
  Result[0, 2] := -f.x;
  Result[1, 2] := -f.y;
  Result[2, 2] := -f.z;
  Result[3, 0] := -(s.Dot(Pos));
  Result[3, 1] := -(u.Dot(Pos));
  Result[3, 2] := f.Dot(Pos);
end;

function vec2(x, y: Single): TVec2;
begin
  Result := TVec2.Create(x, y);
end;

function vec2(Value: Single): TVec2;
begin
  Result := TVec2.Create(Value, Value);
end;

function vec3(x, y, z: Single): TVec3;
begin
  Result := TVec3.Create(x, y, z);
end;

function vec3(Value: Single): TVec3;
begin
  Result := TVec3.Create(Value, Value, Value);
end;

function vec4(x, y, z, w: Single): TVec4;
begin
  Result := TVec4.Create(x, y, z, w);
end;

function vec2i(x, y: Integer): TVec2i;
begin
  Result := TVec2i.Create(x, y);
end;

function vec3i(x, y, z: Integer): TVec3i;
begin
  Result := TVec3i.Create(x, y, z);
end;

function vec4i(x, y, z, w: Integer): TVec4i;
begin
  Result := TVec4i.Create(x, y, z, w);
end;

function vec4i(Value: Integer): TVec4i;
begin
  Result := TVec4i.Create(Value, Value, Value, Value);
end;

function StrToVec2(Str: String; const AFormatSettings: TFormatSettings; Default: Single; Delimiter: Char): TVec2;
var
  sarr: TArray<String>;
  s: String;
  f: Single;
  index: Integer;
begin
  Str := Trim(Str);
  sarr := SplitString(Str, Delimiter);
  Result := vec2(Default);
  index := 0;
  for s in sarr do
  begin
    if TryStrToFloat(s, f, AFormatSettings) then
    begin
      Result[index] := f;
      Inc(Index);
      if Index > High(Result.raw) then
        exit;
    end;
  end;
end;

function StrToVec2(Str: String; Default: Single; Delimiter: Char): TVec2;
begin
  Result := StrToVec2(Str, FormatSettings, Default, Delimiter);
end;

function StrToVec3(Str: String; const AFormatSettings: TFormatSettings; Default: Single; Delimiter: Char): TVec3;
var
  sarr: TArray<String>;
  s: String;
  f: Single;
  index: Integer;
begin
  Str := Trim(Str);
  sarr := SplitString(Str, Delimiter);
  Result := vec3(Default);
  index := 0;
  for s in sarr do
  begin
    if TryStrToFloat(s, f, AFormatSettings) then
    begin
      Result[index] := f;
      Inc(Index);
      if Index > High(Result.raw) then
        exit;
    end;
  end;
end;

function StrToVec3(Str: String; Default: Single; Delimiter: Char): TVec3;
begin
  Result := StrToVec3(Str, FormatSettings, Default, Delimiter);
end;

function StrToVec4i(Str: String; Default: Integer; Delimiter: Char): TVec4i;
var
  sarr: TArray<String>;
  s: String;
  f: Integer;
  index: Integer;
begin
  Str := Trim(Str);
  sarr := SplitString(Str, Delimiter);
  Result := vec4i(Default);
  index := 0;
  for s in sarr do
  begin
    if TryStrToInt(s, f) then
      Result[index] := f;
    Inc(Index);
    if Index > High(Result.raw) then
      exit;
  end;
end;

{$ENDREGION}

{$REGION 'TVec'}

class function TVec.Cross(A, B: TVec3): TVec3;
begin
  Result.x := (A.y * B.z) - (A.z * B.y);
  Result.y := (A.z * B.x) - (A.x * B.z);
  Result.z := (A.x * B.y) - (A.y * B.x);
end;

class function TVec.Cross(A, B: TVec2): TVec2;
begin
  Result.x := A.y;
  Result.y := -A.x;
end;

class function TVec.Dot(A, B: TVec2): Double;
begin
  Result := (A.x * B.x) + (A.y + B.y);
end;

class function TVec.Dot(A, B: TVec3): Double;
begin
  Result := (A.x * B.x) + (A.y * B.y) + (A.z * B.z);
end;

class function TVec.Normalize(A: TVec2): TVec2;
var
  d: Double;
begin
  d := A.Length;
  if d = 0 then
    exit;
  Result := A / d;
end;

class function TVec.Normalize(A: TVec3): TVec3;
var
  d: Double;
begin
  d := A.Length;
  if d = 0 then
    exit;
  Result := A / d;
end;

class function TVec.VecInCube(Vec, A, B: TVec3): Boolean;

  function InRangeEx(AValue, BoundA, BoundB: Double): Boolean;
  begin
    if BoundA >= BoundB then
      Result := InRange(AValue, BoundB, BoundA)
    else
      Result := InRange(AValue, BoundA, BoundB);
  end;

begin
  Result := InRangeEx(Vec.x, A.x, B.x) and
            InRangeEx(Vec.y, A.y, B.y) and
            InRangeEx(Vec.z, A.z, B.z);
end;

{$ENDREGION}

{$REGION 'TMat'}

class function TMat.Mat434(A: TMat4): TMat4;
begin
  Result := A;
  Result.vec[3] := vec4(0, 0, 0, 1);
  Result.m14 := 0;
  Result.m24 := 0;
  Result.m34 := 0;
end;

{$ENDREGION}

end.
