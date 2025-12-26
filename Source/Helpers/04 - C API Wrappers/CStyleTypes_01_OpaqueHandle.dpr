program CStyleTypes_01_OpaqueHandle;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Playground.Utils in '..\..\Common\Playground.Utils.pas',
  Playground.CStyleTypes in 'Playground.CStyleTypes.pas';

procedure PrintValue(AKey: TRegHandle; const AName: string);
begin
  if AKey.IsValid then
    Writeln(Format('  [Value] "%s" = "%s"', [AName, AKey.ReadString(AName, '<Empty>')]))
  else
    Writeln('  [Error] Invalid Handle');
end;

procedure Example1_HKCU;
var
  lKey: TRegHandle;
begin
  Writeln('--- Example #1: HKCU International ---');
  Writeln('  [Code] OpenCurrentUser(''Control Panel\International'')');

  lKey:=TRegHandle.OpenCurrentUser('Control Panel\International');
  try
    if lKey.IsValid then
      Writeln('  [Result] Opened Successfully')
    else
      Writeln('  [Result] Failed');

    PrintValue(lKey, 'sCountry');
  finally
    lKey.Close;
  end;
end;

procedure Example2_HKLM;
var
  lKey: TRegHandle;
begin
  Writeln(sLineBreak+'--- Example #2: HKLM Windows Version ---');
  Writeln('  [Code] OpenLocalMachine(''SOFTWARE\Microsoft\Windows NT\CurrentVersion'')');

  lKey:=TRegHandle.OpenLocalMachine('SOFTWARE\Microsoft\Windows NT\CurrentVersion');
  try
    if lKey.IsValid then
      PrintValue(lKey, 'ProductName')
    else
      Writeln('  [Result] Failed (Check permissions?)');
  finally
    lKey.Close;
  end;
end;

procedure Example3_Invalid;
var
  lKey: TRegHandle;
begin
  Writeln(sLineBreak+'--- Example #3: Invalid Key ---');
  Writeln('  [Code] OpenCurrentUser(''Software\Invalid\Key'')');

  lKey:=TRegHandle.OpenCurrentUser('Software\Invalid\Key');
  try
    if not lKey.IsValid then
      Writeln('  [Result] Failed gracefully (Handle is 0). Correct.')
    else
      Writeln('  [Result] Unexpected success?');
  finally
    lKey.Close; // Safe to call on 0
  end;
end;

begin
  try
    {$IFDEF MSWINDOWS}
    Example1_HKCU;
    NextSlide;

    Example2_HKLM;
    NextSlide;

    Example3_Invalid;

    {$ELSE}
    Writeln('This demo requires MS Windows.');
    {$ENDIF}
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  PromptForCompletion;
end.
