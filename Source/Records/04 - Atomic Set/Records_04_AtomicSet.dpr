(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

program Records_04_AtomicSet;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections,
  Playground.Utils in '..\..\Common\Playground.Utils.pas',
  Playground.Records.AtomicSet in 'Playground.Records.AtomicSet.pas';

// -----------------------------------------------------------------------------
// Example 1: Syntax & Operators
// -----------------------------------------------------------------------------
procedure Example1;
var
  lSet: TAtomicSet;
begin
  Writeln('--- Example #1: Syntax & Operators ---');
  Writeln('Objective: Demonstrate Pascal-like syntax on the atomic wrapper.');

  // 1. Implicit Assignment
  lSet:=[afRunning, afCanceling];
  Writeln(sLineBreak+'  [Code] lSet:=[afRunning, afCanceling];');

  // Use AsInteger for Hex Output
  Writeln(Format('  [Result]: %s', [lSet.Value.AsString]));

  // 2. Set Arithmetic (+)
  Writeln(sLineBreak+'  [Code] lSet:=lSet+afFailing;');
  lSet:=lSet+afFailing;

  // 3. "In" Operator with clean ToString
  Writeln('  [Result] Is afFailed in Set? ' +
    (afFailing in lSet).ToString(TUseBoolStrs.True));

  // 4. Subtract (-)
  Writeln(sLineBreak+'  [Code] lSet:=lSet-[afRunning];');
  lSet:=lSet-[afRunning];

  Writeln('  [Result] Is afRunning in Set? ' +
    (afRunning in lSet).ToString(TUseBoolStrs.True));
end;

// -----------------------------------------------------------------------------
// Example 2: Atomic API
// -----------------------------------------------------------------------------
procedure Example2;
var
  lSet: TAtomicSet;
begin
  Writeln(sLineBreak+'--- Example #2: Atomic Operations ---');
  Writeln('Objective: Thread-safe modifications.');

  lSet:=[];

  // 1. Atomic Include
  Writeln(sLineBreak+'  [Code] AtomicInclude(afRunning)');
  lSet.AtomicInclude(afRunning);

  if afRunning in lSet then
    Writeln(Format('  [Result] afRunning set. Value: %s', [lSet.Value.AsString]));

  // 2. Atomic Transition (CAS)
  Writeln(sLineBreak +
    '  [Code] AtomicTransition([afRunning], [afRunning, afCanceling])');
  // Logic: If set contains ONLY afRunning, add afCanceling.
  if lSet.AtomicTransition([afRunning], [afRunning, afCanceling]) then
    Writeln(
      Format('  [Result] Success. Transitioned. Value: %s',[lSet.Value.AsString])
    )
  else
    Writeln('  [Result] Failed.');

  if afCanceling in lSet then Writeln('  [Result] afCanceling is now set.');
end;

// -----------------------------------------------------------------------------
// Example 3: The Flag Race (Stress Test)
// -----------------------------------------------------------------------------
type
  PAtomicSet = ^TAtomicSet;

  TFlagSetter = class(TThread)
  private
    FTarget: PAtomicSet;
    FFlag: TAtomicFlag;
  protected
    procedure Execute; override;
  public
    constructor Create(ATarget: PAtomicSet; AFlag: TAtomicFlag);
  end;

constructor TFlagSetter.Create(ATarget: PAtomicSet; AFlag: TAtomicFlag);
begin
  inherited Create(True);
  FTarget:=ATarget;
  FFlag:=AFlag;
  FreeOnTerminate:=False;
end;

procedure TFlagSetter.Execute;
begin
  // Race condition generator:
  // Multiple threads try to update the SAME bytes simultaneously.
  // Standard "OR" would lose bits. AtomicInclude guarantees safety via CAS loop.
  FTarget^.AtomicInclude(FFlag);
end;

procedure Example3;
var
  lSharedSet: TAtomicSet;
  lThreads: TObjectList<TFlagSetter>;
  lEnum: TAtomicFlag;
  lMissing: Boolean;
begin
  Writeln(sLineBreak+'--- Example #3: Multithreaded Flag Race ---');
  Writeln(
    Format('Objective: %d Threads set %0:d different flags simultaneously.',
      [Succ(Ord(High(TAtomicFlag)))])
  );

  lSharedSet:=[];
  lThreads:=TObjectList<TFlagSetter>.Create;

  try
    // Create 7 threads, each assigned one unique flag (afQueued..afPausing)
    for lEnum:=Low(TAtomicFlag) to High(TAtomicFlag) do
    begin
      lThreads.Add(TFlagSetter.Create(@lSharedSet, lEnum));
    end;

    Writeln(Format('  [Setup] Created %d threads.', [lThreads.Count]));

    // Start all
    for var t in lThreads do t.Start;

    // Wait for completion
    for var t in lThreads do t.WaitFor;

    // Verify
    Writeln(sLineBreak+'  [Verification]');
    lMissing:=False;

    for lEnum:=Low(TAtomicFlag) to High(TAtomicFlag) do
    begin
      if not (lEnum in lSharedSet) then
      begin
        Writeln(Format('  [Error] Flag %d is MISSING!', [Ord(lEnum)]));
        lMissing:=True;
      end;
    end;

    if not lMissing then
      Writeln(
        Format('  [Success] All flags present. Result: %s',
          [lSharedSet.Value.AsString])
      )
    else
      Writeln('  [Fail] Race condition detected.');

  finally
    lThreads.Free;
  end;
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
