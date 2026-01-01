program Records_03_AtomicInt;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections,
  Playground.Utils in '..\..\Common\Playground.Utils.pas',
  Playground.Records.Atomic in 'Playground.Records.Atomic.pas',
  Playground.Records.Atomic.Threads in 'Playground.Records.Atomic.Threads.pas';

procedure Example1_Arithmetic;
var
  lAtom: TAtomicInt;
begin
  Writeln('--- Example #1: Atomic Arithmetic ---');

  // 1. Initialization
  lAtom := 10;
  Writeln(sLineBreak + '  [Code] lAtom := 10;');
  Writeln('  [Result] Value: ' + lAtom.Value.ToString);

  // 2. Increment (Default Parameter)
  Writeln(sLineBreak + '  [Code] lAtom.Increment; // Default +1');
  lAtom.Increment;
  Writeln('  [Result] Value: ' + lAtom.Value.ToString);

  // 3. Increment by Amount
  Writeln(sLineBreak + '  [Code] lAtom.Increment(5);');
  lAtom.Increment(5);
  Writeln('  [Result] Value: ' + lAtom.Value.ToString);
end;

procedure Example2_CAS;
var
  lAtom: TAtomicInt;
  lSuccess: Boolean;
  lPrev: Integer;
begin
  Writeln(sLineBreak + '--- Example #2: Compare & Exchange ---');

  lAtom := 100;
  Writeln('  [Initial] ' + lAtom.Value.ToString);

  // 1. Boolean Overload (Simple Check)
  // Fail case: Expected 50, Actual 100
  Writeln(sLineBreak + '  [Code] if CompareExchange(New=200, Expected=50) ...');
  if lAtom.CompareExchange(200, 50) then
    Writeln('  [Result] Swapped! (Unexpected)')
  else
    Writeln('  [Result] Failed. Value is still ' + lAtom.Value.ToString);

  // 2. Detailed Overload (Out Success + Old Value)
  // Success case: Expected 100, Actual 100
  Writeln(sLineBreak + '  [Code] lPrev := CompareExchange(200, 100, lSuccess);');
  lPrev := lAtom.CompareExchange(200, 100, lSuccess);

  if lSuccess then
    Writeln(Format('  [Result] Swapped! Old: %d, New: %d', [lPrev, lAtom.Value]))
  else
    Writeln('  [Result] Failed.');
end;

procedure Example3_Assignment;
var
  lAtom1, lAtom2: TAtomicInt;
begin
  Writeln(sLineBreak + '--- Example #3: Atomic Assignment ---');

  lAtom1 := 50;
  lAtom2 := 100;

  // Operator Assign (Triggers TAtomicInt.Assign -> Exchange)
  Writeln('  [Code] lAtom1 := lAtom2; // Atomic Copy');
  lAtom1 := lAtom2;

  Writeln(Format('  [Result] Atom1: %d, Atom2: %d', [lAtom1.Value, lAtom2.Value]));
end;

procedure Example4_MultipleThreads;
const
  cCountDownVal = MaxInt div 64-1; // Increased count to make the race visible
  cWriterCount = 8;
  cReaderCount = 16;
  cWaitTimout = 125;
  cWaitCount  = 80;

var
  lRunner: TRunner;
  
begin
  Writeln(sLineBreak + '--- Example #4: Multithreaded Countdown ---');
  
  lRunner:=TRunner.Create(cCountDownVal, cWriterCount, cReaderCount);
  try
    Writeln(
      Format('  Counter from %4.0n to 0; Writer threads: %d; Reader threads: %d',
      [(cCountDownVal+0.0), cWriterCount, cReaderCount])
    );
    lRunner.Run(cWaitCount, cWaitTimout);
  finally
    lRunner.Free;
  end;
end;

begin
  try
    Example1_Arithmetic;
    NextSlide;

    Example2_CAS;
    NextSlide;

    Example3_Assignment;
    NextSlide;

    Example4_MultipleThreads;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  PromptForCompletion;
end.
