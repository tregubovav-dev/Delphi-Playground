(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

unit Playground.Records.AtomicSet;

interface

uses
  System.SysUtils,
  System.SyncObjs;

type
  TAtomicFlag = (afFree, afQueued, afRunning, afCompleted,
                 afFailing, afCanceling, afPausing);

  TAtomicFlags = set of TAtomicFlag;
  TAtomicFlagsHelper = record helper for TAtomicFlags
  private const
    cNames: array[TAtomicFlag] of string = ('afFree', 'afQueued', 'afRunning',
                  'afCompleted', 'afFailing', 'afCanceling', 'afPausing');
    cCount = Succ(Ord(High(TAtomicFlag)));

    function ToString: string;
  public
    property AsString: string read ToString;
  end;


  /// <summary>
  ///   Thread-safe wrapper for a Pascal Set.
  ///   Promotes storage to at least 16-bit (Word) for C-API compatibility.
  /// </summary>
  TAtomicSet = record
  public type
  {$IF ((Defined(CPU64BITS) and (SizeOf(TAtomicFlags) > 8)) or ((Defined(CPU32BITS) and (SizeOf(TAtomicFlags) > 4))))}
    {$MESSAGE Error 'TAtomicSet size exceeded.'}
  {$IFEND}

    // Auto-Detect Storage Type (Min 16-bit)
    {$IF SizeOf(TAtomicFlags) <= 2}     TStorage = Word;
    {$ELSEIF SizeOf(TAtomicFlags) <= 4} TStorage = Cardinal;
    {$ELSE}                             TStorage = UInt64;
    {$IFEND}
    (*
    // declaration supporting 8-bit storage commented out for C-API alignment preference
    {$IF SizeOf(TAtomicFlags) <= 1}     TStorage = Byte;
    {$ELSEIF SizeOf(TAtomicFlags) <= 2} TStorage = Word;
    {$ELSEIF SizeOf(TAtomicFlags) <= 4} TStorage = Cardinal;
    {$ELSE}                             TStorage = UInt64;
    {$IFEND}
    *)

  strict private
    [Volatile]
    FData: TStorage;

    // --- Internal Helpers ---
    // Used to calculate actual valid bits based on Enum Range, not Storage Size
    const cMask = TStorage(Pred(1 shl Succ(Ord(High(TAtomicFlag)))));

    class function ToStorage(Value: TAtomicFlags): TStorage; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class function FromStorage(Value: TStorage): TAtomicFlags; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    class function DoCAS(var ATarget: TStorage; New, Old: TStorage;
      out Success: Boolean): TStorage; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    procedure SetAsAtomic(Value: TAtomicFlags); {$IFNDEF DEBUG}inline;{$ENDIF}
    function GetAsAtomic: TAtomicFlags; {$IFNDEF DEBUG}inline;{$ENDIF}

    procedure SetAsInteger(Value: TStorage); {$IFNDEF DEBUG}inline;{$ENDIF}

  public
    // -------------------------------------------------------------------------
    // Atomic Operations
    // -------------------------------------------------------------------------
    function AtomicInclude(Value: TAtomicFlags): TAtomicFlags; overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    function AtomicInclude(Value: TAtomicFlag): TAtomicFlags; overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    function AtomicExclude(Value: TAtomicFlags): TAtomicFlags; overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    function AtomicExclude(Value: TAtomicFlag): TAtomicFlags; overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    function AtomicTransition(Expected, NewValue: TAtomicFlags): Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    // -------------------------------------------------------------------------
    // Operators
    // -------------------------------------------------------------------------
    class operator Implicit(Value: TAtomicFlags): TAtomicSet;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator Implicit(Value: TAtomicSet): TAtomicFlags;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator Implicit(Value: TAtomicFlag): TAtomicSet;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    class operator Add(Left: TAtomicSet; Right: TAtomicFlags): TAtomicSet;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator Add(Left: TAtomicSet; Right: TAtomicFlag): TAtomicSet;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    class operator Subtract(Left: TAtomicSet; Right: TAtomicFlags): TAtomicSet;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator Subtract(Left: TAtomicSet; Right: TAtomicFlag): TAtomicSet;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    class operator In(Element: TAtomicFlag; SetVal: TAtomicSet): Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator Equal(Left, Right: TAtomicSet): Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator NotEqual(Left, Right: TAtomicSet): Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    // -------------------------------------------------------------------------
    // Properties
    // -------------------------------------------------------------------------
    property Value: TAtomicFlags read GetAsAtomic write SetAsAtomic;

    /// <summary>
    ///   Direct Atomic access to the underlying integer storage.
    ///   Useful for C-Interop and Debugging (Hex output).
    /// </summary>
    property AsInteger: TStorage read FData write SetAsInteger;
  end;

implementation

{ TAtomicFlagsHelper }

function TAtomicFlagsHelper.ToString: string;
var
  i: TAtomicFlag;

begin
  Result:='[';
  for i:=Low(TAtomicFlag) to High(TAtomicFlag) do
    if i in Self then
    begin
      if Result.Length > 1 then
        Result:=Result+' ,';
      Result:=Result+cNames[i];
    end;
  Result:=Result+']';
end;

{ TAtomicSet }

class function TAtomicSet.ToStorage(Value: TAtomicFlags): TStorage;
begin
  Result:=0;
  // Read based on Set Size (1 Byte), Result promoted to TStorage (2 Bytes)
  {$IF (SizeOf(TAtomicFlags) = 1)} Result:=PByte(@Value)^;
  {$ELSEIF (SizeOf(TAtomicFlags) = 2)} Result:=PWord(@Value)^;
  {$ELSEIF (SizeOf(TAtomicFlags) = 4)} Result:=PCardinal(@Value)^;
  {$ELSEIF (Defined(CPU64BITS) and (SizeOf(TAtomicFlags) = 8))}
    Result:=PUInt64(@Value)^;
  {$ELSE} Move(Value, Result, SizeOf(TAtomicFlags)); {$IFEND}

  // Mask ensures we don't carry garbage in the valid range
  Result:=Result and cMask;
end;

class function TAtomicSet.FromStorage(Value: TStorage): TAtomicFlags;
begin
  Result:=[];
  Value:=Value and cMask;

  // Write based on Set Size
  {$IF (SizeOf(TAtomicFlags) = 1)} PByte(@Result)^:=Byte(Value);
  {$ELSEIF (SizeOf(TAtomicFlags) = 2)} PWord(@Result)^:=Word(Value);
  {$ELSEIF (SizeOf(TAtomicFlags) = 4)} PCardinal(@Result)^:=Cardinal(Value);
  {$ELSEIF (Defined(CPU64BITS) and (SizeOf(TAtomicFlags) = 8))}
    PUInt64(@Result)^:=UInt64(Value);
  {$ELSE} Move(Value, Result, SizeOf(TAtomicFlags)); {$IFEND}
end;

class function TAtomicSet.DoCAS(var ATarget: TStorage; New, Old: TStorage; out Success: Boolean): TStorage;
begin
  // CAS based on Storage Size (Min Word/2 Bytes)
  {$IF SizeOf(TStorage) = 1}
    Byte(Result):=AtomicCmpExchange(Byte(ATarget), Byte(New), Byte(Old), Success);
  {$ELSEIF SizeOf(TStorage) = 2}
    Word(Result):=AtomicCmpExchange(Word(ATarget), Word(New), Word(Old), Success);
  {$ELSEIF SizeOf(TStorage) = 4}
    Cardinal(Result):=AtomicCmpExchange(Cardinal(ATarget), Cardinal(New), Cardinal(Old), Success);
  {$ELSEIF SizeOf(TStorage) = 8}
    UInt64(Result):=AtomicCmpExchange(UInt64(ATarget), UInt64(New), UInt64(Old), Success);
  {$IFEND}
end;

procedure TAtomicSet.SetAsAtomic(Value: TAtomicFlags);
begin
  SetAsInteger(ToStorage(Value));
end;

function TAtomicSet.GetAsAtomic: TAtomicFlags;
begin
  Result:=FromStorage(FData);
end;

procedure TAtomicSet.SetAsInteger(Value: TStorage);
begin
  {$IF SizeOf(TStorage) = 1} AtomicExchange(Byte(FData), Byte(Value));
  {$ELSEIF SizeOf(TStorage) = 2} AtomicExchange(Word(FData), Word(Value));
  {$ELSEIF SizeOf(TStorage) = 4} AtomicExchange(Cardinal(FData), Cardinal(Value));
  {$ELSEIF SizeOf(TStorage) = 8} AtomicExchange(UInt64(FData), UInt64(Value));
  {$IFEND}
end;

function TAtomicSet.AtomicInclude(Value: TAtomicFlags): TAtomicFlags;
var
  lOld, lNew, lPrev: TStorage;
  lSuccess: Boolean;
  lBits: TStorage;
  lSpin: TSpinWait;
begin
  lSpin.Reset;
  lBits:=ToStorage(Value);
  lOld:=FData;

  repeat
    lNew:=lOld or lBits;
    if lOld = lNew then Exit(FromStorage(lNew));

    lPrev:=DoCAS(FData, lNew, lOld, lSuccess);
    if lSuccess then Exit(FromStorage(lNew));

    lOld:=lPrev;
    lSpin.SpinCycle;
  until False;
end;

function TAtomicSet.AtomicInclude(Value: TAtomicFlag): TAtomicFlags;
begin
  Result:=AtomicInclude([Value]);
end;

function TAtomicSet.AtomicExclude(Value: TAtomicFlags): TAtomicFlags;
var
  lOld, lNew, lPrev: TStorage;
  lSuccess: Boolean;
  lBits: TStorage;
  lSpin: TSpinWait;
begin
  lSpin.Reset;
  lBits:=ToStorage(Value);
  lOld:=FData;

  repeat
    lNew:=lOld and not lBits;
    if lOld = lNew then Exit(FromStorage(lNew));

    lPrev:=DoCAS(FData, lNew, lOld, lSuccess);
    if lSuccess then Exit(FromStorage(lNew));

    lOld:=lPrev;
    lSpin.SpinCycle;
  until False;
end;

function TAtomicSet.AtomicExclude(Value: TAtomicFlag): TAtomicFlags;
begin
  Result:=AtomicExclude([Value]);
end;

function TAtomicSet.AtomicTransition(Expected, NewValue: TAtomicFlags): Boolean;
var
  lExp, lNew: TStorage;
  lSuccess: Boolean;
begin
  lExp:=ToStorage(Expected);
  lNew:=ToStorage(NewValue);
  DoCAS(FData, lNew, lExp, lSuccess);
  Result:=lSuccess;
end;

// --- Operators ---

class operator TAtomicSet.Implicit(Value: TAtomicFlags): TAtomicSet;
begin
  Result.FData:=ToStorage(Value);
end;

class operator TAtomicSet.Implicit(Value: TAtomicSet): TAtomicFlags;
begin
  Result:=FromStorage(Value.FData);
end;

class operator TAtomicSet.Implicit(Value: TAtomicFlag): TAtomicSet;
begin
  Result.FData:=ToStorage([Value]);
end;

class operator TAtomicSet.Add(Left: TAtomicSet; Right: TAtomicFlags): TAtomicSet;
begin
  Result.FData:=Left.FData or ToStorage(Right);
end;

class operator TAtomicSet.Add(Left: TAtomicSet; Right: TAtomicFlag): TAtomicSet;
begin
  Result.FData:=Left.FData or ToStorage([Right]);
end;

class operator TAtomicSet.Subtract(Left: TAtomicSet; Right: TAtomicFlags): TAtomicSet;
begin
  Result.FData:=Left.FData and not ToStorage(Right);
end;

class operator TAtomicSet.Subtract(Left: TAtomicSet; Right: TAtomicFlag): TAtomicSet;
begin
  Result.FData:=Left.FData and not ToStorage([Right]);
end;

class operator TAtomicSet.In(Element: TAtomicFlag; SetVal: TAtomicSet): Boolean;
begin
  Result:=(SetVal.FData and ToStorage([Element])) <> 0;
end;

class operator TAtomicSet.Equal(Left, Right: TAtomicSet): Boolean;
begin
  Result:=Left.FData = Right.FData;
end;

class operator TAtomicSet.NotEqual(Left, Right: TAtomicSet): Boolean;
begin
  Result:=Left.FData <> Right.FData;
end;

end.
