(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

program _01_Introduction.SimpleTypes;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Playground.Utils in 'Playground.Utils.pas';

{$REGION 'Example #1: Integer to String Conversion'}
function GetClassicSum(AItem1, AItem2: integer): string;
var
  lIntStr1, lIntStr2, lStrSum: string;

begin
  lIntStr1:=IntToStr(AItem1);
  lIntStr2:=IntToStr(AItem2);
  lStrSum:= IntToStr(AItem1+AItem2);

  Result:='Sum of ' + lIntStr1 + ' and ' + lIntStr2 + ' is ' + lStrSum + '.';
end;

function GetModernSum(AItem1, AItem2: integer): string;
begin

  // Helper syntax allows chaining and inline conversion
  Result:='Sum of ' + AItem1.ToString + ' and ' + AItem2.ToString +
          ' is ' + (AItem1 + AItem2).ToString + '.';

end;

procedure Example1;
begin
  Writeln('--- Example #1: Integer Helpers ---');
  Writeln('Objective: Calculate sum and format a result string.');

  Writeln(sLineBreak+'  [Classic Approach]');
  Writeln('  lStrSum:=IntToStr(AItem1 + AItem2);');
  Writeln('  Result: '+GetClassicSum(1, 2));

  Writeln(sLineBreak+'  [Modern Approach]');
  Writeln('  Result:=''...''+(AItem1 + AItem2).ToString+''...'';');
  Writeln('  Result: '+GetModernSum(1, 2));
end;
{$ENDREGION}

{$REGION 'Example #2: String to Numeric Conversion'}
function GetClassicProduct(AFactor1, AFactor2: string): string;
var
  lFactor1: integer;
  lFactor2: Extended;
  lProductStr: string;

begin
  try
    lFactor1:=StrToInt(AFactor1);
    lFactor2:=StrToFloat(AFactor2);
    lProductStr:=FloatToStr(lFactor1*lFactor2);

    Result:='Product of ' + AFactor1 + ' and ' + AFactor2 + ' is ' +
      lProductStr + '.';

  except
    // Note: In real code, handle error or re-raise.
    // Using GetExceptionString for demo purposes.
    on E: Exception do
      Writeln(GetExceptionString(E));
  end;
end;

function GetModernProduct(AFactor1, AFactor2: string): string;
begin
  try

    // Helpers allow conversion directly on the variable
    Result:='Product of '+AFactor1+' and '+AFactor2+' is '+
      (AFactor1.ToInteger*AFactor2.ToExtended).ToString+'.';

  except
    // Note: In real code, handle error or re-raise.
    // Using GetExceptionString for demo purposes.
    on E: Exception do
      Writeln(GetExceptionString(E));
  end;
end;

procedure Example2;
begin
  Writeln(sLineBreak+'--- Example #2: String Helpers for Parsing ---');
  Writeln('Objective: Parse strings to numbers, multiply, and format.');

  Writeln(sLineBreak+'  [Classic Approach]');
  Writeln('  lFactor1:=StrToInt(AFactor1);');
  Writeln('  Result: '+GetClassicProduct('3', '2.5E-2'));

  Writeln(sLineBreak+'  [Modern Approach]');
  Writeln('  (AFactor1.ToInteger * AFactor2.ToExtended).ToString');
  Writeln('  Result: '+GetModernProduct('3', '2.5E-2'));
end;
{$ENDREGION}

{$REGION 'Example #3'}
function GetStringUpdateClassic(AStr: string): string;
begin
  AStr:=Trim(AStr);
  if AStr = '' then
    Exit('');

  Result:=QuotedStr(AnsiUpperCase(AStr[1]) + AnsiLowerCase(Copy(AStr, 2)) + '.');
end;

function GetStringUpdateModern(AStr: string): string;
begin
  AStr:=AStr.Trim;
  if not AStr.IsEmpty then
    // Modern: Methods belong to the data. Fluent interface.
    // CRITICAL: Helpers use 0-based indexing!
    Result:=(
      AStr.Substring(0,1).ToUpperInvariant +
      AStr.Substring(1).ToLowerInvariant +
      '.'
    ).QuotedString('''')  // Matching Classic QuotedStr behavior
  else
    Result:=string.Empty;
end;

procedure Example3;
begin
  Writeln(sLineBreak+'--- Example #3. ---');
  Writeln(
    'Transforms string as below and returns it as result'+sLineBreak+
    '* Trims unprintable characters and spaces'+sLineBreak+
    '* Transforms first character to upper case according Unicode specification'+sLineBreak+
    '* Transforms rest of the string to lower case according Unicode specification'+sLineBreak+
    '* Adds the final dot (''.'') character'+sLineBreak+
    '* Quotes the result.)'
    );
  Writeln(sLineBreak+'  Classic code:'+sLineBreak);
  Writeln(sLineBreak+'  function call: "GetStringUpdateClassic(''  this is a sample string     '')');
  Writeln('  Returns: '+
    GetStringUpdateClassic(
      '  this is a sample string     '
    )
  );

  Writeln(sLineBreak+'  function call: "GetStringUpdateClassic(#8#9''to jest prosty ciąg ZNAKÓW     '')');
  Writeln('  Returns: '+
    GetStringUpdateClassic
    (
      #8#9'to jest prosty ciąg ZNAKÓW     '
    )
  );

  Writeln(sLineBreak+'  Modern code:'+sLineBreak);
  Writeln(sLineBreak+'  function call: "GetStringUpdateModern(''  this is a sample string     '')');
  Writeln('  Returns: '+
    GetStringUpdateModern(
      '  this is a sample string     '
    )
  );

  Writeln(sLineBreak+'  function call: "GetStringUpdateModern(#8#9''to jest prosty ciąg ZNAKÓW     '')');
  Writeln('  Returns: '+
    GetStringUpdateModern(
      #8#9'to jest prosty ciąg ZNAKÓW     '
    )
  );
end;
{$ENDREGION}

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    Example1;
    NextSlide;

    Example2;
    NextSlide;

    Example3;

  except
    on E: Exception do
      Writeln(GetExceptionString(E));
  end;

  PromptForCompletion;
end.
