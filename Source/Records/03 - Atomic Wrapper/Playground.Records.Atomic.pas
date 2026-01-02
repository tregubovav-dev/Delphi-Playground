unit Playground.Records.Atomic;

interface

uses
  System.SysUtils, System.SyncObjs;

type
  TAtomicInt = record
  strict private
    [Volatile]
    FData: integer;
    function GetValue: integer; inline;
    procedure SetValue(const Value: integer); inline;
  public
    // -------------------------------------------------------------------------
    // Atomic Modification
    // -------------------------------------------------------------------------

    /// <summary>Atomic Add (Self+Amount). Returns NEW value.</summary>
    function Add(Amount: integer): integer;

    /// <summary>Atomic Increment by Amount. Returns NEW value.</summary>
    function Increment(Amount: integer =1 ): integer; overload; inline;

    /// <summary>Atomic Decrement by Amount. Returns NEW value.</summary>
    function Decrement(Amount: integer = 1): integer; overload; inline;

    /// <summary>Atomic Exchange. Sets new value, returns OLD value.</summary>
    function Exchange(NewValue: integer): integer;

    /// <summary>Compare and Exchange. Returns True if swap occurred.</summary>
    function CompareExchange(NewValue, Expected: integer): boolean; overload;

    /// <summary>Compare and Exchange. Returns OLD value.</summary>
    function CompareExchange(NewValue, Expected: integer;
      out Success: boolean): integer; overload;

    // -------------------------------------------------------------------------
    // Operator Overloads
    // -------------------------------------------------------------------------
    class operator Assign(var Dest: TAtomicInt; const [ref] Src: TAtomicInt);
    class operator Implicit(const A: TAtomicInt): integer;
    class operator Implicit(const A: integer): TAtomicInt;
    class operator Equal(const A: TAtomicInt; const B: integer): Boolean;
    class operator NotEqual(const A: TAtomicInt; const B: integer): Boolean;
    class operator GreaterThan(const A: TAtomicInt; const B: integer): boolean;
    class operator GreaterThanOrEqual(const A: TAtomicInt; const B: integer): boolean;
    class operator LessThan(const A: TAtomicInt; const B: integer): boolean;
    class operator LessThanOrEqual(const A: TAtomicInt; const B: integer): boolean;
    property Value: integer read GetValue write SetValue;
  end;

implementation

{ TAtomicInt }

function TAtomicInt.GetValue: integer;
begin
  Result:=TInterlocked.CompareExchange(FData, 0, 0);
end;

procedure TAtomicInt.SetValue(const Value: integer);
begin
  TInterlocked.Exchange(FData, Value);
end;

// --- Arithmetic ---

function TAtomicInt.Add(Amount: integer): integer;
begin
  // The core primitive for atomic addition
  Result:=TInterlocked.Add(FData, Amount);
end;

function TAtomicInt.Increment(Amount: integer): integer;
begin
  // Wrapper for Add
  Result:=Add(Amount);
end;

function TAtomicInt.Decrement(Amount: integer): integer;
begin
  // Wrapper for Add (negated)
  Result:=Add(-Amount);
end;

// --- Exchange / CAS ---

function TAtomicInt.Exchange(NewValue: integer): integer;
begin
  Result:=TInterlocked.Exchange(FData, NewValue);
end;

function TAtomicInt.CompareExchange(NewValue, Expected: integer): boolean;
begin
  CompareExchange(NewValue, Expected, Result);
end;

function TAtomicInt.CompareExchange(NewValue, Expected: integer;
  out Success: boolean): integer;
begin
  Result:=TInterlocked.CompareExchange(FData, NewValue, Expected);
  Success:=Result = Expected;
end;

// --- Operators ---

class operator TAtomicInt.Assign(var Dest: TAtomicInt; const [ref] Src: TAtomicInt);
begin
  Dest.Exchange(Src.GetValue);
end;

class operator TAtomicInt.Implicit(const A: TAtomicInt): integer;
begin
  Result:=A.GetValue;
end;

class operator TAtomicInt.Implicit(const A: integer): TAtomicInt;
begin
  Result.FData:=A;
end;

class operator TAtomicInt.Equal(const A: TAtomicInt; const B: integer): Boolean;
begin
  Result:=A.GetValue = B;
end;

class operator TAtomicInt.NotEqual(const A: TAtomicInt; const B: integer): Boolean;
begin
  Result:=A.GetValue <> B;
end;

class operator TAtomicInt.GreaterThan(const A: TAtomicInt;
  const B: integer): boolean;
begin
  Result:=A.GetValue > B;
end;

class operator TAtomicInt.GreaterThanOrEqual(const A: TAtomicInt;
  const B: integer): boolean;
begin
  Result:=A.GetValue >= B;
end;

class operator TAtomicInt.LessThan(const A: TAtomicInt;
  const B: integer): boolean;
begin
  Result:=A.GetValue < B;
end;

class operator TAtomicInt.LessThanOrEqual(const A: TAtomicInt;
  const B: integer): boolean;
begin
  Result:=A.GetValue <= B;
end;

end.
