program SimpleTypes_04_DynamicArray;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Playground.Utils in '..\..\Common\Playground.Utils.pas',
  Playground.Helpers.SimpleTypes in 'Playground.Helpers.SimpleTypes.pas';

procedure Example1;
var
  lTags: TStringArray;
begin
  Writeln('--- Example #1: Initialization & Factory ---');
  Writeln('Objective: Create a dynamic array using clean syntax.');

  // 1. Factory Create
  Writeln(sLineBreak + '  [Code]');
  Writeln('  lTags := TStringArray.Create([''Pascal'', ''Delphi'']);');

  lTags := TStringArray.Create(['Pascal', 'Delphi']);
  Writeln('  [Result] Created: ' + lTags.Join(','));

  // 2. Count Property
  Writeln(sLineBreak + '  [Code]');
  Writeln('  Writeln(lTags.Count.ToString);');
  Writeln('  [Result] Count: ' + lTags.Count.ToString);
end;

procedure Example2;
var
  lTags: TStringArray;
begin
  Writeln(sLineBreak + '--- Example #2: Fluent Modification ---');
  Writeln('Objective: Add and Insert items like a TStringList.');

  lTags := TStringArray.Create(['Pascal', 'Delphi']);
  Writeln('  [Initial] ' + lTags.Join(','));

  // 1. Add (Append)
  Writeln(sLineBreak + '  [Code]');
  Writeln('  lTags.Add(''Helpers'');');

  lTags.Add('Helpers');
  Writeln('  [Result] ' + lTags.Join(','));

  // 2. Insert (at beginning)
  Writeln(sLineBreak + '  [Code]');
  Writeln('  lTags.Insert(''Modern'', 0);');

  lTags.Insert('Modern', 0);
  Writeln('  [Result] ' + lTags.Join(','));
end;

procedure Example3;
var
  lTags: TStringArray;
begin
  Writeln(sLineBreak + '--- Example #3: Deletion & Performance ---');
  Writeln('Objective: Remove items and join string efficiently.');

  lTags := TStringArray.Create(['A', 'B', 'DeleteMe', 'C']);
  Writeln('  [Initial] ' + lTags.Join(','));

  // 1. Delete
  Writeln(sLineBreak + '  [Code]');
  Writeln('  lTags.Delete(2, 1); // Remove "DeleteMe"');

  lTags.Delete(2, 1);
  Writeln('  [Result] ' + lTags.Join(','));

  // 2. Join (Performance)
  Writeln(sLineBreak + '  [Code]');
  Writeln('  Result := lTags.Join('''#$2192''');');
  Writeln('  [Result] ' + lTags.Join(#$2192)); // right arrow symbol
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
