unit Parser;

interface

uses Generics.Collections, Generics.Defaults, SysUtils, StrUtils;

type
  EInvalidString = class(Exception);
  EExpressionError = class(Exception);
  EVarNotFound = class(Exception);

  TEvaluationBase = class;
  TEvaluationParent = TObject;

  TVarCommand = (Add, Get);

  TVarFunc = function(ACommand: TVarCommand; AVar: String): Double of object;

  TEvaluationBase = class
  private
    function DefOnVariable(ACommand: TVarCommand; AVar: String): Double;
  protected
    fParent: TEvaluationParent;

    fOnVariable: TVarFunc;

    function GetOnVariable: TVarFunc;
    procedure SetOnVariable(Value: TVarFunc); virtual;
  public
    constructor Create(AParent: TEvaluationParent); virtual;

    function Evaluate: Double; virtual; abstract;
    class function Parse(AParent: TEvaluationParent; AString: String): TEvaluationBase; virtual; abstract;

    class function SplitExpr(AString: String; const AChar: Char): TArray<String>;

    property Parent: TEvaluationParent read fParent;

    property OnVariable: TVarFunc read GetOnVariable write SetOnVariable;
  end;

  TEvaluationClass = class of TEvaluationBase;

  TExpression = class
  private
    fExpression: TEvaluationBase;
    fVariables: TDictionary<string, Double>;
    fExpressionString: String;

    function GetVars(ACommand: TVarCommand; AVar: String): Double;
    procedure SetExpression(const Value: TEvaluationBase);
    procedure SetExpressionString(const Value: String);
  public
    constructor Create;
    constructor CreateFromString(AString: String; IgnoreCase: Boolean = true);
    destructor Destroy; override;

    procedure ParseString(AString: String; IgnoreCase: Boolean = true);

    class function Parse(AParent: TObject; AString: String; IgnoreCase: Boolean): TEvaluationBase;

    function Result: Double;

    property Variables: TDictionary<String, Double> read fVariables;
    property Expression: TEvaluationBase read fExpression write SetExpression;
    property ExpressionString: String read fExpressionString write SetExpressionString;
  end;

  TExprOrder = record
    Priority: Integer;
    Handler: TEvaluationClass;
    constructor Create(APriority: Integer; AHandler: TEvaluationClass);
  end;

  TExprOrderList = class
    fIndex: Integer;
    fList: TList<TExprOrder>;
  public
    constructor Create;
    destructor Destroy; override;

    function FindNext(AClass: TEvaluationClass): TEvaluationClass;
    function First: TEvaluationClass;

    procedure Add(AItem: TExprOrder); overload;
    procedure Add(APriority: Integer; AHandler: TEvaluationClass); overload;
  end;

var
  ExpressionOrder: TExprOrderList;

implementation

uses Parser.Operators;

{$REGION 'TExpression'}

constructor TExpression.Create;
begin
  fVariables := TDictionary<String, Double>.Create;
  fExpressionString := '';
end;

destructor TExpression.Destroy;
begin
  fExpression.Free;
  fVariables.Free;
  inherited;
end;

function TExpression.GetVars(ACommand: TVarCommand; AVar: String): Double;
begin
  Result := Double.NaN;
  case ACommand of
    Add: 
      begin
        fVariables.Add(AVar, Double.NaN);
      end;
    Get: 
      begin
        if not fVariables.ContainsKey(AVar) then
          raise EVarNotFound.Create('Variable not defined: ' + AVar);
        Result := fVariables[AVar];
      end;
  end;
end;

class function TExpression.Parse(AParent: TObject; AString: String; IgnoreCase: Boolean): TEvaluationBase;
var
  bCount: Integer;
  c: Char;
begin
  AString := AString.Replace(' ', '', [rfReplaceAll]);
  if IgnoreCase then
    AString := AString.ToLower;

  bCount := 0;
  for c in AString do
    case c of
    '(': Inc(bCount);
    ')': Dec(bCount);
    end;

  if bCount > 0 then
    raise EInvalidString.Create('Not all Parenthesis are closed/opened');

  Result := ExpressionOrder.First.Parse(AParent, AString);
end;

procedure TExpression.ParseString(AString: String; IgnoreCase: Boolean);
begin
  Expression := Parse(Self, AString, IgnoreCase);
  Expression.OnVariable := GetVars;
  fExpressionString := AString;
end;

constructor TExpression.CreateFromString(AString: String; IgnoreCase: Boolean);
begin
  Create;
  fExpression := Parse(Self, AString, IgnoreCase);
  fExpression.OnVariable := GetVars;
  fExpressionString := AString;
end;

function TExpression.Result: Double;
begin
  Result := fExpression.Evaluate;
end;

procedure TExpression.SetExpression(const Value: TEvaluationBase);
begin
  if Value <> fExpression then
  begin
    fExpression.Free;
    fExpression := Value;
  end;
end;

procedure TExpression.SetExpressionString(const Value: String);
begin
  if Value <> fExpressionString then
  begin
    fExpressionString := Value;
    ParseString(fExpressionString);
  end;
end;

procedure TEvaluationBase.SetOnVariable(Value: TVarFunc);
begin
  fOnVariable := Value;
end;

class function TEvaluationBase.SplitExpr(AString: String; const AChar: Char): TArray<String>;
var
  i, bCount, lastIndex, arrLen, currSplit: Integer;
  c: Char;
begin
  bCount := 0;
  arrLen := 0;

  for c in AString do
  begin
    if c = '(' then Inc(bCount)
    else if c = ')' then Dec(bCount)
    else if (c = AChar) and (bCount = 0) then Inc(arrLen);
  end;

  SetLength(Result, arrLen + 1);
  bCount := 0;
  currSplit := 0;
  lastIndex := 0;
  for i := 1 to AString.Length do
  begin
    if AString[i] = '(' then Inc(bCount)
    else if AString[i] = ')' then Dec(bCount)
    else if (AString[i] = AChar) and (bCount = 0) then
    begin
      Result[currSplit] := AString.Substring(lastIndex, i - lastIndex - 1); // String.Substring Index starts with 0
      Inc(currSplit);
      lastIndex := i;
    end;
  end;

  Result[currSplit] := AString.Substring(lastIndex, AString.Length - lastIndex);
end;

{$ENDREGION}

{$REGION 'TExprOrderList'}

procedure TExprOrderList.Add(AItem: TExprOrder);
begin
  fList.Add(AItem);
  fList.Sort;
end;

procedure TExprOrderList.Add(APriority: Integer; AHandler: TEvaluationClass);
begin
  Add(TExprOrder.Create(APriority, AHandler));
end;

constructor TExprOrderList.Create;
var
  cp: TComparison<TExprOrder>;
begin
  cp :=
    function(const Left, Right: TExprOrder): Integer
    begin
      Result := Left.Priority - Right.Priority;
    end;

  fList := TList<TExprOrder>.Create(TComparer<TExprOrder>.Construct(cp));
  fIndex := 0;
end;

destructor TExprOrderList.Destroy;
begin
  fList.Free;
  inherited;
end;

function TExprOrderList.FindNext(AClass: TEvaluationClass): TEvaluationClass;
var
  i: Integer;
begin
  Result := First;
  for i := 0 to fList.Count - 1 do
  begin
    if fList[i].Handler = AClass then
    begin
      Result := fList[i + 1].Handler;
      exit;
    end;
  end;
end;

function TExprOrderList.First: TEvaluationClass;
begin
  Result := fList.First.Handler;
end;

{$ENDREGION}

{$REGION 'TExprOrder'}

constructor TExprOrder.Create(APriority: Integer; AHandler: TEvaluationClass);
begin
  Priority := APriority;
  Handler := AHandler;
end;

{$ENDREGION}

{$REGION 'TEvaluationBase'}

constructor TEvaluationBase.Create(AParent: TObject);
begin
  fParent := AParent;
end;

function TEvaluationBase.DefOnVariable(ACommand: TVarCommand;
  AVar: String): Double;
begin
  Result := 0;
end;

function TEvaluationBase.GetOnVariable: TVarFunc;
begin
  if not Assigned(fOnVariable) then
  begin
    if Assigned(fParent) and (fParent is TEvaluationBase) then
      Result := (fParent as TEvaluationBase).OnVariable
    else
      Result := DefOnVariable;
  end
  else
    Result := fOnVariable;
end;

{$ENDREGION}

initialization

  ExpressionOrder := TExprOrderList.Create;

  ExpressionOrder.Add(0, TEvaluationAdd);
  ExpressionOrder.Add(1, TEvaluationSubtract);
  ExpressionOrder.Add(2, TEvaluationMultiply);
  ExpressionOrder.Add(3, TEvaluationDivide);

  ExpressionOrder.Add(10, TEvaluationConst);
  ExpressionOrder.Add(11, TEvaluationFunc);
  ExpressionOrder.Add(12, TEvaluationVar);

  ExpressionOrder.Add(13, TEvaluationParenthesis);

finalization

  ExpressionOrder.Free;

end.
