(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

program CStyleTypes_02_SparseEnum;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.TypInfo,
  Playground.Utils in '..\..\Common\Playground.Utils.pas',
  Playground.CStyleTypes in 'Playground.CStyleTypes.pas';

procedure Example1;
var
  lCtx: PSomeCtx;
  lStatus: TLegacyStatus;
begin
  Writeln('--- Example #1: Sending to C-API ---');
  Writeln('Objective: Convert Pascal Enum -> C Value -> API.');

  lCtx:=nil;
  lStatus:=lsReset; // Pascal Index 5, C-Value 1024

  Writeln(sLineBreak+'  [Code]');
  Writeln('  lStatus:=lsiReset;');
  Writeln('  SOME_CTX_set_status(lCtx, lStatus.AsInteger);');

  // The helper converts Enum -> 1024 automatically
  SOME_CTX_set_status(lCtx, lStatus.AsInteger);
end;

procedure Example2;
var
  lCtx: PSomeCtx;
  lStatus: TLegacyStatus;
  lRawVal: Integer;
begin
  Writeln(sLineBreak+'--- Example #2: Receiving from C-API (Stateful) ---');
  Writeln('Objective: Read back the value set in Example 1.');

  lCtx:=nil;

  // 1. Valid Case: Direct Assignment
  // The helper setter automatically converts C-Value -> Enum
  Writeln(sLineBreak+'  [Code]');
  Writeln('  lStatus.AsInteger:=SOME_CTX_get_status(lCtx);');

  try
    lStatus.AsInteger:=SOME_CTX_get_status(lCtx);
    Writeln('  [Result] Mapped to Pascal Enum: '+GetEnumName(TypeInfo(TLegacyStatus), Ord(lStatus)));
  except
    on E: ERangeError do
      Writeln('  [Result] Error: Invalid C-Value returned!');
  end;

  // 2. Invalid Case (Simulating bad C-Value)
  lRawVal:=500;
  Writeln(sLineBreak+'  [Code]');
  Writeln('  lRawVal:=500;');
  Writeln('  lStatus.AsInteger:=lRawVal;');

  try
    lStatus.AsInteger:=lRawVal; // Will raise exception
  except
    on E: ERangeError do
      Writeln('  [Result] Error: Unknown C-Value ('+lRawVal.ToString+')');
  end;
end;

procedure Example3;
var
  lStatus: TLegacyStatus;
  lFilter: TLegacyStatuses; // set of TLegacyStatus
begin
  Writeln(sLineBreak+'--- Example #3: Sets and Loops ---');
  Writeln('Objective: Demonstrate "Pure Pascal" logic on Sparse Enums.');

  // 1. Working with Sets
  // Define a filter of "Safe" states
  lFilter:=[lsOff, lsWarming];

  Writeln(sLineBreak+'  [Code]');
  Writeln('  lFilter:=[lsOff, lsiWarming];');
  Writeln('  if lStatus in lFilter then ...');

  // Test a value
  lStatus:=lsWarming; // C-Value 8
  if lStatus in lFilter then
    Writeln('  [Result] lsiWarming (8) is in the Safe Filter.');

  lStatus:=lsReset;   // C-Value 1024
  if not (lStatus in lFilter) then
    Writeln('  [Result] lsiReset (1024) is NOT in the Safe Filter.');

  // 2. Iteration (For Loop)
  Writeln(sLineBreak+'  [Code]');
  Writeln('  for lStatus:=Low(TLegacyStatus) to High(TLegacyStatus) do ...');

  Write('  [Result] C-Values in Loop: ');
  for lStatus:=Low(TLegacyStatus) to High(TLegacyStatus) do
  begin
    // We can iterate easily, even though values jump from 32 to 1024
    Write(lStatus.AsInteger.ToString+' ');
  end;
  Writeln;
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
