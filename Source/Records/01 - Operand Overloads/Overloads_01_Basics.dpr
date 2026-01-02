(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

program Overloads_01_Basics;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Playground.Utils in '..\..\Common\Playground.Utils.pas',
  Playground.Records.Base in 'Playground.Records.Base.pas';

procedure Example1;
begin
  Writeln('--- Example #1: Size and Creation ---');

  // Prove zero overhead (Wrapper size == Type size)
  Writeln(Format('  SizeOf(double):     %d bytes', [SizeOf(double)]));
  Writeln(Format('  SizeOf(TDoubleRec): %d bytes', [SizeOf(TDoubleRec)]));

  Writeln(sLineBreak+'  [Code] var lRec:=TDoubleRec.Create(1.0E1);');
  var lRec:=TDoubleRec.Create(1.0E1);
end;

procedure Example2;
var
  lRec: TDoubleRec;
  lStr: string;
begin
  Writeln(sLineBreak+'--- Example #2: Implicit Conversion ---');
  Writeln('Objective: Seamless assignment between Record and String.');

  // Initialize
  lRec:=TDoubleRec.Create(1.0E1);

  // Rec -> String
  Writeln(sLineBreak+'  [Code] var lStr: string:=lRec;');
  lStr:=lRec; // Implicit Rec -> String

  // String -> Rec
  Writeln(sLineBreak+'  [Code] lStr:=''2.0E1''; lRec:=lStr;');
  lStr:='2.0E1';
  lRec:=lStr; // Implicit String -> Rec
end;

procedure Example3;
var
  lRec: TDoubleRec;
  lStr: string;
begin
  Writeln(sLineBreak+'--- Example #3: Explicit Conversion (Casting) ---');
  Writeln('Objective: Using hard casts like TType(Val) or string(Val).');

  lRec:=TDoubleRec.Create(2.0E1);

  // Rec -> String
  Writeln(sLineBreak+'  [Code] lStr:=string(lRec);');
  lStr:=string(lRec);

  // String -> Rec
  Writeln(sLineBreak+'  [Code] lStr:=''3.0E1''; lRec:=TDoubleRec(lStr);');
  lStr:='3.0E1';
  lRec:=TDoubleRec(lStr);

  // Error Handling
  Writeln(sLineBreak+'  [Code] lRec:=TDoubleRec(''Not a Number'');');
  try
    lRec:=TDoubleRec('This is not a number.');
  except
    on E: Exception do
      Writeln(Format('  [Result] Exception %s: "%s"', [E.ClassName, E.Message]));
  end;
end;

procedure Example4;
var
  lRec: TDoubleRec;
begin
  Writeln(sLineBreak+'--- Example #4: Equality Operators ---');
  Writeln('Objective: Comparing Record directly with String literals.');

  // 1. Equal (Rec = String)
  lRec:=TDoubleRec.Create(1.5);
  Writeln(sLineBreak+'  [Code] if lRec = ''1.5'' then ...');

  if lRec = '1.5' then
    Writeln('  [Result] Equal (Correct)')
  else
    Writeln('  [Result] Not Equal');

  // 2. Equal (String = Rec)
  lRec:=TDoubleRec.Create(1.5);
  Writeln(sLineBreak+'  [Code] if ''1.5'' = lRec then ...');

  if '1.5' = lRec then
    Writeln('  [Result] Equal (Correct)')
  else
    Writeln('  [Result] Not Equal');

  // 3. NotEqual (String <> Rec)
  // This triggers the specific operator NotEqual(string, TDoubleRec)
  lRec:=TDoubleRec.Create(15.0);
  Writeln(sLineBreak+'  [Code] if ''1.5'' <> lRec then ...');

  if '1.5' <> lRec then
    Writeln('  [Result] Not Equal (Correct)')
  else
    Writeln('  [Result] Equal (Unexpected)');

  // 4. NotEqual (Rec <> String)
  Writeln(sLineBreak+'  [Code] if lRec <> ''99.9'' then ...');
  if lRec <> '99.9' then
    Writeln('  [Result] Not Equal (Correct)');
end;

begin
  try
    Example1;
    NextSlide;

    Example2;
    NextSlide;

    Example3;
    NextSlide;

    Example4;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  PromptForCompletion;
end.
