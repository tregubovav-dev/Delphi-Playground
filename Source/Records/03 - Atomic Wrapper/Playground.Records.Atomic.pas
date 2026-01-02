(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

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
      {$IFNDEF DEBUG}inline;{$ENDIF}
    procedure SetValue(const Value: integer); inline;
      {$IFNDEF DEBUG}inline;{$ENDIF}
  public
    // -------------------------------------------------------------------------
    // Atomic Modification
    // -------------------------------------------------------------------------

    /// <summary>Atomic Add (Self+Amount). Returns NEW value.</summary>
    function Add(Amount: integer): integer;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Atomic Increment by Amount. Returns NEW value.</summary>
    function Increment(Amount: integer =1 ): integer; overload; inline;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Atomic Decrement by Amount. Returns NEW value.</summary>
    function Decrement(Amount: integer = 1): integer; overload; inline;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Atomic Exchange. Sets new value, returns OLD value.</summary>
    function Exchange(NewValue: integer): integer;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Compare and Exchange. Returns True if swap occurred.</summary>
    function CompareExchange(NewValue, Expected: integer): boolean; overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Compare and Exchange. Returns OLD value.</summary>
    function CompareExchange(NewValue, Expected: integer;
      out Success: boolean): integer; overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    // -------------------------------------------------------------------------
    // Operator Overloads
    // -------------------------------------------------------------------------
    class operator Assign(var Dest: TAtomicInt; const [ref] Src: TAtomicInt);
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator Implicit(const A: TAtomicInt): integer;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator Implicit(const A: integer): TAtomicInt;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator Equal(const A: TAtomicInt; const B: integer): Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator NotEqual(const A: TAtomicInt; const B: integer): Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator GreaterThan(const A: TAtomicInt; const B: integer): boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator GreaterThanOrEqual(const A: TAtomicInt; const B: integer): boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator LessThan(const A: TAtomicInt; const B: integer): boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator LessThanOrEqual(const A: TAtomicInt; const B: integer): boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}

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
