(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

unit Playground.Utils;

interface

uses
  System.SysUtils
{$IFDEF MSWINDOWS}
  ,Winapi.Windows
{$ENDIF}
  ;

function GetExceptionString(E: Exception): string;

procedure NextSlide;

procedure PromptForCompletion;

procedure ClearLine;

procedure ClearScreen;

implementation

{$REGION 'support procedures'}
function GetExceptionString(E: Exception): string;
begin
  if not Assigned(E) then
    Exit;
  Result := Format('Exception %s: "%s"', [E.ClassName, E.Message]);
end;

const
  sClrScr = #$1b'[2J';
  sClrLine = #$1b'[2K';
  sLineUp = #$1b'[1A';

procedure ClearLine;
begin
  Write(sLineUp, sClrLine);
end;

procedure ClearScreen;
begin
  Write(sClrScr);
end;

procedure NextSlide;
begin
  Writeln(sLineBreak+
  '''
  Press Enter key for the next slide,
  or Ctrl+C to terminate;
  ''');
  Readln;
  ClearScreen;
end;

procedure PromptForCompletion;
begin
  Writeln(sLineBreak+'Press Enter key to complete.');
  Readln;
end;
{$ENDREGION}

{$REGION 'Platform Specific Initialization'}
{$IFDEF MSWINDOWS}
procedure EnableVTMode;
var
  hOut: THandle;
  dwMode: DWORD;
const
  ENABLE_VIRTUAL_TERMINAL_PROCESSING = $0004;
begin
  hOut := GetStdHandle(STD_OUTPUT_HANDLE);
  if hOut = INVALID_HANDLE_VALUE then Exit;

  if GetConsoleMode(hOut, dwMode) then
  begin
    dwMode := dwMode or ENABLE_VIRTUAL_TERMINAL_PROCESSING;
    SetConsoleMode(hOut, dwMode);
  end;
end;
{$ENDIF}
{$ENDREGION}

initialization
{$IFDEF MSWINDOWS}
  SetConsoleOutputCP(CP_UTF8);
  EnableVTMode;
  ClearScreen;
{$ENDIF}

end.
