unit FreetypeDelphi.dllImports;

interface

const
{$IFDEF WIN64}
  {$DEFINE FT_DLL}
  dlllib = 'freetype64.dll';
{$ENDIF}
{$IFDEF WIN32}
  {$DEFINE FT_DLL}
  dlllib = 'freetype32.dll';
{$ENDIF}

{$IFNDEF FT_DLL}
  {$MESSAGE ERROR 'freetype dll not declared'}
{$ENDIF}

type

{$REGION 'Basic Type declaration'}
  FT_Error = Integer;
  FT_Long = LongInt;
  FT_Int = Integer;
  FT_Short = SmallInt;
  FT_Pos = LongInt;
  FT_UShort = Word;
  FT_UInt = Cardinal;
  FT_Fixed = LongInt;
  FT_ULong = LongWord;
  FT_Int32 = Int32;
  FT_Byte = Byte;
  FT_Bytes = ^FT_Byte;
  FT_F26Dot6 = LongInt;


  FT_String = AnsiChar;
  PFT_String = ^FT_String;

  FT_Bitmap_Size = packed record
    height: FT_Short;
    width: FT_Short;
    size: FT_Pos;
    x_ppem: FT_Pos;
    y_ppem: FT_Pos;
  end;
  PFT_Bitmap_Size = ^FT_Bitmap_Size;

  FT_Generic_Finalizer = reference to procedure(obj: Pointer);

  FT_Generic = packed record
    data: Pointer;
    finalizer: FT_Generic_Finalizer;
  end;

  FT_Vector = packed record
    x: FT_Pos;
    y: FT_Pos;
  end;
  PFT_Vector = ^FT_Vector;

  FT_Outline = packed record
    n_contours: SmallInt;
    n_points: SmallInt;

    points: PFT_Vector;
    tags: PShortInt;
    contours: PSmallInt;

    flags: Integer;
  end;

  FT_Encoding = (
    FT_ENCODING_NONE            =          0,
    FT_ENCODING_UNICODE         = 1970170211,
    FT_ENCODING_MS_SYMBOL       = 1937337698,
    FT_ENCODING_SJIS            = 1936353651,
    FT_ENCODING_PRC             = 1734484000,
    FT_ENCODING_BIG5            = 1651074869,
    FT_ENCODING_WANSUNG         = 2002873971,
    FT_ENCODING_JOHAB           = 1785686113,
    FT_ENCODING_ADOBE_LATIN_1   = 1818326065,
    FT_ENCODING_ADOBE_STANDARD  = 1094995778,
    FT_ENCODING_ADOBE_EXPERT    = 1094992453,
    FT_ENCODING_ADOBE_CUSTOM    = 1094992451,
    FT_ENCODING_APPLE_ROMAN     = 1634889070,
    FT_ENCODING_OLD_LATIN_2     = 1818326066,
    FT_ENCODING_MS_SJIS         = FT_ENCODING_SJIS,
    FT_ENCODING_MS_GB2312       = FT_ENCODING_PRC,
    FT_ENCODING_MS_BIG5         = FT_ENCODING_BIG5,
    FT_ENCODING_MS_WANSUNG      = FT_ENCODING_WANSUNG,
    FT_ENCODING_MS_JOHAB        = FT_ENCODING_JOHAB
    );

  FT_Glyph_Format = (
    FT_GLYPH_FORMAT_NONE      =          0,
    FT_GLYPH_FORMAT_COMPOSITE = 1668246896,
    FT_GLYPH_FORMAT_BITMAP    = 1651078259,
    FT_GLYPH_FORMAT_OUTLINE   = 1869968492,
    FT_GLYPH_FORMAT_PLOTTER   = 1886154612
    );

  FT_CharMap = ^FT_CharMapRec;
  PFT_CharMap = ^FT_CharMap;

  FT_Library = type Pointer;
  PFT_Library = ^FT_Library;

  FT_SubGlyph = type Pointer;
  FT_Slot_Internal = type Pointer;
  FT_Size_Internal = type Pointer;
  FT_Driver = type Pointer;
  FT_Face_Internal = type Pointer;

  FT_Face = ^FT_FaceRec;
  PFT_Face = ^FT_Face;

  FT_Memory = ^FT_MemoryRec;

  FT_Alloc_Func   = reference to function(memory: FT_Memory; size: LongInt): Pointer;
  FT_Free_Func    = reference to procedure(memory: FT_Memory; Block: Pointer);
  FT_Realloc_Func = reference to function(memory: FT_Memory; curr_size, new_size: LongInt; block: Pointer): Pointer;

  FT_MemoryRec = packed record
    user: Pointer;
    alloc: FT_Alloc_Func;
    free: FT_Free_Func;
    realloc: FT_Realloc_Func;
  end;

  FT_StreamDesc = packed record
    value: LongInt;
    pointer: Pointer;
  end;

  FT_Stream = ^FT_StreamRec;

  FT_Stream_IoFunc = reference to function(stream: FT_Stream; offset: LongWord; buffer: PByte; count: LongWord): LongWord;
  FT_Stream_CloseFunc = reference to procedure(stream: FT_Stream);

  FT_StreamRec = packed record
    base: PByte;
    size: LongWord;
    pos: LongWord;

    descriptor: FT_StreamDesc;
    pathname: FT_StreamDesc;
    read: FT_Stream_IoFunc;
    close: FT_Stream_CloseFunc;

    memory: FT_Memory;
    cursor: PByte;
    limit: PByte;
  end;

  FT_Size_Metrics = packed record
    x_ppem: FT_UShort;
    y_ppem: FT_UShort;

    x_scale: FT_Fixed;
    y_scale: FT_Fixed;

    ascender: FT_Pos;
    descender: FT_Pos;
    height: FT_Pos;
    max_advance: FT_Pos;
  end;

  FT_SizeRec = packed record
    face: FT_Face;
    generic: FT_Generic;
    metrics: FT_Size_Metrics;
    internal: FT_Size_Internal;
  end;
  FT_Size = ^FT_SizeRec;

  FT_Bitmap = packed record
    rows: Cardinal;
    width: Cardinal;
    pitch: Integer;
    buffer: PByte;
    num_grays: Word;
    pixel_mode: Byte;
    palette_mode: Byte;
    palette: Pointer;
  end;

  FT_Glyph_Metrics = packed record
    width: FT_Pos;
    height: FT_Pos;

    horiBearingX: FT_Pos;
    horiBearingY: FT_Pos;
    horiAdvance:  FT_Pos;

    vertBearingX: FT_Pos;
    vertBearingY: FT_Pos;
    vertAdvance:  FT_Pos;
  end;

  FT_ListNode = ^FT_ListNodeRec;

  FT_ListNodeRec = packed record
    prev: FT_ListNode;
    next: FT_ListNode;
    data: Pointer;
  end;

  FT_ListRec = packed record
    head: FT_ListNode;
    tail: FT_ListNode;
  end;

  FT_GlyphSlot = ^FT_GlyphSlotRec;
  FT_GlyphSlotRec = packed record
      aLibrary:           FT_Library;
      face:               FT_Face;
      next:               FT_GlyphSlot;
      glyph_index:        FT_UInt;
      generic:            FT_Generic;

      metrics:            FT_Glyph_Metrics;
      linearHoriAdvance:  FT_Fixed;
      linearVertAdvance:  FT_Fixed;
      advance:            FT_Vector;

      format:             FT_Glyph_Format;

      bitmap:             FT_Bitmap;
      bitmap_left:        FT_Int;
      bitmap_top:         FT_Int;

      outline:            FT_Outline;

      num_subglyphs:      FT_UInt;
      subglyphs:          FT_SubGlyph;

      control_data:       Pointer;
      control_len:        FT_Long;

      lsb_delta:          FT_Pos;
      rsb_delta:          FT_Pos;

      other:              Pointer;

      internal:           FT_Slot_Internal;
  end;

  FT_BBox = packed record
    xMin, yMin: FT_Pos;
    xMax, yMax: FT_Pos;
  end;

  FT_FaceRec = packed record
    num_faces: FT_Long;
    face_index: FT_Long;

    face_flags: FT_Long;
    style_flags: FT_Long;

    num_glyphs: FT_Long;

    family_name: PFT_String;
    style_name: PFT_String;

    num_fixed_sizes: FT_Int;
    available_sizes: PFT_Bitmap_Size;

    num_charmaps: FT_Int;
    charmaps: PFT_CharMap;

    generic: FT_Generic;

    bbox: FT_BBox;

    units_per_EM: FT_UShort;

    ascender: FT_Short;
    descender: FT_Short;
    height: FT_Short;

    max_advance_width: FT_Short;
    max_advance_height: FT_Short;

    underline_position: FT_Short;
    underline_thickness: FT_Short;

    glyph: FT_GlyphSlot;
    size: FT_Size;
    charmap: FT_CharMap;

    driver: FT_Driver;
    memory: FT_Memory;
    stream: FT_Stream;

    sizes_list: FT_ListRec;

    autohint: FT_Generic;
    extensions: Pointer;

    internal: FT_Face_Internal;
  end;

  FT_CharMapRec = packed record
    face: FT_Face;
    encoding: FT_Encoding;
    platform_id: FT_UShort;
    encoding_id: FT_UShort;
  end;
{$ENDREGION}

const
  FT_LOAD_DEFAULT         = 0;
  FT_LOAD_NO_SCALE        = 1;
  FT_LOAD_NO_HINTING      = 2;
  FT_LOAD_RENDER          = 4;
  FT_LOAD_NO_BITMAP       = 8;
  FT_LOAD_VERTICAL_LAYOUT = 16;
  FT_LOAD_FORCE_AUTOHINT  = 32;
  FT_LOAD_CROP_BITMAP     = 64;
  FT_LOAD_PEDANTIC        = 128;
  FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH = 512;
  FT_LOAD_NO_RESCUE       = 1024;
  FT_LOAD_IGNORE_TRANSFORM = 2048;
  FT_LOAD_MONOCHROME      = 4096;
  FT_LOAD_LINEAR_DESIGN   = 8192;
  FT_LOAD_NO_AUTOHINT     = 32768;
  FT_LOAD_COLOR           = 1048578;
  FT_LOAD_COMPUTE_METRICS = 2097152;
  FT_LOAD_BITMAP_METRICS_ONLY = 4194304;

function FT_Init_FreeType(aLibrary: PFT_Library): FT_Error;
  cdecl; external dlllib;
function FT_Done_FreeType(aLibrary: FT_Library): FT_Error;
  cdecl; external dlllib;
function FT_New_Face(aLibrary: FT_Library; Path: PAnsiChar; face_index: FT_Long; aFace: PFT_Face): FT_Error;
  cdecl; external dlllib;
function FT_New_Memory_Face(aLibrary: FT_Library; file_base: FT_Bytes; file_size: FT_Long; face_index: FT_Long; aFace: PFT_Face): FT_Error;
  cdecl; external dlllib;
function FT_Done_Face(aFace: FT_Face): FT_Error;
  cdecl; external dlllib;
function FT_Set_Pixel_Sizes(face: FT_Face; pixel_width: FT_UInt; pixel_height: FT_UInt): FT_Error;
  cdecl; external dlllib;
function FT_Load_Char(face: FT_Face; char_code: FT_ULong; load_flags: FT_Int32): FT_Error;
  cdecl; external dlllib;
function FT_Set_Char_Size(face: FT_Face; char_width: FT_F26Dot6; char_height: FT_F26Dot6; horz_resolution, vert_Resolution: FT_UInt): FT_Error;
  cdecl; external dlllib;

implementation

end.
