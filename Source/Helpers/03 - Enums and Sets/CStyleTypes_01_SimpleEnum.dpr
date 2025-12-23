(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

program CStyleTypes_01_SimpleEnum;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.TypInfo,
  Playground.Utils in '..\..\Common\Playground.Utils.pas',
  Playground.CStyleTypes in 'Playground.CStyleTypes.pas';

procedure Example1;
var
  lCtx: PSomeCtx;
  lEnum: TSimpleTestEnum;
begin
  Writeln('--- Example #1: Contiguous C-Enum ---');
  Writeln('Objective: Pass Pascal Enum to C-API expecting int.');

  lCtx:=nil;
  lEnum:=steThree;

  Writeln(sLineBreak+'  [Code]');
  Writeln('  lEnum:=steThree; // Value 3');
  Writeln('  SOME_CTX_do_with_simple_enum(lCtx, lEnum.AsInteger);');

  SOME_CTX_do_with_simple_enum(lCtx, lEnum.AsInteger);
end;

procedure Example2;
var
  lCtx: PSomeCtx;
  lRawVal: Integer;
  lEnum: TSimpleTestEnum;
begin
  Writeln(sLineBreak+'--- Example #2: Receiving from C-API ---');
  Writeln('Objective: Safely convert raw int from C-API to Pascal Enum.');

  // Mocking return value
  lRawVal:=SOME_CTX_get_simple_enum(lCtx);

  Writeln(sLineBreak+'  [Code]');
  Writeln('  lRawVal:=SOME_CTX_get_simple_enum(lCtx); // Returns '+lRawVal.ToString);
  Writeln('  lEnum:=TSimpleTestEnum.FromInteger(lRawVal);');

  try
    lEnum:=TSimpleTestEnum.FromInteger(lRawVal);
    Writeln('  [Result] Converted to Enum: '+GetEnumName(TypeInfo(TSimpleTestEnum), Ord(lEnum)));
  except
    on E: ERangeError do
      Writeln('  [Result] Error: Value out of range!');
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
