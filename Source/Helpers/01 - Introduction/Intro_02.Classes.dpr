(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

program Intro_02.Classes;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Data.Bind.ObjectScope,
  Playground.Utils,
  Intro_02.Classes.res in 'Intro_02.Classes.res.pas';

{$REGION 'TStringsHelper Declaration and Implementation'}

type
  TStringsHelper = class helper for TStrings
  private
    function GetIsEmpty: boolean;
  public
    function Append(AStrings: TStrings; AAddDivider: boolean = False;
      ADivider: string = ''): TStrings; overload;
    function Append(AStringsArray: TArray<TStrings>;
      AAddDivider: boolean = False; ADivider: string = ''): TStrings; overload;
    property IsEmpty: boolean read GetIsEmpty;
  end;

{ TStringsHelper }

function TStringsHelper.Append(AStrings: TStrings; AAddDivider: boolean;
  ADivider: string): TStrings;
var
  lStr: string;

begin
  Result:=Self;
  if not Assigned(AStrings) then
    Exit;

  // Sustainability: Always use Begin/EndUpdate when bulk modifying UI-bound lists
  BeginUpdate;
  try
    if AAddDivider then
      Add(ADivider);
    for lStr in AStrings do
    begin
      Add(lStr);
    end;
  finally
    EndUpdate;
  end;
end;

function TStringsHelper.Append(AStringsArray: TArray<TStrings>;
  AAddDivider: boolean; ADivider: string): TStrings;
var
  lStrings: TStrings;

begin
  Result:=Self;

  // Sustainability: Always use Begin/EndUpdate when bulk modifying UI-bound lists
  // TStrings and descendants support recusive BeginUpdate/EndUpdate.
  BeginUpdate;
  try
    for lStrings in AStringsArray do
      Append(lStrings, AAddDivider, ADivider);
  finally
    EndUpdate;
  end;
end;

function TStringsHelper.GetIsEmpty: boolean;
begin
  Result:=Count = 0;
end;

{$ENDREGION}

{$REGION 'Support Routines'}

function NewStrings(const AString: string): TStrings;
begin
  Result:=nil;
  try
    Result:=TStringList.Create;
    if not AString.IsEmpty then
      Result.Text:=AString;
  except
    Result.Free;
    raise;
  end;
end;

function GetStringsInfo(const AStrings: TStrings): string;
const
  cFormatStr = sLineBreak +
    '    Instance of: ''%s''' + sLineBreak +
    '    Lines: %d' + sLineBreak +
    '    Text length: %d';
  cFormatStrEmpty = '    Instance of ''%s'' has no strings.';

begin
  if Assigned(AStrings) then
  begin
    if AStrings.IsEmpty then
      Result:=Format(cFormatStrEmpty, [AStrings.ClassName])
    else
      Result:=Format(cFormatStr, [AStrings.ClassName, AStrings.Count,
        AStrings.Text.Length])
  end
  else
    Result:='<unassigned>';
end;


procedure PrintStringsContent(const AStrings: TStrings);
var
  lAnswer: string;

begin
  Write(sLineBreak+'Press ''p'' key  and then Enter key '+
    'if you like print TStrings instance content or '+
    'press Enter key continue...');
  Readln(lAnswer);
  ClearLine;
  if lAnswer.StartsWith('P', True) then
  begin
    Writeln(sLineBreak + '  --- Content Start ---');
    if not AStrings.IsEmpty then
      Writeln(AStrings.Text);
    Writeln('  --- Content End ---');
  end;
end;

function BuildStrings(const AString: string): TStrings;
begin
  Result:=nil;
  try
    Result:=NewStrings(AString);
    Writeln(GetStringsInfo(Result));
    PrintStringsContent(Result);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

{$ENDREGION}

{$REGION 'Example #1: The "IsEmpty" Property'}

procedure Example1;
var
  lStrings: TStrings;

begin
  Writeln('--- Example #1: The "IsEmpty" Property ---');
  Writeln('Objective: Readability. Replace "if Count = 0" with "if IsEmpty".');

  begin
    Writeln(sLineBreak + '  [Test 1: Empty Instance]');
    lStrings:=NewStrings(string.Empty);
    try
      Writeln(GetStringsInfo(lStrings));
      PrintStringsContent(lStrings);
    finally
      lStrings.Free;
    end;
  end;

  begin
    Writeln(sLineBreak + '  [Test 2: Populated Instance]');
    lStrings:=NewStrings(cLoreIpsum4x64);
    try
      Writeln(GetStringsInfo(lStrings));
      PrintStringsContent(lStrings);
  finally
      lStrings.Free;
    end;
  end;
end;

{$ENDREGION}

{$REGION 'Example #2: The "Append" Method'}

procedure Example2;
var
  lMainList, lSourceList: TStrings;

begin
  Writeln(sLineBreak + '--- Example #2: The "Append" Method ---');
  Writeln('Objective: Sustainability. Add logic to TStrings without subclassing.');

  lMainList:=nil;
  lSourceList:=nil;
  try
    Writeln(sLineBreak + '  1. Main List:');
    lMainList:=BuildStrings(cLoreIpsum4x64);

    Writeln(sLineBreak + '  2. Source List to Append:');
    lSourceList:=BuildStrings(cCicero2x48);

    Writeln(sLineBreak + '  3. Executing: lMainList.Append(lSourceList);');
    lMainList.Append(lSourceList);
    Writeln(GetStringsInfo(lMainList));
    PrintStringsContent(lMainList);

  finally
    lSourceList.Free;
    lMainList.Free;
  end;
end;

{$ENDREGION}

{$REGION 'Example #3: Fluent Interface (Method Chaining)'}

procedure Example3;
var
  lMainList, lCiceroList, lFarFarAwayList, lPanagramList: TStrings;

begin
  Writeln(sLineBreak + '--- Example #3: Fluent Interface (Method Chaining) ---');
  Writeln('Objective: Readability via chaining.');

  lMainList:=nil;
  lCiceroList:=nil;
  lFarFarAwayList:=nil;
  lPanagramList:=nil;
  try
    Writeln(sLineBreak + '  1. Main List:');
    lMainList:=BuildStrings(cLoreIpsum4x64);

    Writeln(sLineBreak + '  2. Cicero List:');
    lCiceroList:=BuildStrings(cCicero2x48);

    Writeln(sLineBreak + '  3. FarFarAway List:');
    lFarFarAwayList:=BuildStrings(cFarFarAway4x72);

    Writeln(sLineBreak + '  4. Panagram List:');
    lPanagramList:=BuildStrings(cPanagram3x64);


    Writeln(sLineBreak + '  5. Executing: lMainList.Append(lCiceroList, ...)'+
      '.Append(lCiceroList, ...).Append(lFarFarAwayList, ...)'+
      '.Append(lPanagramList, ...)');
    Writeln(GetStringsInfo(
      lMainList.Append(lCiceroList, True, '<-- Cicero sentences added -->' )
               .Append(lFarFarAwayList, True, '<-- FarFarAway sentences added -->')
               .Append(lPanagramList, True, '<-- Panagram sentences added -->')
    ));
    PrintStringsContent(lMainList);

  finally
    lMainList.Free;
    lCiceroList.Free;
    lFarFarAwayList.Free;
    lPanagramList.Free;
  end;
end;

{$ENDREGION}

{$REGION 'Example #4: Batch Appending'}

procedure Example4;
const
  cStringsSrc: array[0..2] of string =
    (cCicero2x48, cFarFarAway4x72, cPanagram3x64);

var
  lMainList, lTempList: TStrings;
  lBatchList : TObjectList<TStrings>;
  i: integer;

begin
  Writeln(sLineBreak + '--- Example #4: Batch Appending ---');
  Writeln('Objective: Safety. Encapsulating the loop and separators.');

  lMainList:=nil;
  lTempList:=nil;
  lBatchList:=nil;

  try
    Writeln(sLineBreak+'  Initializing a single instance of TStrings.');
    lMainList:=BuildStrings(cLoreIpsum4x64);

    Writeln(sLineBreak + '  Preparing batch list...');
    lBatchList:=TObjectList<TStrings>.Create(True);
    lBatchList.Capacity:=Length(cStringsSrc);

    for i:=Low(cStringsSrc) to High(cStringsSrc) do
    begin
      lTempList:=NewStrings(cStringsSrc[i]);
      Writeln(Format('    - Adding list [%d] (%d strings; %d chars)',
        [i, lTempList.Count, lTempList.Text.Length]));
      lBatchList.Add(lTempList);
      lTempList:=nil;
    end;

    Writeln(sLineBreak + '  Executing: lMainList.Append(BatchArray, True, ''<<<--->>>'');');
    lMainList.Append(lBatchList.ToArray, True, '<<<--->>>');

    Writeln(GetStringsInfo(lMainList));
    PrintStringsContent(lMainList);

  finally
    lTempList.Free;
    lBatchList.Free;
    lMainList.Free;
  end;
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
    NextSlide;

    Example4;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  PromptForCompletion;
end.
