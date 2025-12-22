(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

program SimpleTypes_03_SimpleEnum;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Playground.Utils in '..\..\Common\Playground.Utils.pas',
  Playground.Helpers.SimpleTypes in 'Playground.Helpers.SimpleTypes.pas';

// Define the names array closer to usage for clarity
const
  cFruitNames: TFruitHelper.TNames =
    ('?', 'Apple', 'Citrus', 'Orange', 'Papaya', 'Pear');

procedure Example1;
var
  lFruit: TFruit;
  lInt: Integer;
begin
  Writeln('--- Example #1: Safe Integer Conversion ---');
  Writeln('Objective: Convert integer to Enum safely (Valid vs Invalid).');

  // 1. Invalid Case
  lInt:=99;
  lFruit:=TFruit.FromInteger(lInt);

  Writeln(sLineBreak+'  [Code]');
  Writeln('  lInt:=99;');
  Writeln('  lFruit:=TFruitHelper.FromInteger(lInt);');
  Writeln('  // Result is frUnknown because 99 is out of range');

  Writeln('  [Result] Fruit Name: '+lFruit.ToString(cFruitNames));

  // 2. Valid Case
  lInt:=1; // Apple
  lFruit:=TFruit.FromInteger(lInt);

  Writeln(sLineBreak+'  [Code]');
  Writeln('  lInt:=1; // Apple');
  Writeln('  lFruit:=TFruit.FromInteger(lInt);');

  Writeln('  [Result] Fruit Name: '+lFruit.ToString(cFruitNames));
end;

procedure Example2;
var
  lFruit: TFruit;
begin
  Writeln(sLineBreak+'--- Example #2: String Parsing ---');
  Writeln('Objective: Parse strings to Enum (Case Insensitive).');

  // 1. Parsing "orange"
  Writeln(sLineBreak+'  [Code]');
  Writeln('  lFruit:=TFruit.FromString(''orange'', cFruitNames, False);');

  lFruit:=lFruit.FromString('orange', cFruitNames, False);
  Writeln('  [Result] Ordinal Value: '+lFruit.AsInteger.ToString);
  Writeln('  [Result] Enum Name: '+lFruit.ToString(cFruitNames));

  // 2. Parsing Garbage
  Writeln(sLineBreak+'  [Code]');
  Writeln('  lFruit:=TFruit.FromString(''tomato'', cFruitNames, False);');

  lFruit:=TFruit.FromString('tomato', cFruitNames, False);
  Writeln('  [Result] Enum Name: '+lFruit.ToString(cFruitNames));
end;

procedure Example3;
var
  lFruit: TFruit;
begin
  Writeln(sLineBreak+'--- Example #3: Metadata Attachment ---');
  Writeln('Objective: Use Helper constants to iterate valid items.');

  Writeln(sLineBreak+'  [Code]');
  Writeln('  for lFruit:=cMinFruit to cMaxFruit do ...');

  Write('  [Result] Valid Fruits: ');
  for lFruit:=TFruit.MinFruit to TFruit.MaxFruit do
  begin
    Write(lFruit.ToString(cFruitNames)+' ');
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
