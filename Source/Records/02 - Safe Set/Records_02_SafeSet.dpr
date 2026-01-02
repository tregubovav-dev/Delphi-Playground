(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

program Records_02_SafeSet;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Playground.Utils in '..\..\Common\Playground.Utils.pas',
  Playground.Records.SafeSet in 'Playground.Records.SafeSet.pas';

procedure Example1;
var
  lSet: TMySafeSet;
begin
  Writeln('--- Example #1: Creation & Size ---');
  Writeln(Format('  SizeOf(TMyFlags): %d', [SizeOf(TMyFlags)]));
  Writeln(Format('  SizeOf(TMySafeSet): %d', [SizeOf(TMySafeSet)]));

  // Implicit: Set -> Record
  lSet:=[flOne, flThree];
  Writeln(sLineBreak+'  [Code] lSet:=[flOne, flThree];');
  Writeln('  [Result] AsInteger: '+IntToHex(lSet.AsInteger, 2));
end;

procedure Example2;
var
  lSet: TMySafeSet;
  lUnion: TMySafeSet;
begin
  Writeln(sLineBreak+'--- Example #2: Set Arithmetic & Methods ---');

  lSet:=[flOne];
  Writeln('  [Initial] '+IntToHex(lSet.AsInteger, 2));

  // 1. Operator+(Include)
  Writeln(sLineBreak+'  [Code] lSet:=lSet+flTwo;');
  lSet:=lSet+flTwo;
  Write('  [Result] Has flTwo? ');
  if flTwo in lSet then Writeln('Yes') else Writeln('No');

  // 2. Method Include
  Writeln(sLineBreak+'  [Code] lSet.Include(flThree);');
  lSet.Include(flThree);
  Write('  [Result] Has flThree? ');
  if flThree in lSet then Writeln('Yes') else Writeln('No');

  // 3. Method Exclude
  Writeln(sLineBreak+'  [Code] lSet.Exclude(flOne);');
  lSet.Exclude(flOne);
  Write('  [Result] Has flOne? ');
  if flOne in lSet then Writeln('Yes (Error)') else Writeln('No (Correct)');

  // 4. Safe+Safe (Union)
  Writeln(sLineBreak+'  [Code] lUnion:=lSet+TMySafeSet([flOne]);');
  lUnion:=lSet+TMySafeSet([flOne]);

  // Check Union
  Write('  [Result] Union has flTwo? ');
  if flTwo in lUnion then Write('Yes ') else Write('No ');

  Write('| Union has flOne? ');
  if flOne in lUnion then Writeln('Yes') else Writeln('No');
end;

procedure Example3;
var
  lSet: TMySafeSet;
  lNative: TMyFlags;
begin
  Writeln(sLineBreak+'--- Example #3: Interop with Native Sets ---');
  Writeln('  [Code] lSet:=[flOne, flTwo]; lNative:=lSet; '+
          'if lNative = [flOne, flTwo] then ...;');
  lSet:=[flOne, flTwo];

  // Explicit/Implicit back to Native
  lNative:=lSet;

  if lNative = [flOne, flTwo] then
    Writeln('  [Result] Round-trip conversion successful.');
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
