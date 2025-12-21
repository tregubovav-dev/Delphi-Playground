program SimpleTypes_01_CustomBoolean;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Playground.Utils in '..\..\Common\Playground.Utils.pas',
  Playground.Helpers.SimpleTypes in 'Playground.Helpers.SimpleTypes.pas';

procedure Example1;
var
  lStandard: Boolean;
  lMyBool: TMyBool;
begin
  Writeln('--- Example #1: Type Compatibility ---');
  Writeln('Objective: Show that TMyBool is assignment-compatible with Boolean.');

  Writeln(sLineBreak+'  [Code]');
  Writeln('  lMyBool:=False;');

  lMyBool:=False;
  Writeln('  [Result] '+lMyBool.AsString);

  Writeln(sLineBreak+'  [Code]');
  Writeln('  lStandard:=True;');
  Writeln('  lMyBool:=lStandard;');

  lStandard:=True;
  lMyBool:=lStandard;
  Writeln('  [Result] '+lMyBool.AsString);
end;

procedure Example2;
var
  lMyBool: TMyBool;
begin
  Writeln(sLineBreak+'--- Example #2: Formatting and Properties ---');
  Writeln('Objective: Demonstrate Helper formatting methods.');

  lMyBool:=True;

  Writeln(sLineBreak+'  [Code] Writeln(lMyBool.AsString);');
  Writeln('  [Result] '+lMyBool.AsString);

  Writeln(sLineBreak+'  [Code] Writeln(lMyBool.ToString(''Active'', ''Inactive''));');
  Writeln('  [Result] '+lMyBool.ToString('Active', 'Inactive'));

  Writeln(sLineBreak+'  [Code] Writeln(lMyBool.AsInteger.ToString);');
  Writeln('  [Result] '+lMyBool.AsInteger.ToString);

  Writeln(sLineBreak+'  [Code]');
  Writeln('  lMyBool.AsInteger:=0;');
  Writeln('  Writeln(lMyBool.AsString);');
  lMyBool.AsInteger:=0;
  Writeln('  [Result] '+lMyBool.AsString);
end;

procedure Example3;
var
  lMyBool: TMyBool;
begin
  Writeln(sLineBreak+'--- Example #3: Parsing ---');
  Writeln('Objective: Parse domain-specific strings into Boolean.');

  Writeln(sLineBreak+'  [Code]');
  Writeln('  TMyBool.TryFromString(''active'', ''Active'', ''Inactive'', False, lMyBool);');

  if TMyBool.TryFromString('active', 'Active', 'Inactive', False, lMyBool) then
    Writeln('  [Result] Success -> '+lMyBool.AsString)
  else
    Writeln('  [Result] Failed');

  Writeln(sLineBreak+'  [Code]');
  Writeln('  TMyBool.TryFromString(''OFF'', ''On'', ''Off'', False, lMyBool);');

  if TMyBool.TryFromString('OFF', 'On', 'Off', False, lMyBool) then
    Writeln('  [Result] Success -> '+lMyBool.AsString);
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
