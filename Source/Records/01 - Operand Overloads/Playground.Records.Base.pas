unit Playground.Records.Base;

interface

uses
  System.SysUtils;

type
  TDoubleRec = record
  strict private
    FValue: double;
    class function AreEqual(const A: TDoubleRec; const B: string): Boolean; static;
  public
    constructor Create(AValue: double);

//    class operator Assign(var Dest: TDoubleRec; const [ref] Src: TDoubleRec);

    class operator Implicit(const AValue: string): TDoubleRec;
    class operator Implicit(const AValue: TDoubleRec): string;

    class operator Explicit(const AValue: string): TDoubleRec;
    class operator Explicit(const AValue: TDoubleRec): string;

    class operator Equal(const A: TDoubleRec; const B: string): Boolean; overload;
    class operator Equal(const A: string; const B: TDoubleRec): Boolean; overload;

    class operator NotEqual(const A: TDoubleRec; const B: string): Boolean; overload;
    class operator NotEqual(const A: string; const B: TDoubleRec): Boolean; overload;

    property Value: double read FValue;
  end;

implementation

{ TDoubleRec }

constructor TDoubleRec.Create(AValue: double);
begin
  Writeln(Format('  >>> TDoubleRec.Create(%e)', [AValue]));
  FValue:=AValue;
  Writeln('  <<< TDoubleRec.Create');
end;

class function TDoubleRec.AreEqual(const A: TDoubleRec; const B: string): Boolean;
begin
  // In real scenario use System.Math.SameValue procedure is preferred.
  Result:=A.Value = B.ToDouble;
end;

{
class operator TDoubleRec.Assign(var Dest: TDoubleRec; const [ref] Src: TDoubleRec);
begin
  Writeln(Format('  >>> [Op] Assign (Dest:=%e)', [Src.FValue]));
  Dest.FValue:=Src.FValue;
  Writeln('  <<< [Op] Assign');
end;
}

class operator TDoubleRec.Implicit(const AValue: string): TDoubleRec;
begin
  Writeln(Format('  >>> [Op] Implicit (String "%s" -> Rec)', [AValue]));
  Result.FValue:=AValue.ToDouble;
  Writeln('  <<< [Op] Implicit');
end;

class operator TDoubleRec.Implicit(const AValue: TDoubleRec): string;
begin
  Writeln(Format('  >>> [Op] Implicit (Rec %e -> String)', [AValue.FValue]));
  Result:=AValue.FValue.ToString;
  Writeln('  <<< [Op] Implicit');
end;

class operator TDoubleRec.Explicit(const AValue: string): TDoubleRec;
begin
  Writeln(Format('  >>> [Op] Explicit (String "%s" -> Rec)', [AValue]));
  Result.FValue:=AValue.ToDouble;
  Writeln('  <<< [Op] Explicit');
end;

class operator TDoubleRec.Explicit(const AValue: TDoubleRec): string;
begin
  Writeln(Format('  >>> [Op] Explicit (Rec %e -> String)', [AValue.FValue]));
  Result:=AValue.FValue.ToString;
  Writeln('  <<< [Op] Explicit');
end;

class operator TDoubleRec.Equal(const A: TDoubleRec; const B: string): Boolean;
begin
  Writeln(Format('  >>> [Op] Equal (Rec %e = "%s"?)', [A.FValue, B]));
  Result:=AreEqual(A, B);
  Writeln('      Result: '+Result.ToString(TUseBoolStrs.True));
  Writeln('  <<< [Op] Equal');
end;

class operator TDoubleRec.Equal(const A: string; const B: TDoubleRec): Boolean;
begin
  // Distinct implementation (no delegation) to show correct entry point in logs
  Writeln(Format('  >>> [Op] Equal (String "%s" = Rec %e?)', [A, B.FValue]));
  Result:=AreEqual(B, A);
  Writeln('      Result: '+Result.ToString(TUseBoolStrs.True));
  Writeln('  <<< [Op] Equal');
end;

class operator TDoubleRec.NotEqual(const A: TDoubleRec; const B: string): Boolean;
begin
  Writeln(Format('  >>> [Op] NotEqual (Rec %e <> "%s"?)', [A.FValue, B]));
  Result:=not AreEqual(A,  B);
  Writeln('  <<< [Op] NotEqual');
end;

class operator TDoubleRec.NotEqual(const A: string; const B: TDoubleRec): Boolean;
begin
  Writeln(Format('  >>> [Op] NotEqual (Rec "%s" <> "%e"?)', [A, B.FValue]));
  Result:=not AreEqual(B,  A);
  Writeln('  <<< [Op] NotEqual');
end;

end.
