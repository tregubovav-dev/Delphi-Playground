(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

unit Playground.Records.SafeSet;

interface

uses
  System.SysUtils;

type
  // The Enum (0..2)
  TMyFlag = (flOne, flTwo, flThree);
  TMyFlags = set of TMyFlag;

  TMySafeSet = record
  public type
  {$IF ((Defined(CPU64BITS) and (SizeOf(TMyFlags) > 8))
    or ((Defined(CPU32BITS) and (SizeOf(TMyFlags) > 4))))}
    {$MESSAGE Error 'TMySafeSet size exceeded.'}
  {$IFEND}

    // Auto-Detect Storage Type
    {$IF SizeOf(TMyFlags) <= 1}
      TStorage = Byte;
    {$ELSEIF SizeOf(TMyFlags) <= 2}
      TStorage = Word;
    {$ELSEIF SizeOf(TMyFlags) <= 4}
      TStorage = Cardinal;
    {$ELSE}
      TStorage = UInt64;
    {$IFEND}

  private const
    // mask for filtering out garbage when.
    // it should be updated manually if TMyFlag type is a sparse enum.
    cMask = TStorage((1 shl (Ord(High(TMyFlag))+1))-1);

  private
    FData: TStorage;
    // Centralized Conversion Logic
    class function ToStorage(Value: TMyFlags): TStorage; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class function FromInteger(Value: TStorage): TStorage; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    procedure SetAsInteger(Value: TStorage);
      {$IFNDEF DEBUG}inline;{$ENDIF}

    class function OpInclude(AData: TStorage; Value: TMyFlag): TStorage;
      static; {$IFNDEF DEBUG}inline;{$ENDIF}
    class function OpExclude(AData: TStorage; Value: TMyFlag): TStorage;
      static; {$IFNDEF DEBUG}inline;{$ENDIF}

  public
    // Converters
    class operator Implicit(Value: TMyFlags): TMySafeSet;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator Implicit(Value: TMySafeSet): TMyFlags;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator Implicit(Value: TMyFlag): TMySafeSet;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    // Arithmetic (Flag)
    class operator Add(ALeft: TMySafeSet; ARight: TMyFlag): TMySafeSet;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator Subtract(ALeft: TMySafeSet; ARight: TMyFlag): TMySafeSet;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    // Arithmetic (Native Set)
    class operator Add(ALeft: TMySafeSet; ARight: TMyFlags): TMySafeSet;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator Subtract(ALeft: TMySafeSet; ARight: TMyFlags): TMySafeSet;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    // Arithmetic (Safe Set)
    class operator Add(ALeft, ARight: TMySafeSet): TMySafeSet;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator Subtract(ALeft, ARight: TMySafeSet): TMySafeSet;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    class operator In(AElement: TMyFlag; ASet: TMySafeSet): Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator Equal(ALeft, ARight: TMySafeSet): Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    class operator NotEqual(ALeft, ARight: TMySafeSet): Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    // Fluent Methods (Pascal-style)
    procedure Include(Value: TMyFlag);
      {$IFNDEF DEBUG}inline;{$ENDIF}
    procedure Exclude(Value: TMyFlag);
      {$IFNDEF DEBUG}inline;{$ENDIF}

    property AsInteger: TStorage read FData write SetAsInteger;
  end;

implementation

{ TMySafeSet }

class function TMySafeSet.ToStorage(Value: TMyFlags): TStorage;
begin
  Result:=0; // Ensure clean slate

  // Hybrid Approach: Cast for standard sizes, Move for odd sizes
  {$IF (SizeOf(TMyFlags) = 1)} Result:=PByte(@Value)^;
  {$ELSEIF (SizeOf(TMyFlags) = 2)} Result:=PWord(@Value)^;
  {$ELSEIF (SizeOf(TMyFlags) = 4)} Result:=PCardinal(@Value)^;
  {$ELSEIF (Defined(CPU64BITS) and (SizeOf(TMyFlags) = 8))} Result:=PUInt64(@Value)^;
  {$ELSE} Move(Value, Result, SizeOf(TMyFlags)); {$IFEND}
end;

class function TMySafeSet.FromInteger(Value: TStorage): TStorage;
begin
  Result:=Value and cMask;
end;

procedure TMySafeSet.SetAsInteger(Value: TStorage);
begin
  FData:=FromInteger(Value);
end;

class function TMySafeSet.OpInclude(AData: TStorage; Value: TMyFlag): TStorage;
begin
  Result:=AData or (TStorage(1) shl Ord(Value));
end;

class function TMySafeSet.OpExclude(AData: TStorage; Value: TMyFlag): TStorage;
begin
  Result:=AData and not (TStorage(1) shl Ord(Value));
end;

class operator TMySafeSet.Implicit(Value: TMyFlags): TMySafeSet;
begin
  Result.FData:=ToStorage(Value);
end;

class operator TMySafeSet.Implicit(Value: TMySafeSet): TMyFlags;
begin
  // Reverse logic (Storage -> Set) usually simpler via Move/Cast
  Result:=[];
  {$IF (SizeOf(TMyFlags) = 1)} PByte(@Result)^:=Value.FData;
  {$ELSEIF (SizeOf(TMyFlags) = 2)} PWord(@Result)^:=Value.FData;
  {$ELSEIF (SizeOf(TMyFlags) = 4)} PCardinal(@Result)^:=Value.FData;
  {$ELSEIF (Defined(CPU64BITS) and (SizeOf(TMyFlags) = 8))} PUInt64(@Result)^:=Value.FData;
  {$ELSE} Move(Value.FData, Result, SizeOf(TMyFlags)); {$IFEND}
end;

class operator TMySafeSet.Implicit(Value: TMyFlag): TMySafeSet;
begin
  Result.FData:=OpInclude(0, Value);
end;

class operator TMySafeSet.Add(ALeft: TMySafeSet; ARight: TMyFlag): TMySafeSet;
begin
  Result.FData:=OpInclude(ALeft.FData, ARight);
end;

class operator TMySafeSet.Add(ALeft: TMySafeSet; ARight: TMyFlags): TMySafeSet;
var
  lRightData: TStorage;
begin
  // Use SetData to convert the Right Operand
  lRightData:=ToStorage(ARight);
  Result.FData:=ALeft.FData or lRightData;
end;

class operator TMySafeSet.Add(ALeft, ARight: TMySafeSet): TMySafeSet;
begin
  Result.FData:=ALeft.FData or ARight.FData;
end;

class operator TMySafeSet.Subtract(ALeft: TMySafeSet; ARight: TMyFlag): TMySafeSet;
begin
  Result.FData:=OpExclude(ALeft.FData, ARight);
end;

class operator TMySafeSet.Subtract(ALeft: TMySafeSet; ARight: TMyFlags): TMySafeSet;
var
  lRightData: TStorage;
begin
  lRightData:=ToStorage(ARight);
  Result.FData:=ALeft.FData and (not LRightData);
end;

class operator TMySafeSet.Subtract(ALeft, ARight: TMySafeSet): TMySafeSet;
begin
  Result.FData:=ALeft.FData and (not ARight.FData);
end;

class operator TMySafeSet.In(AElement: TMyFlag; ASet: TMySafeSet): Boolean;
begin
  Result:=(ASet.FData and (1 shl Ord(AElement))) <> 0;
end;

class operator TMySafeSet.Equal(ALeft, ARight: TMySafeSet): Boolean;
begin
  Result:=ALeft.FData = ARight.FData;
end;

class operator TMySafeSet.NotEqual(ALeft, ARight: TMySafeSet): Boolean;
begin
  Result:=ALeft.FData <> ARight.FData;
end;

procedure TMySafeSet.Include(Value: TMyFlag);
begin
  FData:=OpInclude(FData, Value);
end;

procedure TMySafeSet.Exclude(Value: TMyFlag);
begin
  FData:=OpExclude(FData, Value);
end;

end.
