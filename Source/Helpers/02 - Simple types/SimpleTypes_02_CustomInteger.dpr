program SimpleTypes_02_CustomInteger;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Playground.Utils in '..\..\Common\Playground.Utils.pas',
  Playground.Helpers.SimpleTypes in 'Playground.Helpers.SimpleTypes.pas';

procedure Example1;
var
  lVal: TMyInt;
  lIsInRange: TMyBool;
begin
  Writeln('--- Example #1: Validation Logic ---');
  Writeln('Objective: Check if a value is within a specific range.');

  // 1. Failure Case
  lVal:=150;
  Writeln(sLineBreak+'  [Code]');
  Writeln('  lVal:=150;');
  Writeln('  lIsInRange:=lVal.IsBetween(0, 100);');

  lIsInRange:=lVal.IsBetween(0, 100);
  Writeln('  [Result] Is 150 in range 0..100? '+lIsInRange.AsString);

  // 2. Success Case (Positive Example)
  lVal:=50;
  Writeln(sLineBreak+'  [Code]');
  Writeln('  lVal:=50;');
  Writeln('  lIsInRange:=lVal.IsBetween(0, 100);');

  lIsInRange:=lVal.IsBetween(0, 100);
  Writeln('  [Result] Is 50 in range 0..100? '+lIsInRange.AsString);
end;

procedure Example2;
var
  lVal: TMyInt;
begin
  Writeln(sLineBreak+'--- Example #2: Clamping Logic ---');
  Writeln('Objective: Restrict a value to a specific range.');

  // 1. High Clamp
  lVal:=150;
  Writeln(sLineBreak+'  [Code]');
  Writeln('  lVal:=150; // Above Max');
  Writeln('  Result:=lVal.EnsureBetween(0, 100);');
  Writeln('  [Result] '+lVal.EnsureBetween(0, 100).ToString);

  // 2. Low Clamp
  lVal:=-50;
  Writeln(sLineBreak+'  [Code]');
  Writeln('  lVal:=-50; // Below Min');
  Writeln('  Result:=lVal.EnsureBetween(0, 100);');
  Writeln('  [Result] '+lVal.EnsureBetween(0, 100).ToString);

  // 3. No Clamp (Positive Example)
  lVal:=42;
  Writeln(sLineBreak+'  [Code]');
  Writeln('  lVal:=42; // Inside Range');
  Writeln('  Result:=lVal.EnsureBetween(0, 100);');
  Writeln('  [Result] '+lVal.EnsureBetween(0, 100).ToString);
end;

procedure Example3;
var
  lVal: TMyInt;
  lBool: TMyBool;
begin
  Writeln(sLineBreak+'--- Example #3: Parity and Bounds ---');
  Writeln('Objective: Check properties of the number using Helper Synergy.');

  lVal:=42;
  lBool:=lVal.IsEven; // Implicit conversion from Boolean to TMyBool

  Writeln(sLineBreak+'  [Code] lVal:=42; lBool:=lVal.IsEven;');
  Writeln('  [Result] IsEven? '+lBool.AsString);

  lVal:=Integer.MaxValue;
  lBool:=lVal.IsMax;

  Writeln(sLineBreak+'  [Code] lVal:=Integer.MaxValue; lBool:=lVal.IsMax;');
  Writeln('  [Result] IsMax? '+lBool.AsString);
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
