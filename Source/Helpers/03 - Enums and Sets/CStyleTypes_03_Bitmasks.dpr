(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

program CStyleTypes_03_Bitmasks;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.TypInfo, // Added for GetEnumName iteration
  Playground.Utils in '..\..\Common\Playground.Utils.pas',
  Playground.CStyleTypes in 'Playground.CStyleTypes.pas';

procedure Example1;
var
  lCtx: PSomeCtx;
  lFlags: TSimpleFlags;
begin
  Writeln('--- Example #1: Sets as Bitmasks ---');
  Writeln('Objective: Use Pascal Sets to manipulate C-Bitmasks.');

  lCtx:=nil;

  // 1. Constructing a mask
  lFlags:=[flsZero, flsTwo, flsNine];

  Writeln(sLineBreak+'  [Code]');
  Writeln('  lFlags:=[flsZero, flsTwo, flsNine];');
  Writeln('  SOME_CTX_set_simple_flags(lCtx, lFlags.AsInteger);');

  // Helper converts Set -> Integer (1 | 4 | 512 = 517 -> 0x205)
  SOME_CTX_set_simple_flags(lCtx, lFlags.AsInteger);

  // 2. Modifying the mask
  Writeln(sLineBreak+'  [Code]');
  Writeln('  Include(lFlags, flsOne); // Add bit 1');
  Writeln('  Exclude(lFlags, flsNine); // Remove bit 9');
  Writeln('  SOME_CTX_set_simple_flags(lCtx, lFlags.AsInteger);');

  Include(lFlags, flsOne);
  Exclude(lFlags, flsNine);

  // Call API with modified mask
  SOME_CTX_set_simple_flags(lCtx, lFlags.AsInteger);
end;

procedure Example2;
var
  lCtx: PSomeCtx;
  lFlags: TSimpleFlags;
  lFlag: TSimpleFlag;
begin
  Writeln(sLineBreak+'--- Example #2: Parsing & Iterating ---');
  Writeln('Objective: Convert raw Integer to Set and iterate active flags.');

  lCtx:=nil;

  // 1. Get Raw Value from C (Stateful from Ex1)
  Writeln(sLineBreak+'  [Code]');
  Writeln('  lFlags.AsInteger:=SOME_CTX_get_simple_flags(lCtx);');

  lFlags.AsInteger:=SOME_CTX_get_simple_flags(lCtx);

  // 2. Iterate using "in"
  Write('  [Result] Active Flags: ');
  for lFlag:=Low(TSimpleFlag) to High(TSimpleFlag) do
  begin
    if lFlag in lFlags then
    begin
      Write(GetEnumName(TypeInfo(TSimpleFlag), Ord(lFlag))+' ');
    end;
  end;
  Writeln;
end;

procedure Example3;
var
  lSingleFlag: TSimpleFlag;
  lRaw: Integer;
begin
  Writeln(sLineBreak+'--- Example #3: Single Flag Validation ---');
  Writeln('Objective: Validate raw integers as valid single-bit flags.');

  // 1. Valid Single Bit (2 = 1 shl 1 = flsOne)
  lRaw:=2;
  Writeln(sLineBreak+'  [Code]');
  Writeln('  lRaw:=2;');
  Writeln('  lSingleFlag.AsInteger:=lRaw;');

  try
    lSingleFlag.AsInteger:=lRaw;
    Writeln('  [Result] Mapped to: '+GetEnumName(TypeInfo(TSimpleFlag), Ord(lSingleFlag)));
  except
    on E: EInvalidCast do Writeln('  [Result] Error');
  end;

  // 2. Invalid (Multi-bit value 3 = 1 | 2)
  lRaw:=3;
  Writeln(sLineBreak+'  [Code]');
  Writeln('  lRaw:=3; // Invalid single flag');
  Writeln('  lSingleFlag.AsInteger:=lRaw;');

  try
    lSingleFlag.AsInteger:=lRaw;
    Writeln('  [Result] Mapped to: ...');
  except
    on E: EInvalidCast do
      Writeln('  [Result] Success: Caught invalid multi-bit value.');
  end;
end;

begin
  try
    Example1;
    NextSlide;

    Example2;
    NextSlide;

    Example3;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  PromptForCompletion;
end.
