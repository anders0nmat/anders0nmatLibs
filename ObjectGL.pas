unit ObjectGL;

interface

uses dglOpenGL, OpenMath, Generics.Collections, SysUtils, Math, Classes,
     StrUtils, FMX.Graphics, FreeTypeDelphi;

type
  EShaderCompile = class(Exception);
  EModelData = class(Exception);
  EGLTexture = class(Exception);
  EInvalidBuffer = class(Exception);
  EInvalidFile = class(Exception);

  TGLShader = class(TInterfacedObject)
  private
    fID: TGLuint;

    function LoadShader(ASourceBuf: TBytes; ShaderType: GLuint): GLuint;
    function LoadProgram(AVert, AFrag, AGeom: TGLuint): GLuint;

    function LoadFromFile(AFile: String; ShaderType: GLuint): GLuint;
    function LoadFromStream(AStream: TStream; ShaderType: GLuint): GLuint;
    function LoadFromSource(ASource: String; ShaderType: GLuint): GLuint;
  public
    constructor Create(VertexPath, FragmentPath: String; GeometryPath: String = ''); overload;
    constructor Create; overload;
    destructor Destroy; override;

    procedure LoadFromFiles(VertexPath, FragmentPath: String; GeometryPath: String = '');
    procedure LoadFromSources(VertexSource, FragmentSource: String; GeometrySource: String = '');

    class procedure Leave;

    procedure Use;

    procedure SetBool(const Name: AnsiString; Value: Boolean);
    procedure SetInt(const Name: AnsiString; Value: Integer);
    procedure SetFloat(const Name: AnsiString; Value: Single);
    procedure SetMat4(const Name: AnsiString; Value: TMat4);
    procedure SetVec3(const Name: AnsiString; Value: TVec3);
  end;

  TGLMesh = class
  private type
    TValueTypes = set of (texture, normal, color);
  private
    fVAO: GLuint;

    fVerticies: TList<TVec3>;
    fTextures: TList<TVec2>;
    fNormals: TList<TVec3>;
    fColors: TList<TVec3>;

    fEBO: TList<GLuint>;

    procedure LoadFromObjFile(AObjFile: String);
  public
    constructor Create; overload;
    constructor Create(AFile: string); overload;
    destructor Destroy; override;

    procedure Draw(DrawMode: GLuint = GL_TRIANGLES);

    procedure LoadFromLists(APoints: TList<TVec4i>; AVerticies: TList<TVec3>; ATextures: TList<TVec2> = nil; ANormals: TList<TVec3> = nil;
                           AColors: TList<TVec3> = nil);
    ///  <summary>Expects an array in the following order ((o) = optional):
    ///  x, y, z, (o)u, (o)v, (o)nx, (o)ny, (o)nz, (o)r, (o)g, (o)b</summary>
    procedure LoadFromArray(Values: array of Single; ValueTypes: TValueTypes);
    procedure LoadFromFile(AFile: String);

    function Size: Integer;

    procedure Transmit;
  end;

  TGLBufferType = (btRed              = GL_RED,
                   btRG               = GL_RG,
                   btRGB              = GL_RGB,
                   btRGBA             = GL_RGBA,
                   btDepthStencil     = GL_DEPTH_STENCIL
                   );
  TGLAttachementType = (atColor0 = GL_COLOR_ATTACHMENT0, atColor1, atColor2, atColor3, atColor4,
                        atColor5, atColor6, atColor7, atColor8, atColor9, atColor10, atColor11,
                        atColor12, atColor13, atColor14, atColor15,
                        atDepth = GL_DEPTH_ATTACHMENT, atStencil = GL_STENCIL_ATTACHMENT,
                        atDepthStencil = GL_DEPTH_STENCIL_ATTACHMENT);

  TGLFramebufferTarget = (ftBoth = GL_FRAMEBUFFER, ftRead = GL_READ_FRAMEBUFFER, ftDraw = GL_DRAW_FRAMEBUFFER);

  TWrapMode = (wmRepeat = GL_REPEAT, wmMirroredRepeat = GL_MIRRORED_REPEAT,
    wmClampToEdge = GL_CLAMP_TO_EDGE, wmClampToBorder = GL_CLAMP_TO_BORDER);

  TTextureFilter = (tfLinear = GL_LINEAR, tfNearest = GL_NEAREST);

  TGLTexture = class
  protected
    fTexId: GLuint;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure SetParameter(Parameter: GLenum; Value: GLint); virtual; abstract;

    procedure Activate(TextureUnit: Integer); overload; virtual; abstract;
    procedure Activate; overload; virtual; abstract;
    class procedure Deactivate; virtual; abstract;

    property TextureId: GLuint read fTexId;
  end;

  TGLTexture2D = class(TGLTexture)
  private
    fType: TGLBufferType;
  public
    constructor Create(AType: TGLBufferType; AWidth, AHeight: Cardinal); reintroduce; overload;
    constructor CreateFromFile(const APath: String; LoadFlipped: Boolean = false);
    constructor CreateFromStream(AStream: TStream; LoadFlipped: Boolean = false);
    constructor CreateFromBitmap(ABitmap: TBitmap; LoadFlipped: Boolean = false);
    constructor CreateFromRawStream(AStream: TMemoryStream; ColorMode: GLuint;
      InternalMode: TGLBufferType; Width, Height: Cardinal);
    procedure LoadFromFile(const APath: String; LoadFlipped: Boolean = false);
    procedure LoadFromStream(AStream: TStream; LoadFlipped: Boolean = false);
    procedure LoadFromBitmap(ABitmap: TBitmap; LoadFlipped: Boolean = false);
    procedure LoadFromRawStream(AStream: TMemoryStream; ColorMode: GLuint;
      InternalMode: TGLBufferType; Width, Height: Cardinal);

    procedure Initialize(AType: TGLBufferType; AWidth, AHeight: Cardinal); virtual;

    procedure SetParameter(Parameter: GLenum; Value: GLint); override;

    procedure Activate; overload; override;
    procedure Activate(TextureUnit: Integer); overload; override;
    class procedure Deactivate; override;

    procedure SetWrapping(ASMode, ATMode: TWrapMode); overload;
    procedure SetWrapping(AMode: TWrapMode); overload;
    procedure SetFilterMode(AMinFilter, AMagFilter: TTextureFilter); overload;
    procedure SetFilterMode(AFilter: TTextureFilter); overload;

    property InternalFormat: TGLBufferType read fType;
  end;

  TGLTextureCube = class(TGLTexture)
  public type
    TCubeFileArray = array[0..5] of String;
  public
    procedure SetParameter(Parameter: GLenum; Value: GLint); override;

    procedure LoadFromFile(const Files: TCubeFileArray; LoadFlipped: Boolean = false);

    class function FromFile(const Files: TCubeFileArray): TGLTextureCube;

    procedure Activate(TextureUnit: Integer); overload; override;
    procedure Activate; overload; override;
    class procedure Deactivate; override;

    procedure SetWrapping(ASMode, ATMode, ARMode: TWrapMode); overload;
    procedure SetWrapping(AMode: TWrapMode); overload;
  end;

  TGLTextureList = class(TObjectDictionary<String, TGLTexture>)
  public
    constructor Create(ACapacity: Integer = 0);
  end;

  TGLMeshList = class(TObjectDictionary<String, TGLMesh>)
  public
    constructor Create(ACapacity: Integer = 0);
  end;

  TGLShaderList = class(TObjectDictionary<String, TGLShader>)
  public
    constructor Create(ACapacity: Integer = 0);
  end;

  TCameraMovement = (cmForward, cmBackward, cmLeft, cmRight, cmUp, cmDown);

  TGLCamera = class
  private
    fPosition: TVec3;
    fFront: TVec3;
    fUp: TVec3;
    fRight: TVec3;
    fWorldUp: TVec3;
    fYaw: Single;
    fPitch: Single;
    fZoom: Single;

    const
      MOVEMENT_SPEED = 0.02;
      MOUSE_SENSITIVITY = 0.7;

    procedure UpdateCameraVectors;
  public
    constructor Create(APosition, AUp: TVec3; AYaw, APitch: Single);

    function GetViewMatrix: TMat4;
    procedure ProcessMouseMovement(XOff, YOff: Single; ConstrainPitch: Boolean = true);
    procedure ProcessMouseWheel(YOff: Single);
    procedure ProcessKeyboard(Direction: TCameraMovement; Delta: Single);

    property Position: TVec3 read fPosition;
    property Front: TVec3 read fFront;
    property Zoom: Single read fZoom;
  end;

  TGLRenderbuffer = class
  private
    fId: GLuint;
    fType: TGLBufferType;
  public
    constructor Create; overload;
    constructor Create(AType: TGLBufferType; AWidth, AHeight: Cardinal); overload;
    destructor Destroy; override;

    procedure Bind;
    procedure Initialize(AType: TGLBufferType; AWidth, AHeight: Cardinal); virtual;
    class procedure Unbind;

    property Id: GLuint read fId;
    property InternalFormat: TGLBufferType read fType;
  end;

  TGLFramebuffer = class
  private
    fId: GLuint;
    fValid: Boolean;
    fAttachments: TObjectDictionary<TGLAttachementType, TObject>;

    function GetAttachmentType(InternalFormat: TGLBufferType): TGLAttachementType;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function Validate: Boolean;
    procedure AttachBuffer(ATextureBuffer: TGLTexture2D; OwnsObject: Boolean = false; AttachmentLevel: Cardinal = 0); overload;
    procedure AttachBuffer(ARenderBuffer: TGLRenderbuffer; OwnsObject: Boolean = false; AttachmentLevel: Cardinal = 0); overload;
    procedure Bind(Target: TGLFramebufferTarget = ftBoth);
    class procedure Unbind(Target: TGLFramebufferTarget = ftBoth);

    property FramebufferId: GLuint read fId;
  end;

  TGLRenderbufferMultisample = class(TGLRenderbuffer)
  private
    fSamples: GLuint;
  public
    constructor Create(Samples: GLuint; AType: TGLBufferType; AWidth, AHeight: Cardinal);
    procedure Initialize(AType: TGLBufferType; AWidth, AHeight: Cardinal); overload; override;
    procedure Initialize(Samples: GLuint; AType: TGLBufferType; AWidth, AHeight: Cardinal); reintroduce; overload;

    property Samples: GLuint read fSamples;
  end;

  TGLTextRenderer = class
  private const
    vertexShader = '#version 330 core'#10 +
                   'layout (location = 0) in vec3 aPos;'#10 +
                   'layout (location = 1) in vec2 aTex;'#10 +
                   'out vec2 texCoord;'#10 +
                   'uniform mat4 scale;'#10 +
                   'uniform mat4 position;'#10 +
                   'uniform mat4 projection;'#10 +
                   'void main() {'#10 +
                   '	gl_Position = projection * position * scale * vec4(aPos.xy, 0.0, 1.0);'#10 +
                   '	texCoord = aTex;'#10 +
                   '}';
    fragmentShader = '#version 330 core'#10 +
                     'out vec4 FragColor;'#10 +
                     'in vec2 texCoord;'#10 +
                     'uniform sampler2D tex;'#10 +
                     'uniform vec3 color;'#10 +
                     'void main() {'#10 +
                     '	FragColor = vec4(color.rgb, texture(tex, texCoord).r);'#10 +
                     '}'; 
  
  private
    fCharList: TDictionary<Char, TFreeTypeChar>;
    fTextureList: TGLTextureList;
    fShader: TGLShader;
    fModel: TGLMesh;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetDrawSize(Left, Right, Bottom, Top: Single);

    procedure RegisterChars(Chars: String; resolutionDPI: Word; Size: Cardinal; AFontFile: String);
    procedure RenderText(AString: String; APosition: TVec2; AColor: TVec3; AScale: Single = 1);
  end;

const
  quadMesh: array[0..29] of Single = (
    0, 0, 0,    0, 0, 
    0, 1, 0,    0, 1,
    1, 0, 0,    1, 0,

    1, 1, 0,    1, 1,
    1, 0, 0,    1, 0,
    0, 1, 0,    0, 1
  );

implementation

{$REGION 'TGLShader'}

constructor TGLShader.Create(VertexPath, FragmentPath, GeometryPath: String);
begin
  Create;
  LoadFromFiles(VertexPath, FragmentPath, GeometryPath);
end;

constructor TGLShader.Create;
begin
  fID := 0;
end;

destructor TGLShader.Destroy;
begin
  glDeleteProgram(fID);
  inherited;
end;

class procedure TGLShader.Leave;
begin
  glUseProgram(0);
end;

function TGLShader.LoadFromFile(AFile: String; ShaderType: GLuint): GLuint;
var
  stream: TFileStream;
begin
  Result := 0;
  stream := TFileStream.Create(AFile, fmOpenRead or fmShareDenyWrite);
  try
    Result := LoadFromStream(stream, ShaderType);
  finally
    stream.Free;
  end;
end;

procedure TGLShader.LoadFromFiles(VertexPath, FragmentPath,
  GeometryPath: String);
var
  vert, frag, geom: GLuint;
begin
  if not FileExists(VertexPath) then
    raise EFileNotFoundException.Create(VertexPath + ' not found');
  if not FileExists(FragmentPath) then
    raise EFileNotFoundException.Create(FragmentPath + ' not found');

  vert := 0;
  frag := 0;
  geom := 0;

  try
    vert := LoadFromFile(VertexPath, GL_VERTEX_SHADER);
    frag := LoadFromFile(FragmentPath, GL_FRAGMENT_SHADER);
    if FileExists(GeometryPath) then
      geom := LoadFromFile(GeometryPath, GL_GEOMETRY_SHADER);

    fID := LoadProgram(vert, frag, geom);
  finally
    if vert <> 0 then
      glDeleteShader(vert);
    if frag <> 0 then
      glDeleteShader(frag);
    if geom <> 0 then
      glDeleteShader(geom);
  end;
end;

function TGLShader.LoadFromSource(ASource: String; ShaderType: GLuint): GLuint;
var
  stream: TStringStream;
begin
  Result := 0;
  stream := TStringStream.Create(ASource);
  try
    Result := LoadFromStream(stream, ShaderType);
  finally
    stream.Free;
  end;
end;

procedure TGLShader.LoadFromSources(VertexSource, FragmentSource,
  GeometrySource: String);
var
  vert, frag, geom: GLuint;
begin
  if VertexSource = '' then
    raise EShaderCompile.Create('VertexSource not valid');
  if FragmentSource = '' then
    raise EShaderCompile.Create('FragmentSource not valid');

  vert := 0;
  frag := 0;
  geom := 0;

  try
    vert := LoadFromSource(VertexSource, GL_VERTEX_SHADER);
    frag := LoadFromSource(FragmentSource, GL_FRAGMENT_SHADER);
    if GeometrySource <> '' then
      geom := LoadFromSource(GeometrySource, GL_GEOMETRY_SHADER);

    fID := LoadProgram(vert, frag, geom);
  finally
    if vert <> 0 then
      glDeleteShader(vert);
    if frag <> 0 then
      glDeleteShader(frag);
    if geom <> 0 then
      glDeleteShader(geom);
  end;

end;

function TGLShader.LoadFromStream(AStream: TStream; ShaderType: GLuint): GLuint;
var
  buf: TBytes;
begin
  SetLength(buf, AStream.Size);
  AStream.Position := 0;
  AStream.Read(buf, Length(buf));
  Result := LoadShader(buf, ShaderType);
end;

function TGLShader.LoadProgram(AVert, AFrag, AGeom: TGLuint): GLuint;
var
  status: TGLint;
  buf: TBytes;
  infoLog: String;
begin
  Result := glCreateProgram;
  glAttachShader(Result, AVert);
  glAttachShader(Result, AFrag);
  if AGeom <> 0 then
    glAttachShader(Result, AGeom);

  glLinkProgram(Result);

  glGetProgramiv(Result, GL_LINK_STATUS, @status);
  if status = 0 then
  begin
    glGetProgramiv(Result, GL_INFO_LOG_LENGTH, @status);
    if status > 0 then
    begin
      SetLength(buf, status);
      glGetProgramInfoLog(Result, status, @status, @buf[0]);
    end;
    infoLog := TEncoding.UTF8.GetString(buf);
    raise EShaderCompile.Create(infoLog);
  end;
end;

function TGLShader.LoadShader(ASourceBuf: TBytes; ShaderType: GLuint): GLuint;
var
  fs: TFileStream;
  errbuf: TBytes;
  ps: PAnsiChar;
  status: TGLint;
  infoLog: String;
  len: Integer;
begin
  Result := glCreateShader(ShaderType);

  ps := PAnsiChar(@ASourceBuf[0]);
  len := Length(ASourceBuf);

  glShaderSource(Result, 1, @ps, @len);
  glCompileShader(Result);

  glGetShaderiv(Result, GL_COMPILE_STATUS, @status);
  if status = 0 then
  begin
    glGetShaderiv(Result, GL_INFO_LOG_LENGTH, @status);
    if status > 0 then
    begin
      SetLength(errbuf, status);
      glGetShaderInfoLog(Result, status, @status, @errbuf[0]);
    end;
    infoLog := TEncoding.UTF8.GetString(errbuf);
    raise EShaderCompile.Create(infoLog);
  end;
end;

procedure TGLShader.SetBool(const Name: AnsiString; Value: Boolean);
begin
  Use;
  glUniform1i(glGetUniformLocation(fID, PAnsiChar(Name)), Integer(Value));
end;

procedure TGLShader.SetFloat(const Name: AnsiString; Value: Single);
begin
  Use;
  glUniform1f(glGetUniformLocation(fID, PAnsiChar(Name)), Value);
end;

procedure TGLShader.SetInt(const Name: AnsiString; Value: Integer);
begin
  Use;
  glUniform1i(glGetUniformLocation(fID, PAnsiChar(Name)), Value);
end;

procedure TGLShader.SetMat4(const Name: AnsiString; Value: TMat4);
begin
  Use;
  glUniformMatrix4fv(glGetUniformLocation(fID, PAnsiChar(Name)), 1, GL_FALSE, @Value.raw[0]);
end;

procedure TGLShader.SetVec3(const Name: AnsiString; Value: TVec3);
begin
  Use;
  glUniform3fv(glGetUniformLocation(fID, PAnsiChar(Name)), 1, @Value.raw[0]);
end;

procedure TGLShader.Use;
begin
  glUseProgram(fID);
end;

{$ENDREGION}

{$REGION 'TGLMesh'}

function TGLMesh.Size: Integer;
begin
  Result := fVerticies.Count * sizeof(TVec3);
  Result := Result + fTextures.Count * sizeof(TVec2);
  Result := Result + fNormals.Count * sizeof(TVec3);
  Result := Result + fColors.Count * sizeof(TVec3);
  Result := Result + fEBO.Count * sizeof(GLuint);
end;

constructor TGLMesh.Create;
begin
  glGenVertexArrays(1, @fVAO);
  fVerticies := TList<TVec3>.Create;
  fTextures := TList<TVec2>.Create;
  fNormals := TList<TVec3>.Create;
  fColors := TList<TVec3>.Create;
  fEBO := TList<GLuint>.Create;
end;

constructor TGLMesh.Create(AFile: string);
begin
  Create;
  LoadFromFile(AFile);
end;

destructor TGLMesh.Destroy;
begin
  glDeleteVertexArrays(1, @fVAO);
  fVerticies.Free;
  fTextures.Free;
  fNormals.Free;
  fColors.Free;
  fEBO.Free;
  inherited;
end;

procedure TGLMesh.Draw(DrawMode: GLuint);
begin
  glBindVertexArray(fVAO);
  glDrawElements(DrawMode, fEBO.Count, GL_UNSIGNED_INT, nil);
end;

procedure TGLMesh.LoadFromArray(Values: array of Single; ValueTypes: TValueTypes);
var
  vert, norm, col: TList<TVec3>;
  text: TList<TVec2>;
  points: TList<TVec4i>;
  i, o, pointLength, p: Integer;
begin
  vert := TList<TVec3>.Create;
  points := TList<TVec4i>.Create;
  norm := nil;
  text := nil;
  col := nil;

  try
    if texture in ValueTypes then
      text := TList<TVec2>.Create;
    if normal in ValueTypes then
      norm := TList<TVec3>.Create;
    if color in ValueTypes then
      col := TList<TVec3>.Create;

    pointLength := (3 + 2 * Integer(texture in ValueTypes) + 3 * Integer(normal in ValueTypes) + 3 * Integer(color in ValueTypes));

    if Length(Values) mod pointLength <> 0 then
      raise EModelData.Create('Values are not as long as expected');

    i := 0;
    p := 0;
    repeat
      o := 0;
      points.Add(vec4i(p, IfThen(texture in ValueTypes, p, -1), IfThen(normal in ValueTypes, p, -1), IfThen(color in ValueTypes, p, -1)));
      vert.Add(vec3(Values[i], Values[i + 1], Values[i + 2]));
      if texture in ValueTypes then
      begin
        text.Add(vec2(Values[i + 3], Values[i + 4]));
        o := 2;
      end;
      if normal in ValueTypes then
      begin
        norm.Add(vec3(Values[i + o + 3], Values[i + o + 4], Values[i + o + 5]));
        Inc(o, 3);
      end;
      if color in ValueTypes then
        col.Add(vec3(Values[i + o + 3], Values[i + o + 4], Values[i + o + 5]));
      Inc(i, pointLength);
      Inc(p);
    until i = Length(Values);

    LoadFromLists(points, vert, text, norm, col);
  finally
    vert.Free;
    norm.Free;
    text.Free;
    col.Free;
    points.Free;
  end;
end;

procedure TGLMesh.LoadFromFile(AFile: String);
var
  ext: string;
begin
  if not FileExists(AFile) then
    raise EFileNotFoundException.Create('File ' + AFile + ' not found');

  ext := ExtractFileExt(AFile);
  case IndexText(ext, ['.obj']) of
  0: LoadFromObjFile(AFile);
  else raise EInvalidFile.Create('Unknown file extension: ' + ext);
  end;
end;

procedure TGLMesh.LoadFromLists(APoints: TList<TVec4i>; AVerticies: TList<TVec3>;
  ATextures: TList<TVec2>; ANormals, AColors: TList<TVec3>);
var
  i: TVec4i;
  eboDic: TDictionary<TVec4i, GLuint>;
  ebo, eboCount: GLuint;
begin
  if not Assigned(APoints) then
    raise EModelData.Create('PointList not initialized');
  if not Assigned(AVerticies) then
    raise EModelData.Create('VertexList not initialized');

  if APoints.Count mod 3 <> 0 then
    raise EModelData.Create('Points not triangulated?');

  eboDic := TDictionary<TVec4i, GLuint>.Create(APoints.Count);
  eboCount := 0;
  try
    for i in APoints do
    begin
      if eboDic.TryGetValue(i, ebo) then
      begin
        fEBO.Add(ebo);
        Continue;
      end;

      eboDic.Add(i, eboCount);
      fEBO.Add(eboCount);
      Inc(eboCount);

      fVerticies.Add(AVerticies[i.x]);

      if (i.y > -1) and Assigned(ATextures) then
        fTextures.Add(ATextures[i.y]);

      if (i.z > -1) and Assigned(ANormals) then
        fNormals.Add(ANormals[i.z]);

      if (i.w > -1) and Assigned(AColors) then
        fColors.Add(AColors[i.w]);
    end;
  finally
    eboDic.Free;
  end;
  Transmit;
end;

procedure TGLMesh.LoadFromObjFile(AObjFile: String);
var
  sl: TStringList;

  verticies, normals: TList<TVec3>;
  textures: TList<TVec2>;
  points: TList<TVec4i>;

  ObjFormat: TFormatSettings;
  sarr: TArray<String>;
  s: String;
begin
  if not FileExists(AObjFile) then
    raise EFileNotFoundException.Create('File ' + AObjFile + ' not found');

  ObjFormat := TFormatSettings.Create;
  with ObjFormat do
  begin
    DecimalSeparator := '.';
    ThousandSeparator := ',';
  end;

  verticies := nil;
  textures := nil;
  normals := nil;
  points := nil;

  sl := TStringList.Create;
  try
    sl.LoadFromFile(AObjFile);

    verticies := TList<TVec3>.Create;
    verticies.Add(vec3(0));             // Indexing in .obj Files starts with 1
    textures := TList<TVec2>.Create;
    textures.Add(vec2(0));              // -||-
    normals := TList<TVec3>.Create;
    normals.Add(vec3(0));               // -||-
    points := TList<TVec4i>.Create;

    for s in sl do
    begin
      if StartsText('v ', s) then
      begin
        verticies.Add(StrToVec3(s, ObjFormat));
        Continue;
      end;

      if StartsText('vt ', s) then
      begin
        textures.Add(StrToVec2(s, ObjFormat));
        Continue;
      end;

      if StartsText('vn ', s) then
      begin
        normals.Add(StrToVec3(s, ObjFormat));
        Continue;
      end;

      if StartsText('f ', s) then
      begin
        sarr := SplitString(s, ' ');
        if Length(sarr) < 4 then
          raise EModelData.Create('Face with less than three points.');
        points.Add(StrToVec4i(sarr[1], -1, '/'));
        points.Add(StrToVec4i(sarr[2], -1, '/'));
        points.Add(StrToVec4i(sarr[3], -1, '/'));
        Continue;
      end;
    end;

    LoadFromLists(points, verticies, textures, normals, nil); // .obj does not support color lists
  finally
    sl.Free;
    verticies.Free;
    textures.Free;
    normals.Free;
    points.Free;
  end;
end;

procedure TGLMesh.Transmit;
var
  vbo, ebo: GLuint;
begin
  glBindVertexArray(fVAO);

  if fEBO.Count = 0 then
  begin
    glBindVertexArray(0);
    exit;
  end;

  if fVerticies.Count > 0 then
  begin
    glGenBuffers(1, @vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, fVerticies.Count * sizeof(fVerticies[0]), @fVerticies.List[0], GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(fVerticies[0]), Pointer(0));
    glEnableVertexAttribArray(0);
  end;

  if fTextures.Count > 0 then
  begin
    glGenBuffers(1, @vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, fTextures.Count * sizeof(fTextures[0]), @fTextures.List[0], GL_STATIC_DRAW);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(fTextures[0]), Pointer(0));
    glEnableVertexAttribArray(1);
  end;

  if fNormals.Count > 0 then
  begin
    glGenBuffers(1, @vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, fNormals.Count * sizeof(fNormals[0]), @fNormals.List[0], GL_STATIC_DRAW);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, sizeof(fNormals[0]), Pointer(0));
    glEnableVertexAttribArray(2);
  end;

  if fColors.Count > 0 then
  begin
    glGenBuffers(1, @vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, fColors.Count * sizeof(fColors[0]), @fColors.List[0], GL_STATIC_DRAW);
    glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, sizeof(fColors[0]), Pointer(0));
    glEnableVertexAttribArray(3);
  end;

  glGenBuffers(1, @ebo);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, fEBO.Count * sizeof(fEBO[0]), @fEBO.List[0], GL_STATIC_DRAW);

  glBindVertexArray(0);
end;

{$ENDREGION}

{$REGION 'TGLTexture2D'}

procedure TGLTexture2D.Activate;
begin
  glBindTexture(GL_TEXTURE_2D, fTexId);
end;

procedure TGLTexture2D.Activate(TextureUnit: Integer);
begin
  if (TextureUnit < 0) or (TextureUnit > 31) then
    raise EGLTexture.Create('TextureUnit out of Bounds');

  glActiveTexture(GL_TEXTURE0 + TextureUnit);
  Activate;
end;

constructor TGLTexture2D.Create(AType: TGLBufferType; AWidth,
  AHeight: Cardinal);
begin
  Create;
  Initialize(AType, AWidth, AHeight);
end;

constructor TGLTexture2D.CreateFromBitmap(ABitmap: TBitmap;
  LoadFlipped: Boolean);
begin
  Create;
  LoadFromBitmap(ABitmap, LoadFlipped);
end;

constructor TGLTexture2D.CreateFromFile(const APath: String;
  LoadFlipped: Boolean);
begin
  Create;
  LoadFromFile(APath, LoadFlipped);
end;

constructor TGLTexture2D.CreateFromRawStream(AStream: TMemoryStream;
  ColorMode: GLuint; InternalMode: TGLBufferType; Width, Height: Cardinal);
begin
  Create;
  LoadFromRawStream(AStream, ColorMode, InternalMode, Width, Height);
end;

constructor TGLTexture2D.CreateFromStream(AStream: TStream;
  LoadFlipped: Boolean);
begin
  Create;
  LoadFromStream(AStream, LoadFlipped);
end;

class procedure TGLTexture2D.Deactivate;
begin
  glBindTexture(GL_TEXTURE_2D, 0);
end;

procedure TGLTexture2D.Initialize(AType: TGLBufferType; AWidth, AHeight: Cardinal);
begin
  Activate;
  fType := AType;
  glTexImage2D(GL_TEXTURE_2D, 0, Ord(AType), AWidth, AHeight, 0, GL_RGB, GL_UNSIGNED_BYTE, nil);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  Deactivate;
end;

procedure TGLTexture2D.LoadFromBitmap(ABitmap: TBitmap; LoadFlipped: Boolean);
var
  pic: TBitmap;
  bitPointer: TBitmapData;
  buf: TMemoryStream;
  i, bbl: Integer;
begin
  buf := nil;
  pic := TBitmap.Create;
  try
    pic.Assign(ABitmap);
    if LoadFlipped then
      pic.FlipVertical;

    buf := TMemoryStream.Create;
    buf.Size := pic.Width * pic.Height * pic.BytesPerPixel;
    bbl := pic.Width * pic.BytesPerPixel;
    pic.Map(TMapAccess.Read, bitPointer);

    for i := 0 to pic.Height - 1 do
      buf.Write(bitPointer.GetScanline(i)^, bbl);

    pic.Unmap(bitPointer);

    LoadFromRawStream(buf, GL_BGRA, btRGBA, pic.Width, pic.Height);
  finally
    buf.Free;
    pic.Free;
  end;
end;

procedure TGLTexture2D.LoadFromFile(const APath: String; LoadFlipped: Boolean);
var
  Bit: TBitmap;
begin
  Bit := TBitmap.CreateFromFile(APath);
  try
    LoadFromBitmap(Bit, LoadFlipped);
  finally
    Bit.Free;
  end;
end;

procedure TGLTexture2D.LoadFromRawStream(AStream: TMemoryStream; ColorMode: GLuint;
  InternalMode: TGLBufferType; Width, Height: Cardinal);
begin
  if AStream.Size < Width * Height then
    raise Exception.Create('Stream too small');

  Activate;

  glTexImage2D(GL_TEXTURE_2D, 0, Ord(InternalMode), Width, Height,
    0, ColorMode, GL_UNSIGNED_BYTE, AStream.Memory);
  fType := InternalMode;
  // default texture filtering. Without it textures will be black
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  Deactivate;
end;

procedure TGLTexture2D.LoadFromStream(AStream: TStream; LoadFlipped: Boolean);
var
  pic: TBitmap;
begin
  pic := TBitmap.CreateFromStream(AStream);
  try
    LoadFromBitmap(pic, LoadFlipped);
  finally
    pic.Free;
  end;
end;

procedure TGLTexture2D.SetFilterMode(AMinFilter, AMagFilter: TTextureFilter);
begin
  Activate;
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, Ord(AMinFilter));
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, Ord(AMagFilter));
  Deactivate;
end;

procedure TGLTexture2D.SetFilterMode(AFilter: TTextureFilter);
begin
  SetFilterMode(AFilter, AFilter);
end;

procedure TGLTexture2D.SetParameter(Parameter: GLenum; Value: GLint);
begin
  Activate;
  glTexParameteri(GL_TEXTURE_2D, Parameter, Value);
  Deactivate;
end;

procedure TGLTexture2D.SetWrapping(ASMode, ATMode: TWrapMode);
begin
  Activate;
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, Ord(ASMode));
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, Ord(ATMode));
  Deactivate;
end;

procedure TGLTexture2D.SetWrapping(AMode: TWrapMode);
begin
  SetWrapping(AMode, AMode);
end;

{$ENDREGION}

{$REGION 'TGLCamera'}

constructor TGLCamera.Create(APosition, AUp: TVec3; AYaw, APitch: Single);
begin
  fPosition := APosition;
  fUp := AUp;
  fWorldUp := AUp;
  fFront := vec3(0, 0, -1);
  fZoom := 45;
  fYaw := AYaw;
  fPitch := APitch;
  UpdateCameraVectors;
end;

function TGLCamera.GetViewMatrix: TMat4;
begin
  Result := TMat4.LookAt(fPosition, fPosition + fFront, fUp);
end;

procedure TGLCamera.ProcessKeyboard(Direction: TCameraMovement; Delta: Single);
var
  Velocity: Single;
begin
  Velocity := Delta * MOVEMENT_SPEED;
  case Direction of
    cmForward: fPosition := fPosition + (fFront.Normal * vec3(1, 0, 1)).Normal * Velocity;
    cmBackward: fPosition := fPosition - (fFront.Normal * vec3(1, 0, 1)).Normal * Velocity;
    cmLeft: fPosition := fPosition - fRight * Velocity;
    cmRight: fPosition := fPosition + fRight * Velocity;
    cmUp: fPosition := fPosition + vec3(0, 1, 0) * Velocity;
    cmDown: fPosition := fPosition + vec3(0, -1, 0) * Velocity;
  end;
end;

procedure TGLCamera.ProcessMouseMovement(XOff, YOff: Single;
  ConstrainPitch: Boolean);
begin
  xoff := xoff * MOUSE_SENSITIVITY;
  yoff := -yoff * MOUSE_SENSITIVITY;

  fYaw := fYaw + XOff;
  fPitch := fPitch + yoff;

  if ConstrainPitch then
  begin
    if fPitch > 89 then
      fPitch := 89;
    if fPitch < -89 then
      fPitch := -89;
  end;

  UpdateCameraVectors;
end;

procedure TGLCamera.ProcessMouseWheel(YOff: Single);
begin
  fZoom := Min(Max(fZoom - yoff, 1), 45);
end;

procedure TGLCamera.UpdateCameraVectors;
var
  front: TVec3;
begin
  front.x := cos(DegToRad(fYaw)) * cos(DegToRad(fPitch));
  front.y := sin(DegToRad(fPitch));
  front.z := sin(DegToRad(fYaw)) * cos(DegToRad(fPitch));
  fFront := front.Normal;

  fRight := TVec.Normalize(TVec.Cross(fFront, fWorldUp));
  fUp := fRight.Cross(fFront).Normal;
end;

{$ENDREGION}

{$REGION 'TGLTextureList'}

constructor TGLTextureList.Create(ACapacity: Integer);
begin
  inherited Create([doOwnsValues], ACapacity);
end;

{$ENDREGION}

{$REGION 'TGLTexture'}

constructor TGLTexture.Create;
begin
  glGenTextures(1, @fTexId);
end;

destructor TGLTexture.Destroy;
begin
  glDeleteTextures(1, @fTexId);
  inherited;
end;

{$ENDREGION}

{$REGION 'TGLTextureCube'}

procedure TGLTextureCube.Activate(TextureUnit: Integer);
begin
  if (TextureUnit < 0) or (TextureUnit > 31) then
    raise EGLTexture.Create('TextureUnit out of Bounds');

  glActiveTexture(GL_TEXTURE0 + TextureUnit);
  Activate;
end;

procedure TGLTextureCube.Activate;
begin
  glBindTexture(GL_TEXTURE_CUBE_MAP, fTexId);
end;

class procedure TGLTextureCube.Deactivate;
begin
  glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
end;

class function TGLTextureCube.FromFile(
  const Files: TCubeFileArray): TGLTextureCube;
begin
  Result := TGLTextureCube.Create;
  Result.LoadFromFile(Files);
end;

procedure TGLTextureCube.LoadFromFile(const Files: TCubeFileArray; LoadFlipped: Boolean);
var
  i: Integer;
  pic: TBitmap;
  bitPointer: TBitmapData;
begin
  Activate;
  pic := TBitmap.Create;
  try
    for i := 0 to 5 do
    begin
      pic.LoadFromFile(Files[i]);
      if LoadFlipped then
        pic.FlipVertical;
      pic.Map(TMapAccess.Read, bitPointer);

      glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL_RGBA, pic.Width, pic.Height,
        0, GL_BGRA, GL_UNSIGNED_BYTE, bitPointer.Data);
      pic.Unmap(bitPointer);
    end;
  finally
    pic.Free;
  end;
  // default texture filtering. Without it textures will be black
  glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  SetWrapping(wmClampToEdge);
  Deactivate;
end;

procedure TGLTextureCube.SetParameter(Parameter: GLenum; Value: GLint);
begin
  Activate;
  glTexParameteri(GL_TEXTURE_CUBE_MAP, Parameter, Value);
  Deactivate;
end;

procedure TGLTextureCube.SetWrapping(AMode: TWrapMode);
begin
  SetWrapping(AMode, AMode, AMode);
end;

procedure TGLTextureCube.SetWrapping(ASMode, ATMode, ARMode: TWrapMode);
begin
  Activate;
  glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, Ord(ASMode));
  glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, Ord(ATMode));
  glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, Ord(ARMode));
  Deactivate;
end;

{$ENDREGION}

{$REGION 'TRawTexture'} {

constructor TRawTexture.Create;
begin
  fData := TMemoryStream.Create;
end;

destructor TRawTexture.Destroy;
begin
  fData.Free;
  inherited;
end;

function TRawTexture.GetDataPointer: Pointer;
begin
  Result := fData.Memory;
end;

function TRawTexture.GetPixelFormat: GLuint;
begin
  Result := GL_BGR + fHasAlpha.ToInteger;
end;

procedure TRawTexture.LoadFromFile(AFile: String; LoadFlipped: Boolean);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFile, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream, LoadFlipped);
  finally
    Stream.Free;
  end;
end;

procedure TRawTexture.LoadFromStream(AStream: TStream; LoadFlipped: Boolean);
var
  pic: TBitmap;

  p: ^Byte;
  y: Integer;
  bpl: integer;
begin
  fData.Clear;
  try
    pic := TBitmap.CreateFromStream(AStream);

    fHasAlpha := pic.;
    fWidth := bit.Width;
    fHeight := bit.Height;
    if not fHasAlpha then
      bit.PixelFormat := pf24bit;
    bpl := (3 + fHasAlpha.ToInteger) * fWidth;
    fData.SetSize(bpl * fHeight);

    for y := 0 to fHeight - 1 do
    begin
      if LoadFlipped then
        p := bit.ScanLine[fHeight - 1 - y]
      else
        p := bit.ScanLine[y];
      fData.WriteBuffer(p^, bpl);
    end;
  finally
    bit.Free;
  end;
end;
 }
{$ENDREGION}

{$REGION 'TGLRenderbuffer'}

procedure TGLRenderbuffer.Bind;
begin
  glBindRenderbuffer(GL_RENDERBUFFER, fId);
end;

constructor TGLRenderbuffer.Create;
begin
  glGenRenderbuffers(1, @fId);
end;

constructor TGLRenderbuffer.Create(AType: TGLBufferType; AWidth,
  AHeight: Cardinal);
begin
  Create;
  Initialize(AType, AWidth, AHeight);
end;

destructor TGLRenderbuffer.Destroy;
begin
  glDeleteRenderbuffers(1, @fId);
  inherited;
end;

procedure TGLRenderbuffer.Initialize(AType: TGLBufferType; AWidth,
  AHeight: Cardinal);
begin
  Bind;
  fType := AType;
  glRenderbufferStorage(GL_RENDERBUFFER, Ord(AType), AWidth, AHeight);
  Unbind;
end;

class procedure TGLRenderbuffer.Unbind;
begin
  glBindRenderbuffer(GL_RENDERBUFFER, 0);
end;

{$ENDREGION}

{$REGION 'TGLFramebuffer'}

procedure TGLFramebuffer.AttachBuffer(ATextureBuffer: TGLTexture2D;
  OwnsObject: Boolean; AttachmentLevel: Cardinal);
var
  AttachmentType: TGLAttachementType;
begin
  AttachmentType := GetAttachmentType(ATextureBuffer.InternalFormat);
  if AttachmentType = atColor0 then
  begin
    if not InRange(AttachmentLevel, 0, 31) then
      raise EGLTexture.Create('TextureUnit out of Bounds');
    AttachmentType := TGLAttachementType(Ord(AttachmentType) + AttachmentLevel);
  end;

  glBindFramebuffer(GL_FRAMEBUFFER, fId);
  glFramebufferTexture2D(GL_FRAMEBUFFER, Ord(AttachmentType), GL_TEXTURE_2D, ATextureBuffer.TextureId, 0);
  Unbind;

  if OwnsObject then
    fAttachments.Add(AttachmentType, ATextureBuffer);
end;

procedure TGLFramebuffer.AttachBuffer(ARenderBuffer: TGLRenderbuffer;
  OwnsObject: Boolean; AttachmentLevel: Cardinal);
var
  AttachmentType: TGLAttachementType;
begin
  AttachmentType := GetAttachmentType(ARenderBuffer.InternalFormat);
  if AttachmentType = atColor0 then
  begin
    if not InRange(AttachmentLevel, 0, 31) then
      raise EGLTexture.Create('TextureUnit out of Bounds');
    AttachmentType := TGLAttachementType(Ord(AttachmentType) + AttachmentLevel);
  end;

  glBindFramebuffer(GL_FRAMEBUFFER, fId);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, Ord(AttachmentType), GL_RENDERBUFFER, ARenderBuffer.Id);
  Unbind;

  if OwnsObject then
    fAttachments.Add(AttachmentType, ARenderBuffer);
end;

function TGLFramebuffer.GetAttachmentType(InternalFormat: TGLBufferType): TGLAttachementType;
begin
  case InternalFormat of
  btDepthStencil: Result := atDepthStencil;
  else Result := atColor0;
  end;
end;

procedure TGLFramebuffer.Bind(Target: TGLFramebufferTarget = ftBoth);
begin
  if not fValid then
    raise Exception.Create('Framebuffer not validated or not valid');
  glBindFramebuffer(Ord(Target), fId);
end;

constructor TGLFramebuffer.Create;
begin
  glGenFramebuffers(1, @fId);
  fAttachments := TObjectDictionary<TGLAttachementType, TObject>.Create([doOwnsValues]);
  fValid := false;
end;

destructor TGLFramebuffer.Destroy;
begin
  glDeleteFramebuffers(1, @fId);
  fAttachments.Free;
  inherited;
end;

class procedure TGLFramebuffer.Unbind(Target: TGLFramebufferTarget = ftBoth);
begin
  glBindFramebuffer(Ord(Target), 0);
end;

function TGLFramebuffer.Validate: Boolean;
begin
  glBindFramebuffer(GL_FRAMEBUFFER, fId);
  fValid := glCheckFramebufferStatus(GL_FRAMEBUFFER) = GL_FRAMEBUFFER_COMPLETE;
  Unbind;
  Result := fValid;
end;

{$ENDREGION}

{$REGION 'TGLRenderbufferMultisample'}

procedure TGLRenderbufferMultisample.Initialize(AType: TGLBufferType; AWidth,
  AHeight: Cardinal);
begin
  Initialize(4, AType, AWidth, AHeight);
end;

constructor TGLRenderbufferMultisample.Create(Samples: GLuint;
  AType: TGLBufferType; AWidth, AHeight: Cardinal);
begin
  inherited Create;
  Initialize(Samples, AType, AWidth, AHeight);
end;

procedure TGLRenderbufferMultisample.Initialize(Samples: GLuint;
  AType: TGLBufferType; AWidth, AHeight: Cardinal);
begin
  Bind;
  fType := AType;
  fSamples := Samples;
  glRenderbufferStorageMultisample(GL_RENDERBUFFER, Samples, Ord(AType), AWidth, AHeight);
  Unbind;
end;

{$ENDREGION}

{$REGION 'TGLMeshList'}

constructor TGLMeshList.Create(ACapacity: Integer);
begin
  inherited Create([doOwnsValues], ACapacity);
end;

{$ENDREGION}

{$REGION 'TGLShaderList'}

constructor TGLShaderList.Create(ACapacity: Integer);
begin
  inherited Create([doOwnsValues], ACapacity);
end;

{$ENDREGION}

{$REGION 'TGLTextRenderer'}

constructor TGLTextRenderer.Create;
begin
  fCharList := TDictionary<Char, TFreeTypeChar>.Create;
  fTextureList := TGLTextureList.Create;
  
  fShader := TGLShader.Create;
  fShader.LoadFromSources(vertexShader, fragmentShader);
  fShader.SetInt('tex', 0);
  
  fModel := TGLMesh.Create;
  fModel.LoadFromArray(quadMesh, [texture]);
end;

destructor TGLTextRenderer.Destroy;
begin
  fCharList.Free;
  fTextureList.Free;
  fShader.Free;
  fModel.Free;
  inherited;
end;

procedure TGLTextRenderer.RegisterChars(Chars: String; resolutionDPI: Word; Size: Cardinal;
  AFontFile: String);
var
  ft: TFreeType;
  c: Char;
  e: TPair<Char, TFreeTypeChar>;
  bitPointer: TBitmapData;
  i: Integer;
  gltex: TGLTexture;
  mbuf: TMemoryStream;
begin
  ft := TFreeType.CreateFromFile(AFontFile);
  try
    ft.PixelSize := Size;
    for c in Chars do
      fCharList.TryAdd(c, ft.GetChar(c, resolutionDPI));
  finally
    ft.Free;
  end;

  mbuf := TMemoryStream.Create;
  try 
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    for e in fCharList do
    begin
      mbuf.Clear;
      for i := e.Value.Height - 1 downto 0 do
        mbuf.Write(e.Value.BitmapData[i * e.Value.Width], e.Value.Width);
      
      //mbuf.Write(e.Value.BitmapData, Length(e.Value.BitmapData));
    
      gltex := TGLTexture2D.CreateFromRawStream(mbuf, GL_RED, btRed, e.Value.Width, e.Value.Height);
      if not fTextureList.TryAdd(e.Key, gltex) then
        gltex.Free;
    end;
  finally
    mbuf.Free;
  end;
end;

procedure TGLTextRenderer.RenderText(AString: String; APosition: TVec2;
  AColor: TVec3; AScale: Single = 1);
var
  c: Char;
  ci: TFreeTypeChar;
  pos: TVec2;
begin
  fShader.Use; 
  fShader.SetVec3('color', AColor);

  for c in AString do
  begin
    if c <> ' ' then
    begin
      ci := fCharList[c];
      pos.x := APosition.x + ci.BearingX * AScale;
      pos.y := APosition.y - (ci.Height - ci.BearingY) * AScale;
      fShader.SetMat4('scale', IdentityMat.Scale(ci.Width * AScale, ci.Height * AScale, 1));
      fShader.SetMat4('position', IdentityMat.Translate(pos));
      fTextureList[c].Activate(0);
      fModel.Draw;
    end;
    APosition.x := APosition.x + ci.Advance * AScale;
  end;

  fShader.Leave;   
end;

procedure TGLTextRenderer.SetDrawSize(Left, Right, Bottom, Top: Single);
begin
  fShader.Use;
  fShader.SetMat4('projection', TMat4.Ortho(Left, Right, Bottom, Top, 0, 1));  
  fShader.Leave;
end;

{$ENDREGION}

end.
