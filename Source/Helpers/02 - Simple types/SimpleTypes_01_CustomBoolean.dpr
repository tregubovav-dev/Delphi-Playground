program SimpleTypes_01_CustomBoolean;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Playground.Utils in '..\..\Common\Playground.Utils.pas',
  Playground.Helpers.SimpleTypes in 'Playground.Helpers.SimpleTypes.pas';

procedure Example1;
var
  LStandard: Boolean;
  LMyBool: TMyBool;
begin
  Writeln('--- Example #1: Type Compatibility ---');
  Writeln('Objective: Show that TMyBool is assignment-compatible with Boolean.');

  Writeln(sLineBreak + '  [Code]');
  Writeln('  LMyBool := False;');

  LMyBool := False;
  Writeln('  [Result] ' + LMyBool.AsString);

  Writeln(sLineBreak + '  [Code]');
  Writeln('  LStandard := True;');
  Writeln('  LMyBool := LStandard;');

  LStandard := True;
  LMyBool := LStandard;
  Writeln('  [Result] ' + LMyBool.AsString);
end;

procedure Example2;
var
  LMyBool: TMyBool;
begin
  Writeln(sLineBreak + '--- Example #2: Formatting and Properties ---');
  Writeln('Objective: Demonstrate Helper formatting methods.');

  LMyBool := True;

  Writeln(sLineBreak + '  [Code] Writeln(LMyBool.AsString);');
  Writeln('  [Result] ' + LMyBool.AsString);

  Writeln(sLineBreak + '  [Code] Writeln(LMyBool.ToString(''Active'', ''Inactive''));');
  Writeln('  [Result] ' + LMyBool.ToString('Active', 'Inactive'));

  Writeln(sLineBreak + '  [Code] Writeln(LMyBool.AsInteger.ToString);');
  Writeln('  [Result] ' + LMyBool.AsInteger.ToString);

  Writeln(sLineBreak + '  [Code]');
  Writeln('  LMyBool.AsInteger := 0;');
  Writeln('  Writeln(LMyBool.AsString);');
  LMyBool.AsInteger := 0;
  Writeln('  [Result] ' + LMyBool.AsString);
end;

procedure Example3;
var
  LMyBool: TMyBool;
begin
  Writeln(sLineBreak + '--- Example #3: Parsing ---');
  Writeln('Objective: Parse domain-specific strings into Boolean.');

  Writeln(sLineBreak + '  [Code]');
  Writeln('  TMyBool.TryFromString(''active'', ''Active'', ''Inactive'', False, LMyBool);');

  if TMyBool.TryFromString('active', 'Active', 'Inactive', False, LMyBool) then
    Writeln('  [Result] Success -> ' + LMyBool.AsString)
  else
    Writeln('  [Result] Failed');

  Writeln(sLineBreak + '  [Code]');
  Writeln('  TMyBool.TryFromString(''OFF'', ''On'', ''Off'', False, LMyBool);');

  if TMyBool.TryFromString('OFF', 'On', 'Off', False, LMyBool) then
    Writeln('  [Result] Success -> ' + LMyBool.AsString);
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
