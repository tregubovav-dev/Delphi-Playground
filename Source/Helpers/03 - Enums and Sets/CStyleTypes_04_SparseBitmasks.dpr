(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

program CStyleTypes_04_SparseBitmasks;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.TypInfo,
  Playground.Utils in '..\..\Common\Playground.Utils.pas',
  Playground.CStyleTypes in 'Playground.CStyleTypes.pas';

procedure Example1;
var
  lCtx: PSomeCtx;
  lFlags: TNcFlags;
begin
  Writeln('--- Example #1: Sparse Bitmask Construction ---');
  Writeln('Objective: Create a bitmask that respects the "Hole" (Bits 8..15).');

  lCtx:=nil;

  // 1. Create a set using explicit Ordinals
  // ncfl01 = Bit 1, ncfl22 = Bit 22.
  lFlags:=[ncfl01, ncfl22];

  Writeln(sLineBreak+'  [Code]');
  Writeln('  lFlags:=[ncfl01, ncfl22];');
  Writeln('  SOME_CTX_set_nc_flags(lCtx, lFlags.AsInteger);');

  // Helper converts Set -> Integer
  // Expect: (1 shl 1) | (1 shl 22) = 2+4194304 = 4194306 (0x400002)
  SOME_CTX_set_nc_flags(lCtx, lFlags.AsInteger);
end;

procedure Example2;
var
  lCtx: PSomeCtx;
  lFlags: TNcFlags;
  lRaw: Integer;
begin
  Writeln(sLineBreak+'--- Example #2: Safe Parsing ---');
  Writeln('Objective: Parse C-Integer while ignoring garbage in the "Hole".');

  lCtx:=nil;

  // 1. Simulate C returning a value with garbage
  // 0x400002 (Valid)+0x100 (Bit 8 - Invalid Hole)
  lRaw:=$400102;

  Writeln(sLineBreak+'  [Code]');
  Writeln('  lRaw:=$400102; // Valid bits+Garbage Bit 8');
  Writeln('  lFlags:=TNcFlags.SafeFromInteger(lRaw);');

  // 2. Safe Parse (Clears garbage automatically)
  lFlags:=TNcFlags.SafeFromInteger(lRaw);

  // 3. Verify Result (Should be same as Ex1)
  Writeln('  [Result] AsInteger (Sanitized): $'+IntToHex(lFlags.AsInteger, 6));

  // 4. Strict Parse (Should Fail)
  Writeln(sLineBreak+'  [Code]');
  Writeln('  TNcFlags.FromInteger(lRaw); // Strict Check');

  try
    TNcFlags.FromInteger(lRaw);
  except
    on E: EInvalidCast do
      Writeln('  [Result] Strict Parse Caught Garbage Bits (Correct).');
  end;
end;

begin
  try
    Example1;
    NextSlide;
    Example2;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  PromptForCompletion;
end.
