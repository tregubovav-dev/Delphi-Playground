(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

unit Playground.Records.Atomic.Threads;

interface

uses
  System.Classes,
  System.SyncObjs,
  System.SysUtils,
  System.Diagnostics,
  System.Generics.Collections,
  Playground.Records.Atomic;

// {$DEFINE USE_PLAIN_INTEGER}

type
  /// <summary>
  ///   Manages shared state and synchronization for the threading demo.
  /// </summary>
  TThreadControl = class
  strict private
    {$IFDEF USE_PLAIN_INTEGER}
    FCounter: integer;
    {$ELSE}
    FCounter: TAtomicInt;
    {$ENDIF}
    FStartEvent: TEvent;
    FStopEvent: TCountdownEvent;
  public
    constructor Create(AValue: integer; AStartEvent: TEvent;
       AStopEvent: TCountdownEvent);
    destructor Destroy; override;

    /// <summary>Signals threads to begin execution.</summary>
    procedure SetStartEvent; {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Signals that a thread has finished its work.</summary>
    procedure SetStopped; {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Waits for the Start signal.</summary>
    function WaitForStart: boolean; {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Waits for all threads to signal Stop (or timeout).</summary>
    function WaitForStop(ATimeout: cardinal): boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>
    ///   Access to the shared atomic integer.
    ///   Since this is a field-backed property, methods called on it
    ///   operate directly on the FInt memory address.
    /// </summary>
    {$IFDEF USE_PLAIN_INTEGER}
    property Counter: integer read FCounter write FCounter;
    {$ELSE}
    property Counter: TAtomicInt read FCounter;
    {$ENDIF}
  end;

  /// <summary>Base class for demo threads.</summary>
  TBaseThread = class abstract(TThread)
  private
    FControl: TThreadControl;
    FStatus: string;
  protected
    procedure SetStatus(const AStatus: string);
    property Control: TThreadControl read FControl;
  public
    constructor Create(AControl: TThreadControl);
    property Status: string read FStatus;
  end;

  /// <summary>
  ///   Writer Thread: Changes the counter value until it reaches zero.
  /// </summary>
  TWriterThread = class(TBaseThread)
  protected
    procedure Execute; override;
  end;

  /// <summary>
  ///   Reader Thread: Monitors the counter value until it reaches zero.
  /// </summary>
  TReaderThread = class(TBaseThread)
  protected
    procedure Execute; override;
  end;

  TRunner = class
  private type
    TWorkerList = TObjectList<TBaseThread>;

  private
    FControl: TThreadControl;
    FWrites: TWorkerList;
    FReaders: TWorkerList;

  public
    constructor Create(AValue: integer; AWriterCount, AReaderCount: cardinal);
    destructor Destroy; override;

    procedure Run(AWaitCount, AWaitTimeout: cardinal);
  end;

implementation

{ TThreadControl }

constructor TThreadControl.Create(AValue: integer; AStartEvent: TEvent;
  AStopEvent: TCountdownEvent);
begin
  Assert(Assigned(AStartEvent), 'Start Event is nil.');
  Assert(Assigned(AStopEvent), 'Stop Event is nil.');
  inherited Create;
  // Initialize the atomic record (Implicit operator uses FData assignment)
  FCounter:=AValue;
  FStartEvent:=AStartEvent;
  FStopEvent:=AStopEvent;
end;

destructor TThreadControl.Destroy;
begin
  FreeAndNil(FStartEvent);
  FreeAndNil(FStopEvent); // Fixed: Was releasing StartEvent twice
  inherited;
end;

procedure TThreadControl.SetStartEvent;
begin
  FStartEvent.SetEvent;
end;

procedure TThreadControl.SetStopped;
begin
  FStopEvent.Signal;
end;

function TThreadControl.WaitForStart: boolean;
begin
  Result:=FStartEvent.WaitFor(INFINITE) = wrSignaled;
end;

function TThreadControl.WaitForStop(ATimeout: cardinal): boolean;
begin
  // Fixed: Wait on FStopEvent, return True if Signaled (Success)
  Result:=FStopEvent.WaitFor(ATimeout) = wrSignaled;
end;

{ TBaseThread }

constructor TBaseThread.Create(AControl: TThreadControl);
begin
  Assert(Assigned(AControl), 'Thread Control object is nil.');
  inherited Create(True); // Create Suspended
  FControl:=AControl;
  FreeOnTerminate:=False; // Managed by caller/list
end;

procedure TBaseThread.SetStatus(const AStatus: string);
begin
  FStatus:=AStatus;
end;

{ TWriterThread }

procedure TWriterThread.Execute;
var
  lStopWatch: TStopWatch;
  lIterations: Int64;
  lIncrement: integer;
  lValue: integer;
  lStatusStr: string;

begin
  try
    lIterations:=0;
    try
      SetStatus('Waiting for Start event.');
      if Control.WaitForStart then
      begin
        // Logic Fix: Determine direction towards zero
        if Control.Counter > 0 then
          lIncrement:=-1
        else
          lIncrement:=1;

        SetStatus('Countdown begins.');

        lStopWatch:=TStopwatch.StartNew;
        lIterations:=0;
        // Loop until we hit 0 exactly
        // AtomicInt.Value performs atomic read
        while True do
        begin
          if Terminated then Break;
          Inc(lIterations);
          {$IFDEF USE_PLAIN_INTEGER}
          if Control.Counter <> 0 then
            Control.Counter:=Control.Counter+lIncrement;
          if Control.Counter = 0 then
            Break;
          {$ELSE}
          // Atomic Add on the shared memory field
          lValue:=Control.Counter;
          if lValue = 0 then
            Break;
          if Control.Counter.CompareExchange(lValue+lIncrement, lValue)
            and (lValue = 1) then
            Break;
          {$ENDIF}
        end;
        lStopWatch.Stop;

        if Terminated then
         lStatusStr:='Control counter can not reach ZERO in %4.0n iterations (in %4.0n ms) '+
           'before Termination called.'
        else
         lStatusStr:='Control counter has reached ZERO in %4.0n iterations (in %4.0n ms)';
        SetStatus(Format(lStatusStr,
          [(lIterations+0.0), (lStopWatch.ElapsedMilliseconds+0.0)]));
      end;
    finally
      // Ensure we signal stop exactly once
      Control.SetStopped;
      ReturnValue:=lIterations;
    end;
  except
    on E: Exception do
      SetStatus(Format('Exception %s with message "%s" occurred.',
        [E.ClassName, E.Message]));
  end;
end;

{ TReaderThread }

procedure TReaderThread.Execute;
var
  lStopWatch: TStopWatch;
  lIterations: Int64;
  lStatusStr: string;

begin
  try
    lIterations:=0;
    try
      SetStatus('Waiting for Start event.');
      if Control.WaitForStart then
      begin
        SetStatus('Checking countdown for zero.');

        lStopWatch:=TStopwatch.StartNew;
        lIterations:=0;
        // Atomic Read Loop
        // Intentionally tight loop (no Sleep/SpinWait) to demonstrate
        // atomic visibility across threads under stress.
        while Control.Counter <> 0 do
        begin
          if Terminated then Break;
          Inc(lIterations);
        end;
        lStopWatch.Stop;

        if Terminated then
         lStatusStr:='Countdown did not reach ZERO in %4.0n iterations (in %4.0n ms) '+
           'before Termination called.'
        else
         lStatusStr:='Countdown has reached ZERO in %4.0n iterations (in %4.0n ms)';
        SetStatus(Format(lStatusStr,
          [(lIterations+0.0), (lStopWatch.ElapsedMilliseconds+0.0)]));
      end;
    finally
      Control.SetStopped;
      ReturnValue:=lIterations;
    end;
  except
    on E: Exception do
      SetStatus(Format('Exception %s with message "%s" occurred.',
        [E.ClassName, E.Message]));
  end;
end;

{ TRunner }

constructor TRunner.Create(AValue: integer; AWriterCount, AReaderCount: cardinal);
var
  i: integer;

begin
  FControl:=TThreadControl.Create(AValue, TSimpleEvent.Create,
  TCountdownEvent.Create(AReaderCount+AWriterCount));

  FWrites:=TWorkerList.Create;
  FWrites.Capacity:=AWriterCount;
  for i:=0 to AWriterCount-1 do
    FWrites.Add(TWriterThread.Create(FControl));

  FReaders:=TWorkerList.Create;
  FReaders.Capacity:=AReaderCount;
  for i:=0 to AReaderCount-1 do
    FReaders.Add(TReaderThread.Create(FControl));
end;

destructor TRunner.Destroy;
begin
  FreeAndNil(FReaders);
  FreeAndNil(FWrites);
  FreeAndNil(FControl);
  inherited;
end;

procedure TRunner.Run(AWaitCount, AWaitTimeout: cardinal);
var
  lAllTerminated: boolean;

  procedure EmergencyTerminate;
  var
    lThread: TBaseThread;
    i: integer;

  begin
    if not lAllTerminated then
    begin
      Writeln('  [Status] Timeout. Terminating threads...');
      for lThread in FWrites do
        lThread.Terminate;
      for lThread in FReaders do
        lThread.Terminate;

      // Wait again for them to react to Terminate
      for i:=0 to AWaitCount-1 do
      begin
        lAllTerminated:=FControl.WaitForStop(AWaitTimeout);
        if lAllTerminated then Break;
      end;
    end;

  end;

var
  lThread: TBaseThread;
  i: integer;
  lTotal: Int64;

begin
  lAllTerminated:=False;
  try
    // Start
    for lThread in FWrites do
      lThread.Start;
    for lThread in FReaders do
      lThread.Start;

    Sleep(100); //give a room to start threads.

    // Go
    FControl.SetStartEvent;

    for i:=0 to AWaitCount-1 do
    begin
      Write('.'); // Heartbeat
      lAllTerminated:=FControl.WaitForStop(AWaitTimeout);
      if lAllTerminated then Break;
    end;
    Writeln;

    // Emergency Cleanup if stuck
    EmergencyTerminate;
    if lAllTerminated then
      Writeln('  [Result] Success. All threads finished.')
    else
      Writeln('  [Result] Failed. Threads failed to stop.');

    // Print final status of a few threads to verify logic
    if FWrites.Count > 0 then
    begin
      lTotal:=0;
      for i:=0 to FWrites.Count-1 do
      begin
        Writeln(Format('  [Writer %4d Status]  %s ',
          [i, FWrites[i].Status])
        );
        Inc(lTotal, FWrites[i].ReturnValue);
      end;
      Writeln(Format('  [Total Writers'' iterations]  %4.0n', [(lTotal+0.0)]));
    end;

    if FReaders.Count > 0 then
    begin
      lTotal:=0;
      for i:=0 to FReaders.Count-1 do
      begin
        Writeln(Format('  [Reader %4d Status]  %s ',
          [i, FReaders[i].Status])
        );
        Inc(lTotal, FReaders[i].ReturnValue);
      end;
      Writeln(Format('  [Total Readers'' iterations]  %4.0n', [(lTotal+0.0)]));
    end;

    lTotal:=FControl.Counter;
    Writeln(Format('  [Final Counter State] %4.0n (Expected = 0)',
      [(lTotal+0.0)]));
  finally
    if not lAllTerminated then
      EmergencyTerminate;
  end;

end;

end.
