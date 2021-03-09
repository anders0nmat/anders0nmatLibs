unit Parser.Operators;

interface

uses Parser, SysUtils, Character, Generics.Collections, StrUtils, Math;

type
  TExpressionList = TObjectList<TEvaluationBase>;

  TEvaluationContainer = class(TEvaluationBase)
  protected
    fArgs: TExpressionList;

    procedure SetOnVariable(Value: TVarFunc); override;
  public
    constructor Create(AParent: TEvaluationParent); override;
    destructor Destroy; override;

    property Args: TExpressionList read fArgs;
  end;

  TEvaluationConst = class(TEvaluationBase)
  private
    fConst: Double;
  public
    constructor Create(AParent: TEvaluationParent; AConst: Double); reintroduce;

    class function Parse(AParent: TEvaluationParent; AString: String): TEvaluationBase; override;

    function Evaluate: Double; override;
  end;

  TEvaluationAdd = class(TEvaluationContainer)
  public
    class function Parse(AParent: TEvaluationParent; AString: String): TEvaluationBase; override;

    function Evaluate: Double; override;
  end;

  TEvaluationSubtract = class(TEvaluationContainer)
  public
    class function Parse(AParent: TEvaluationParent; AString: String): TEvaluationBase; override;

    function Evaluate: Double; override;
  end;

  TEvaluationMultiply = class(TEvaluationContainer)
  public
    class function Parse(AParent: TEvaluationParent; AString: String): TEvaluationBase; override;

    function Evaluate: Double; override;
  end;

  TEvaluationDivide = class(TEvaluationContainer)
  public
    class function Parse(AParent: TEvaluationParent; AString: String): TEvaluationBase; override;

    function Evaluate: Double; override;
  end;

  TEvaluationVar = class(TEvaluationBase)
  private
    fVarName: String;
  protected
    procedure SetOnVariable(Value: TVarFunc); override;
  public
    constructor Create(AParent: TEvaluationParent; AVarName: String); reintroduce;

    class function Parse(AParent: TEvaluationParent; AString: String): TEvaluationBase; override;

    function Evaluate: Double; override;
  end;

  TEvaluationParenthesis = class(TEvaluationBase)
  public
    class function Parse(AParent: TEvaluationParent; AString: String): TEvaluationBase; override;
  end;

  TEvaluationFunc = class(TEvaluationContainer)
  private type
    TExpressionFunction = record
      FuncName: String;
      Args: Integer;
    end;
  private const
    ValidFunctions: array[0..6] of TExpressionFunction = (
      (FuncName: 'sin'; Args: 1),
      (FuncName: 'cos'; Args: 1),
      (FuncName: 'tan'; Args: 1),
      (FuncName: 'pow'; Args: 2),
      (FuncName: 'abs'; Args: 1),
      (FuncName: 'sqr'; Args: 1),
      (FuncName: 'sqrt'; Args: 1)
      );
  private
    fFunc: String;
  public
    constructor Create(AParent: TEvaluationParent; AFunc: String); reintroduce;

    class function Parse(AParent: TEvaluationParent; AString: String): TEvaluationBase; override;

    function Evaluate: Double; override;
  end;

implementation

{$REGION 'TEvaluationConst'}

constructor TEvaluationConst.Create(AParent: TEvaluationParent; AConst: Double);
begin
  inherited Create(AParent);
  fConst := AConst;
end;

function TEvaluationConst.Evaluate: Double;
begin
  Result := fConst;
end;

class function TEvaluationConst.Parse(AParent: TEvaluationParent; AString: String): TEvaluationBase;
var
  d: Double;
  fs: TFormatSettings;
begin
  fs.ThousandSeparator := ' ';
  fs.DecimalSeparator := '.';
  if not TryStrToFloat(AString, d, fs) then
    Result := ExpressionOrder.FindNext(Self).Parse(AParent, AString)
  else
    Result := TEvaluationConst.Create(AParent, d);
end;

{$ENDREGION}

{$REGION 'TEvaluationAdd'}

function TEvaluationAdd.Evaluate: Double;
var
  e: TEvaluationBase;
begin
  Result := 0;
  for e in fArgs do
    Result := Result + e.Evaluate;
end;

class function TEvaluationAdd.Parse(AParent: TEvaluationParent; AString: String): TEvaluationBase;
var
  sArr: TArray<String>;
  s: String;
  NextClass: TEvaluationClass;
begin
  sArr := SplitExpr(AString, '+');

  NextClass := ExpressionOrder.FindNext(Self);
  if Length(sArr) = 1 then
  begin
    Result := NextClass.Parse(AParent, sArr[0]);
    exit;
  end;

  Result := TEvaluationAdd.Create(AParent);

  for s in sArr do
  begin
    if s = '' then
      continue;
    TEvaluationAdd(Result).Args.Add(NextClass.Parse(AParent, s));
  end;
end;

{$ENDREGION}

{$REGION 'TEvaluationSubtract'}

function TEvaluationSubtract.Evaluate: Double;
var
  i: Integer;
begin
  Result := fArgs[0].Evaluate;
  for i := 1 to fArgs.Count - 1 do
    Result := Result - fArgs[i].Evaluate;
end;

class function TEvaluationSubtract.Parse(AParent: TEvaluationParent; AString: String): TEvaluationBase;
var
  sArr: TArray<String>;
  s: String;
  NextClass: TEvaluationClass;
begin
  sArr := SplitExpr(AString, '-');

  NextClass := ExpressionOrder.FindNext(Self);
  if Length(sArr) = 1 then
  begin
    Result := NextClass.Parse(AParent, sArr[0]);
    exit;
  end;

  Result := TEvaluationSubtract.Create(AParent);

  if sArr[0] = '' then
  begin
    TEvaluationSubtract(Result).Args.Add(TEvaluationMultiply.Parse(AParent, '-1*'+sArr[1]));
    sArr[1] := '';
  end;

  for s in sArr do
  begin
    if s = '' then
      continue;
    TEvaluationSubtract(Result).Args.Add(NextClass.Parse(AParent, s));
  end;
end;

{$ENDREGION}

{$REGION 'TEvaluationMultiply'}

function TEvaluationMultiply.Evaluate: Double;
var
  e: TEvaluationBase;
begin
  Result := 1;
  for e in fArgs do
    Result := Result * e.Evaluate;
end;

class function TEvaluationMultiply.Parse(AParent: TEvaluationParent; AString: String): TEvaluationBase;
var
  sArr: TArray<String>;
  s: String;
  NextClass: TEvaluationClass;
  i, LastIndex: Integer;
begin
  // Implicit multiplication
  s := '';
  LastIndex := 0;
  for i := 2 to AString.Length do
  begin
    if ((AString[i - 1].IsLetter <> AString[i].IsLetter) and (AString[i - 1].IsNumber <> AString[i].IsNumber))
      or (AString[i - 1].IsDigit and (AString[i] = '('))
      or (AString[i].IsDigit and (AString[i - 1] = ')')) or (AString[i].IsLetter and (AString[i - 1] = ')')) then
    begin
      s := s + AString.Substring(lastIndex, i - lastIndex - 1) + '*' + AString[i];
      lastIndex := i;
    end;
  end;

  if s <> '' then
  begin
    s := s + AString.Substring(LastIndex, AString.Length - LastIndex);
    AString := s;
  end;

  sArr := SplitExpr(AString, '*');

  NextClass := ExpressionOrder.FindNext(Self);
  if Length(sArr) = 1 then
  begin
    Result := NextClass.Parse(AParent, sArr[0]);
    exit;
  end;

  Result := Self.Create(AParent);

  for s in sArr do
  begin
    if s = '' then
      continue;
    TEvaluationMultiply(Result).Args.Add(NextClass.Parse(AParent, s));
  end;
end;

{$ENDREGION}

{$REGION 'TEvaluationDivide'}

function TEvaluationDivide.Evaluate: Double;
var
  i: Integer;
begin
  Result := fArgs[0].Evaluate;
  for i := 1 to fArgs.Count - 1 do
    Result := Result / fArgs[i].Evaluate;
end;

class function TEvaluationDivide.Parse(AParent: TEvaluationParent; AString: String): TEvaluationBase;
var
  sArr: TArray<String>;
  s: String;
  NextClass: TEvaluationClass;
begin
  sArr := SplitExpr(AString, '/');

  NextClass := ExpressionOrder.FindNext(Self);
  if Length(sArr) = 1 then
  begin
    Result := NextClass.Parse(AParent, sArr[0]);
    exit;
  end;

  Result := Self.Create(AParent);

  for s in sArr do
  begin
    if s = '' then
      continue;
    TEvaluationDivide(Result).Args.Add(NextClass.Parse(AParent, s));
  end;
end;

{$ENDREGION}

{$REGION 'TEvaluationVar'}

constructor TEvaluationVar.Create(AParent: TEvaluationParent; AVarName: String);
begin
  inherited Create(AParent);
  fVarName := AVarName;
  OnVariable(Add, fVarName);
end;

function TEvaluationVar.Evaluate: Double;
begin
  Result := OnVariable(Get, fVarName);
end;

class function TEvaluationVar.Parse(AParent: TEvaluationParent; AString: String): TEvaluationBase;
var
  NextClass: TEvaluationClass;
  c: Char;
begin
  NextClass := ExpressionOrder.FindNext(Self);
  for c in AString do
  begin
    if not c.IsLetter then
    begin
      Result := NextClass.Parse(AParent, AString);
      exit;
    end;
  end;
  Result := Self.Create(AParent, AString);
end;

procedure TEvaluationVar.SetOnVariable(Value: TVarFunc);
begin
  inherited;
  OnVariable(Add, fVarName);
end;

{$ENDREGION}

{$REGION 'TEvaluationParenthesis'}

class function TEvaluationParenthesis.Parse(AParent: TEvaluationParent;
  AString: String): TEvaluationBase;
begin
  if AString.StartsWith('(') and AString.EndsWith(')') then
    Result := TExpression.Parse(AParent, AString.Substring(1, AString.Length - 2), false)
  else
    raise EInvalidString.Create('Invalid Expression');
end;

{$ENDREGION}

{$REGION 'TEvaluationContainer'}

constructor TEvaluationContainer.Create(AParent: TEvaluationParent);
begin
  fArgs := TExpressionList.Create;
end;

destructor TEvaluationContainer.Destroy;
begin
  fArgs.Free;
  inherited;
end;

procedure TEvaluationContainer.SetOnVariable(Value: TVarFunc);
var
  e: TEvaluationBase;
begin
  inherited;
  for e in fArgs do
    e.OnVariable := fOnVariable;
end;

{$ENDREGION}

{$REGION 'TEvaluationFunc'}

constructor TEvaluationFunc.Create(AParent: TEvaluationParent; AFunc: String);
begin
  inherited Create(AParent);
  fFunc := AFunc;
end;

function TEvaluationFunc.Evaluate: Double;
var
  i, idx: Integer;
begin
  idx := -1;
  for i := 0 to High(ValidFunctions) do
    if ValidFunctions[i].FuncName = fFunc then
    begin
      idx := i;
      break;
    end;

  case idx of
  0: Result := Sin(fArgs[0].Evaluate);
  1: Result := Cos(fArgs[0].Evaluate);
  2: Result := Tan(fArgs[0].Evaluate);
  3: Result := Power(fArgs[0].Evaluate, fArgs[1].Evaluate);
  4: Result := Abs(fArgs[0].Evaluate);
  5: Result := Sqr(fArgs[0].Evaluate);
  6: Result := Sqrt(fArgs[0].Evaluate);
  else
    Result := 0;
  end;
end;

class function TEvaluationFunc.Parse(AParent: TEvaluationParent;
  AString: String): TEvaluationBase;
var
  sArr: TArray<String>;
  NextClass: TEvaluationClass;
  s, funcArgs: String;
  e, func: TExpressionFunction;
begin
  func.FuncName := '';
  func.Args := 0;
  for e in ValidFunctions do
  begin
    if StartsText(e.FuncName + '(', AString) then
    begin
      func := e;
      funcArgs := AString.Substring(e.FuncName.Length);
    end;
  end;

  NextClass := ExpressionOrder.FindNext(Self);
  if func.FuncName = '' then
  begin
    Result := NextClass.Parse(AParent, AString);
    exit;
  end;

  if not (funcArgs.StartsWith('(') and funcArgs.EndsWith(')')) then
    raise EInvalidString.Create('Invalid function Parameters: ' + funcArgs)
  else
    funcArgs := funcArgs.Substring(1, funcArgs.Length - 2);

  sArr := SplitExpr(funcArgs, ',');

  if Length(sArr) < func.Args then
    raise EInvalidString.Create('Not enough arguments');

  Result := Self.Create(AParent, func.FuncName);

  for s in sArr do
  begin
    if s = '' then
      continue;
    TEvaluationFunc(Result).Args.Add(TExpression.Parse(AParent, s, false));
  end;
end;

end.
