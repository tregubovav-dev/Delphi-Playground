(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

unit Playground.Helpers.SimpleTypes;

interface

uses
  System.SysUtils;

type
  // ---------------------------------------------------------------------------
  // TMyBool - Distinct Boolean Type
  // Demonstrates how to attach a helper to a specific boolean usage
  // without conflicting with the global Boolean type.
  // ---------------------------------------------------------------------------
  TMyBool = type boolean;

  /// <summary>
  ///   Helper for the distinct type TMyBool.
  ///   Provides conversion and string formatting utilities.
  /// </summary>
  TMyBoolHelper = record helper for TMyBool
  private
    function GetAsInteger: integer; {$IFNDEF DEBUG}inline;{$ENDIF}
    procedure SetAsInteger(Value: integer); {$IFNDEF DEBUG}inline;{$ENDIF}
  public
    /// <summary>Converts TMyBool to Integer (1=True, 0=False).</summary>
    class function ToInteger(const Value: TMyBool): integer; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Converts Integer to TMyBool (0=False, <>0=True).</summary>
    class function FromInteger(const Value: integer): TMyBool; static;
       {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Returns one of two strings based on the boolean value.</summary>
    class function ToString(const Value: TMyBool; const ATrueStr,
      AFalseStr: string): string; overload; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Parses a string into TMyBool (Factory Method).</summary>
    /// <exception cref="EConvertError">Thrown if string matches neither option.</exception>
    class function FromString(const Value, ATrueStr, AFalseStr: string;
      ACaseSensitive: boolean): TMyBool;
      overload; static; {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Attempts to parse a string into TMyBool safely.</summary>
    class function TryFromString(const Value, ATrueStr, AFalseStr: string;
      ACaseSensitive: boolean; out AResultOut: TMyBool): boolean;
      overload; static; {$IFNDEF DEBUG}inline;{$ENDIF}

    // Instance Methods (Fluent Syntax)
    function ToString(const ATrueStr, AFalseStr: string): string;
      overload; {$IFNDEF DEBUG}inline;{$ENDIF}
    function TryFromString(const Value, ATrueStr, AFalseStr: string;
      ACaseSensitive: boolean): boolean;
      overload; {$IFNDEF DEBUG}inline;{$ENDIF}

    property AsInteger: integer read GetAsInteger write SetAsInteger;
  end;


  // ---------------------------------------------------------------------------
  // TMyInt - Distinct Integer Type
  // Demonstrates adding domain-specific logic to integers (e.g., IDs, Counts).
  // ---------------------------------------------------------------------------
  TMyInt = type integer;

  /// <summary>
  ///   Helper for TMyInt providing range checking and value analysis.
  /// </summary>
  TMyIntHelper = record helper for TMyInt
  public
    /// <summary>Checks if Value is >= Min and <= Max.</summary>
    class function IsBetween(const Value: TMyInt;
      const AMin, AMax: integer): boolean; overload; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Instance version of IsBetween.</summary>
    function IsBetween(const AMin, AMax: integer): boolean;
      overload; {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Clamps the value within the defined range.</summary>
    class function EnsureBetween(const Value: TMyInt;
      const AMin, AMax: integer): integer; overload; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Instance version of EnsureBetween.</summary>
    function EnsureBetween(const AMin, AMax: integer): integer;
      overload; {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Returns True if the number is Even.</summary>
    class function IsEven(const Value: TMyInt): boolean;
      overload; static; {$IFNDEF DEBUG}inline;{$ENDIF}
    function IsEven: boolean; overload; {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Returns True if value equals Integer.MinValue.</summary>
    class function IsMin(Value: TMyInt): boolean;
      overload; static; {$IFNDEF DEBUG}inline;{$ENDIF}
    function IsMin: boolean; overload; {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Returns True if value equals Integer.MaxValue.</summary>
    class function IsMax(Value: TMyInt): boolean;
      overload; static; {$IFNDEF DEBUG}inline;{$ENDIF}
    function IsMax: boolean; overload; {$IFNDEF DEBUG}inline;{$ENDIF}
  end;

  // ---------------------------------------------------------------------------
  // TFruit - Enumeration Type
  // Demonstrates attaching metadata (Names) to an Enum via Helper.
  // ---------------------------------------------------------------------------
  TFruit = (frUnknown, frApple, frCitrus, frOrange, frPapaya, frPear);

  // ---------------------------------------------------------------------------
  // TFruitHelper
  // ---------------------------------------------------------------------------
  /// <summary>
  ///   Helper for the TFruit enumeration providing conversion and string lookup.
  /// </summary>
  TFruitHelper = record helper for TFruit
  public const
    /// <summary>The first valid fruit (skipping Unknown).</summary>
    cMinFruit = Succ(Low(TFruit));
    /// <summary>The last valid fruit.</summary>
    cMaxFruit = High(TFruit);
    /// <summary>The default/invalid fruit value.</summary>
    cUnknownFruit = Low(TFruit);

  public type
    /// <summary>Defines a mapping array for all fruit names.</summary>
    TNames = array[TFruit] of string;

  private
    function GetAsInteger: integer; {$IFNDEF DEBUG}inline;{$ENDIF}
    procedure SetAsInteger(Value: integer); {$IFNDEF DEBUG}inline;{$ENDIF}

  public
    /// <summary>Converts the Enum to its ordinal integer value.</summary>
    class function ToInteger(const Value: TFruit): integer; overload; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>
    ///   Safely converts an integer to TFruit.
    ///   Returns frUnknown if the integer is out of valid range.
    /// </summary>
    class function FromInteger(const Value: integer): TFruit; overload; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Returns the string representation from the provided Name array.</summary>
    class function ToString(const Value: TFruit;
      const ANames: TNames): string; overload; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Instance version. Returns string from Name array for Self.</summary>
    function ToString(const ANames: TNames): string; overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Parses string to Enum (Case Sensitive/Insensitive).</summary>
    /// <returns>The matching TFruit or frUnknown if not found.</returns>
    class function FromString(const Value: string; const ANames: TNames;
      ACaseSensitive: boolean): TFruit; static; {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Gets or Sets the ordinal value of the fruit.</summary>
    property AsInteger: integer read GetAsInteger write SetAsInteger;
  end;

  // ---------------------------------------------------------------------------
  // TStringArray - Dynamic Array Helper
  // Demonstrates fluent manipulation of dynamic arrays.
  // ---------------------------------------------------------------------------
  TStringArray = TArray<string>;

  // ---------------------------------------------------------------------------
  // TStringArrayHelper
  // ---------------------------------------------------------------------------
  /// <summary>
  ///   Helper for TArray&lt;string&gt; providing fluent list-like manipulations.
  /// </summary>
  TStringArrayHelper = record helper for TStringArray
  private
    function GetCount: NativeUInt; {$IFNDEF DEBUG}inline;{$ENDIF}
    procedure SetCount(Value: NativeUInt); {$IFNDEF DEBUG}inline;{$ENDIF}

    function GetString(Value: NativeUInt): string;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    procedure SetString(Index: NativeUInt; const Value: string);
      {$IFNDEF DEBUG}inline;{$ENDIF}
  public
    /// <summary>
    ///   Initializes the array with a set of strings.
    ///   Usage: var Arr := TStringArray.Create('A', 'B');
    /// </summary>
    constructor Create(const AStrings: array of string);

    /// <summary>Appends a string to the end of the array.</summary>
    /// <returns>The modified array (Self).</returns>
    class function Add(AArray: TStringArray;
      const Value: string): TStringArray; overload; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Instance version. Appends string to Self.</summary>
    function Add(const Value: string): TStringArray; overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Inserts a string at the specified index.</summary>
    class function Insert(AArray: TStringArray;
      const Value: string; AIndex: NativeUInt): TStringArray; overload; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Instance version. Inserts string into Self.</summary>
    function Insert(const Value: string; AIndex: NativeUInt): TStringArray;
      overload; {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Removes N items starting at Index.</summary>
    class function Delete(AArray: TStringArray;
      AIndex, ACount: NativeUInt): TStringArray; overload; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Instance version. Removes N items from Self.</summary>
    function Delete(AIndex, ACount: NativeUInt): TStringArray; overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>
    ///   Concatenates all elements into a single string using a separator.
    ///   Optimized using System.Move for performance.
    /// </summary>
    class function Join(ASeparator: Char; const AArray: TStringArray): string;
      overload; static; {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Instance version. Joins Self with separator.</summary>
    function Join(ASeparator: char): string; overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Gets or sets the number of elements in the array.</summary>
    property Count: NativeUInt read GetCount write SetCount;

    /// <summary>Accesses elements by Index.</summary>
    property &String[Index: NativeUInt]: string read GetString write SetString;
  end;

implementation

uses
  System.StrUtils,
  System.SysConst;

{ TMyBoolHelper }

function TMyBoolHelper.GetAsInteger: integer;
begin
  Result:=ToInteger(Self);
end;

procedure TMyBoolHelper.SetAsInteger(Value: integer);
begin
  Self:=FromInteger(Value);
end;

class function TMyBoolHelper.FromInteger(const Value: integer): TMyBool;
begin
  Result:=not (Value = 0);
end;

class function TMyBoolHelper.ToInteger(const Value: TMyBool): integer;
begin
  Result:=integer(Value) and $1;
end;

class function TMyBoolHelper.ToString(const Value: TMyBool;
  const ATrueStr, AFalseStr: string): string;
begin
  if Value then
    Result:=ATrueStr
  else
    Result:=AFalseStr;
end;

class function TMyBoolHelper.FromString(const Value, ATrueStr,
  AFalseStr: string; ACaseSensitive: boolean): TMyBool;
begin
  if not TryFromString(Value, ATrueStr, AFalseStr,
    ACaseSensitive, Result) then
    raise EConvertError.CreateFmt('Error converting string "%s" to boolean', [Value]);
end;

class function TMyBoolHelper.TryFromString(const Value, ATrueStr,
  AFalseStr: string; ACaseSensitive: boolean; out AResultOut: TMyBool): boolean;
begin
  if ACaseSensitive then
  begin
    if SameStr(Value, ATrueStr) then
    begin
      AResultOut:=True;
      Exit(True);
    end;

    if SameStr(Value, AFalseStr) then
    begin
      AResultOut:=False;
      Exit(True);
    end;
  end
  else
  begin
    if SameText(Value, ATrueStr) then
    begin
      AResultOut:=True;
      Exit(True);
    end;

    if SameText(Value, AFalseStr) then
    begin
      AResultOut:=False;
      Exit(True);
    end;
  end;
  Result:=False;
end;

function TMyBoolHelper.ToString(const ATrueStr, AFalseStr: string): string;
begin
  Result:=ToString(Self, ATrueStr, AFalseStr);
end;

function TMyBoolHelper.TryFromString(const Value, ATrueStr, AFalseStr: string;
  ACaseSensitive: boolean): boolean;
begin
  Result:=TryFromString(Value, ATrueStr, AFalseStr, ACaseSensitive, Self);
end;

{ TMyIntHelper }

class function TMyIntHelper.IsBetween(const Value: TMyInt;
 const AMin, AMax: integer): boolean;
begin
  Result:=(Value >= AMin) and (Value <= AMax);
end;

function TMyIntHelper.IsBetween(const AMin, AMax: integer): boolean;
begin
  Result:=IsBetween(Self, AMin, AMax);
end;

class function TMyIntHelper.EnsureBetween(const Value: TMyInt;
  const AMin, AMax: integer): integer;
begin
  if Value < AMin then
    Result:=AMin
  else if Value > AMax then
    Result:=AMax
  else
    Result:=Value;
end;

function TMyIntHelper.EnsureBetween(const AMin, AMax: integer): integer;
begin
  Result:=EnsureBetween(Self, AMin, AMax);
end;

class function TMyIntHelper.IsEven(const Value: TMyInt): boolean;
begin
  Result:=not Odd(Value);
end;

function TMyIntHelper.IsEven: boolean;
begin
  Result:=IsEven(Self);
end;

class function TMyIntHelper.IsMin(Value: TMyInt): boolean;
begin
  Result:=Value = integer.MinValue;
end;

function TMyIntHelper.IsMin: boolean;
begin
  Result:=IsMin(Self);
end;

class function TMyIntHelper.IsMax(Value: TMyInt): boolean;
begin
  Result:=Value = integer.MaxValue;
end;

function TMyIntHelper.IsMax: boolean;
begin
  Result:=IsMax(Self);
end;

{ TFruitHelper }

function TFruitHelper.GetAsInteger: integer;
begin
  Result:=ToInteger(Self);
end;

procedure TFruitHelper.SetAsInteger(Value: integer);
begin
  Self:=FromInteger(Value);
end;

class function TFruitHelper.ToInteger(const Value: TFruit): integer;
begin
  Result:=Ord(Value);
end;

{$IFDEF DEBUG}
  {$IFOPT R+}
    {$R-}
    {$DEFINE R_ON}
  {$ENDIF}
{$ENDIF}
class function TFruitHelper.FromInteger(const Value: integer): TFruit;
begin
  if (Value >= Ord(cMinFruit)) and (Value <= Ord(cMaxFruit)) then
    Result:=TFruit(Value)
  else
    Result:=frUnknown;
end;
{$IFDEF DEBUG}
  {$IFDEF R_ON}
    {$R+}
    {$UNDEF R_ON}
  {$ENDIF}
{$ENDIF}

class function TFruitHelper.ToString(const Value: TFruit;
  const ANames: TNames): string;
begin
  Result:=ANames[Value];
end;

function TFruitHelper.ToString(const ANames: TNames): string;
begin
  Result:=ToString(Self, ANames);
end;

class function TFruitHelper.FromString(const Value: string;
  const ANames: TNames; ACaseSensitive: boolean): TFruit;
begin
  if ACaseSensitive then
  begin
    for Result:=Low(TFruit) to High(TFruit) do
      if SameStr(Value, ANames[Result]) then
        Exit;
  end
  else
  begin
    for Result:=Low(TFruit) to High(TFruit) do
      if SameText(Value, ANames[Result]) then
        Exit;
  end;
  Result:=Low(TFruit);
end;

{ TStringArrayHelper }

constructor TStringArrayHelper.Create(const AStrings: array of string);
var
  i: NativeUInt;
begin
  Count:=System.Length(AStrings);
  for i:=Low(AStrings) to High(AStrings) do
    &String[i]:=AStrings[i];
end;

function TStringArrayHelper.GetCount: NativeUInt;
begin
  Result:=System.Length(Self);
end;

procedure TStringArrayHelper.SetCount(Value: NativeUInt);
begin
  System.SetLength(Self, Value);
end;

function TStringArrayHelper.GetString(Value: NativeUInt): string;
begin
  Result:=Self[Value];
end;

procedure TStringArrayHelper.SetString(Index: NativeUInt; const Value: string);
begin
  if Index > Count-1 then
    raise ERangeError.Create(SRangeError);
  Self[Index]:=Value;
end;

class function TStringArrayHelper.Add(AArray: TStringArray;
  const Value: string): TStringArray;
begin
  Result:=Insert(AArray, Value, AArray.Count);
end;

function TStringArrayHelper.Add(const Value: string): TStringArray;
begin
  Result:=Add(Self, Value);
end;

class function TStringArrayHelper.Insert(AArray: TStringArray;
  const Value: string; AIndex: NativeUInt): TStringArray;
begin
  Result:=AArray;
  System.Insert(Value, Result, AIndex); // System.Insert modifies var param
end;

function TStringArrayHelper.Insert(const Value: string;
  AIndex: NativeUInt): TStringArray;
begin
  Result:=Insert(Self, Value, AIndex);
end;

class function TStringArrayHelper.Delete(AArray: TStringArray;
  AIndex, ACount: NativeUInt): TStringArray;
begin
  Result:=AArray;
  System.Delete(Result, AIndex, ACount); // System.Delete modifies var param
end;

function TStringArrayHelper.Delete(AIndex, ACount: NativeUInt): TStringArray;
begin
  Result:=Delete(Self, AIndex, ACount);
end;

class function TStringArrayHelper.Join(ASeparator: Char; const AArray: TStringArray): string;
var
  i: NativeUInt;
  lLength: NativeUInt;
  lPos: NativeUInt;
  lString: string;
  lStrLen: Integer;
begin
  if AArray.Count = 0 then
    Exit(string.Empty);

  if ASeparator = #0 then
    lLength:=0
  else
    lLength:=AArray.Count-1;

  for i:=0 to AArray.Count-1 do
    Inc(lLength, AArray[i].Length);

  SetLength(Result, lLength);

  lPos:=1;
  for i:=0 to AArray.Count-1 do
  begin
    if (i <> 0) and (ASeparator <> #0) then
    begin
      Result[lPos]:=ASeparator;
      Inc(lPos);
    end;

    lString:=AArray[i];
    lStrLen:=lString.Length;
    if lStrLen > 0 then
    begin
      // FIXED: Multiplying by SizeOf(Char) for Unicode compatibility
      System.Move(lString[1], Result[lPos], lStrLen * SizeOf(Char));
      Inc(lPos, lStrLen);
    end;
  end;
end;

function TStringArrayHelper.Join(ASeparator: char): string;
begin
  Result:=Join(ASeparator, Self);
end;

end.
