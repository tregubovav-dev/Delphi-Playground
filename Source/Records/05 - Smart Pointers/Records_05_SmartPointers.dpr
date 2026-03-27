program Records_05_SmartPointers;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections,
  Playground.Utils in '..\..\Common\Playground.Utils.pas',
  Playground.Records.SmartPointer in 'Playground.Records.SmartPointer.pas';

// =============================================================================
// HELPER TYPES FOR DEMOS
// =============================================================================

type
  PExampleRec = ^TExampleRec;
  TExampleRec = record
  private
    FName: string;
    FNumber: Integer;
  public
    constructor Create(const AName: string; ANumber: Integer);
    property Name: string read FName write FName;
    property Number: Integer read FNumber write FNumber;
  end;

  TExamplePtr = TSmartPointer<TExampleRec>;

  TExamplePtrHelper = record helper for TExamplePtr
  private
    function GetName: string;
    function GetNumber: Integer;
    procedure SetName(const AValue: string);
    procedure SetNumber(const AValue: Integer);
  public
    procedure PrintValue(AIndent: Integer; const AName: string);
    property Name: string read GetName write SetName;
    property Number: Integer read GetNumber write SetNumber;
  end;

  // A simple class to demonstrate ARC (Automatic Reference Counting)
  TDummyObj = class
  private
    FName: string;
  public
    constructor Create(const AName: string);
    destructor Destroy; override;
    procedure DoWork(AValue: string);
  end;

{ TExampleRec }
constructor TExampleRec.Create(const AName: string; ANumber: Integer);
begin
  FName:=AName;
  FNumber:=ANumber;
end;

{ TExamplePtrHelper }
function TExamplePtrHelper.GetName: string;
begin
  if not IsAssigned then raise Exception.Create('[TExamplePtr] No value assigned.');
  Result:=ValuePtr^.Name; // Access heap memory directly
end;

procedure TExamplePtrHelper.SetName(const AValue: string);
begin
  if not IsAssigned then raise Exception.Create('[TExamplePtr] No value assigned.');
  ValuePtr^.Name:=AValue; // Modify heap memory directly
end;

function TExamplePtrHelper.GetNumber: Integer;
begin
  if not IsAssigned then raise Exception.Create('[TExamplePtr] No value assigned.');
  Result:=ValuePtr^.Number;
end;

procedure TExamplePtrHelper.SetNumber(const AValue: Integer);
begin
  if not IsAssigned then raise Exception.Create('[TExamplePtr] No value assigned.');
  ValuePtr^.Number:=AValue;
end;

procedure TExamplePtrHelper.PrintValue(AIndent: Integer; const AName: string);
begin
  Writeln(Format('%s[Value] %s.Name = ''%s''; %s.Number = %d',
    [StringOfChar(' ', AIndent), AName, Name, AName, Number]));
end;

{ TDummyObj }
constructor TDummyObj.Create(const AName: string);
begin
  FName:=AName;
  Writeln(Format('    [TDummyObj] Object "%s" Created.', [FName]));
end;

destructor TDummyObj.Destroy;
begin
  Writeln(Format('    [TDummyObj] Object "%s" Destroyed.', [FName]));
  inherited;
end;

procedure TDummyObj.DoWork(AValue: string);
begin
  Writeln(Format('    [TDummyObj] "%s" is working for %s', [FName, AValue]));
end;

// =============================================================================
// DEMO 1: BASIC LIFECYCLE & SCOPING
// =============================================================================
procedure Example1_Lifecycle;

  function SubCall(const ASPtr: TExamplePtr): TExamplePtr;
  var
    lSPtrSub: TExamplePtr;
    lRawPtr: TExamplePtr.PT;

  begin
    Writeln(sLineBreak + '    >>> Entering function SubCall');
    // Note: ASPtr is 'const', so passing it here didn't increment RefCount!
    ASPtr.PrintStatus(6, 'ASPtr (const arg)');

    Writeln(sLineBreak + '      [Code] lSPtrSub:=ASPtr;');
    lSPtrSub:=ASPtr; // Assignment increments RefCount
    lSPtrSub.PrintStatus(6, 'lSPtrSub');

    Writeln(sLineBreak + '      [Code] Modifying data via implicit pointer cast...');
    lRawPtr:=lSPtrSub; // Implicit cast to raw pointer
    if Assigned(lRawPtr) then
    begin
      lRawPtr^.Number:=lRawPtr^.Number + 1;
      lRawPtr^.Name:=lRawPtr^.Name + '-SubCall';
    end;

    lSPtrSub.PrintValue(6, 'lSPtrSub');

    Writeln(sLineBreak + '      [Code] Result:=lSPtrSub;');
    Result:=lSPtrSub;
    Result.PrintStatus(6, 'Result');

    Writeln('    <<< Exiting function SubCall');
  end;

var
  lSPtr: TExamplePtr;
begin
  Writeln('--- Example #1: Smart Pointer Lifecycle & Scoping ---');
  Writeln('Objective: Demonstrate RAII and Reference Counting across scopes.');

  Writeln(sLineBreak + '  [Code] lSPtr:=TExamplePtr.Create(...)');
  lSPtr:=TExamplePtr.Create(TExampleRec.Create('Example1', 1));
  lSPtr.PrintValue(2, 'lSPtr');
  lSPtr.PrintStatus(2, 'lSPtr');

  Writeln(sLineBreak + '  Entering dedicated local scope...');
  begin
    Writeln('    [Code] var lSubCallResult:=SubCall(lSPtr);');
    var lSubCallResult:=SubCall(lSPtr);

    Writeln(sLineBreak + '    Back in local scope:');
    lSubCallResult.PrintValue(4, 'lSubCallResult');
    lSPtr.PrintStatus(4, 'lSPtr');

    Writeln(sLineBreak + '  Exiting dedicated local scope (lSubCallResult will be finalized)...');
  end;

  Writeln(sLineBreak + '  Back in main routine:');
  lSPtr.PrintStatus(2, 'lSPtr');
  Writeln('  Exiting Example1 (lSPtr will be finalized)...');
end;

// =============================================================================
// DEMO 2: EXCEPTION HANDLING
// =============================================================================
procedure Example2_Exceptions;
var
  lSPtr: TExamplePtr;

  procedure DoError(ASPtr: TExamplePtr);
  var
    lLocalSPtr: TExamplePtr;
  begin
    Writeln('    >>> Entering DoError');
    lLocalSPtr:=ASPtr;
    lLocalSPtr.PrintStatus(4, 'lLocalSPtr');

    Writeln('    [Code] Triggering Exception...');
    lLocalSPtr.Number:='Error string'.ToInteger; // Raises EConvertError

    Writeln('    <<< Exiting DoError (You will never see this!)');
  end;

begin
  Writeln(sLineBreak + '--- Example #2: Seamless Exception Handling ---');
  Writeln('Objective: Prove that Smart Pointers prevent memory leaks during exceptions.');

  lSPtr:=TExamplePtr.Create(TExampleRec.Create('Example2', 2));
  try
    DoError(lSPtr);
  except
    on E: Exception do
    begin
      Writeln(Format('  [Caught Exception] %s: "%s"', [E.ClassName, E.Message]));
      Writeln('  Notice that the Control Block RefCount safely decremented despite the crash!');
      lSPtr.PrintStatus(2, 'lSPtr');
    end;
  end;
end;

// =============================================================================
// DEMO 3: MULTITHREADING SAFETY
// =============================================================================
type
  TSmartWorker = class(TThread)
  private
    FData: TExamplePtr; // Thread takes its own reference!
  protected
    procedure Execute; override;
  public
    constructor Create(const AData: TExamplePtr);
  end;

constructor TSmartWorker.Create(const AData: TExamplePtr);
begin
  inherited Create(True);
  FData:=AData; // Thread-safe RefCount Increment
  FreeOnTerminate:=False;
end;

procedure TSmartWorker.Execute;
begin
  Sleep(Random(100)); // Simulate work
  // Modifying via Interlocked to prevent Data Races on the Number field
  TInterlocked.Increment(FData.ValuePtr^.FNumber);
  // As thread terminates, FData goes out of scope, decrementing RefCount!
end;

procedure Example3_Multithreading;
var
  lThreads: TObjectList<TSmartWorker>;
  lSPtr: TExamplePtr;
  i: Integer;

begin
  Writeln(sLineBreak + '--- Example #3: Multithreaded Smart Pointers ---');
  Writeln('Objective: Pass Smart Pointers to threads. The last thread alive frees the memory.');

  lThreads:=TObjectList<TSmartWorker>.Create;
  lSPtr:=TExamplePtr.Create(TExampleRec.Create('SharedData', 0));
  try
    Writeln('  Creating 5 threads...');
    for i:=0 to 4 do
      lThreads.Add(TSmartWorker.Create(lSPtr));

    lSPtr.PrintStatus(2, 'lSPtr (Main Thread)');

    Writeln('  [Code] lSPtr:=Default(TExamplePtr); // Main thread releases its reference');
    lSPtr:=Default(TExamplePtr);

    Writeln('  Starting threads...');
    for i:=0 to 4 do
      lThreads[i].Start;

    Writeln('  Waiting for threads to finish...');
    for var t in lThreads do t.WaitFor;

    Writeln('  All threads finished. Memory was freed by the last thread automatically!');
  finally
    lThreads.Free;
  end;
end;

// =============================================================================
// DEMO 4: ARC FOR CLASSES (TArcClass)
// =============================================================================
procedure Example4_ArcClasses;
type
  TDummyArc = TArcClass<TDummyObj>;
var
  lObj: TDummyArc;

begin
  Writeln(sLineBreak + '--- Example #4: Automatic Reference Counting (ARC) for Classes ---');
  Writeln('Objective: Prove that TArcClass automatically calls the Object Destructor.');

  Writeln(sLineBreak+
    '  [Code] lObj:=TDummyArc.Create(TDummyObj.Create(''MyService''));');
  lObj:=TDummyArc.Create(TDummyObj.Create('MyService'));

  lObj.Instance.DoWork('lObj'); // Accessing the object naturally
  Writeln(sLineBreak+
    '  [Code] lObj:=Default(TDummyArc); // Simulating variable going out of scope');
  lObj:=Default(TDummyArc);

  Writeln('  Object should be destroyed before this line prints.');
end;

// =============================================================================
// DEMO 5: FIRE AND FORGET ARC
// =============================================================================

type
  TArcWorker = class(TThread)
  private
    FData: TArcClass<TDummyObj>;
    FStartEvent: TSimpleEvent;
    FStopNotify: TCountdownEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(const AData: TArcClass<TDummyObj>;
      AStartEvent: TSimpleEvent; AStopNotify: TCountdownEvent);
  end;

constructor TArcWorker.Create(const AData: TArcClass<TDummyObj>;
  AStartEvent: TSimpleEvent; AStopNotify: TCountdownEvent);
begin
  // Thread takes ownership of the ARC reference
  inherited Create(False);
  FData := AData;
  FreeOnTerminate:=True; // Thread will clean itself up
  FStartEvent:=AStartEvent;
  FStopNotify:=AStopNotify;
end;

procedure TArcWorker.Execute;
begin
  // Wait for FStartEvent occured. If not flag set (error, lost, etc.) - exitting.
  if FStartEvent.WaitFor <> wrSignaled then
    Exit;

  Sleep(150+Random(100)); // Simulate background processing
  FData.Instance.DoWork('Background Thread');
  Writeln('    [TArcWorker] Thread finishing. FData will go out of scope now.');
  FData.Release;
  FStopNotify.Signal;
end;

procedure Example5_FireAndForget;
const
  cThreadCount = 4;

var
  i: integer;
  lStart: TSimpleEvent;
  lStop: TCountdownEvent;

begin
  Writeln(sLineBreak + '--- Example #5: Fire and Forget (ARC) ---');
  Writeln('Objective: Main thread creates an object, passes it to a thread, and forgets it.');

  lStart:=nil;
  lStop:=nil;
  try

    lStart:=TSimpleEvent.Create;
    lStop:=TCountdownEvent.Create(cThreadCount);

    Writeln(sLineBreak + '  [Code] Entering local scope to create object...');
    begin
      // Create the object and the ARC wrapper
      var lTempObj := TArcClass<TDummyObj>.Create(TDummyObj.Create('BackgroundService'));

      Writeln('  [Code] Spawning 4 threads and passing lTempObj...');
      // Pass to threads (RefCount becomes 5)
      for i:=1 to cThreadCount do
        TArcWorker.Create(lTempObj, lStart, lStop);

      Writeln('  [Code] Exiting local scope. Main thread drops its reference.');
      // lTempObj goes out of scope here (RefCount drops to 4)
    end;

    Writeln('  [Main] Main thread is now doing other things...');
    Writeln('  [Main] The object is ALIVE, owned purely by the background thread.');

    // Fire the lStart event
    Writeln('  [Main] Starting the BackgroundServices...');
    lStart.SetEvent;

    // Wait until the background threads to finish to show the console output
    Writeln('  [Main] Waiting for BackgroundServices completion ...');
    lStop.WaitFor;

    Writeln('  [Main] Example 5 finished.');
  finally
    lStart.Free;
    lStop.Free;
  end;
end;

begin
  try
    Example1_Lifecycle;
    NextSlide;

    Example2_Exceptions;
    NextSlide;

    Example3_Multithreading;
    NextSlide;

    Example4_ArcClasses;
    NextSlide;

    Example5_FireAndForget;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  PromptForCompletion;
end.
