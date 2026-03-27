unit Playground.Records.SmartPointer;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  Playground.Records.Atomic; // Reusing our Atomic Integer!

type
  /// <summary>
  ///   A generic Smart Pointer implemented as a Custom Managed Record (CMR).
  ///   Provides automatic memory management (RAII) via reference counting.
  ///   Automatically allocates and frees the memory for type T.
  /// </summary>
  TSmartPointer<T> = record
  public type
    PT = ^T;

  private type
    PControlBlock = ^TControlBlock;

    /// <summary>
    ///   The shared control block allocated on the heap.
    ///   Holds the actual data pointer and the atomic reference count.
    /// </summary>
    TControlBlock = record
    private
      FRefCount: TAtomicInt;
      FValuePtr: PT;
      function GetRefCount: Integer; inline;
      function GetValue: T; inline;
    public
      constructor Create(AValuePtr: PT);

      /// <summary>Decrements RefCount. Frees memory if 0. Returns remaining count.</summary>
      class function ReleaseBlock(var ABlock: PControlBlock): Integer; static;

      /// <summary>Increments RefCount. Returns new count.</summary>
      function UseBlock: Integer; inline;

      property RefCount: Integer read GetRefCount;
      property ValuePtr: PT read FValuePtr;
      property Value: T read GetValue;
    end;

  private
    FBlock: PControlBlock;

    procedure Release;
    function GetValue: T; inline;
    function GetRefCount: Integer; inline;
    function GetValuePtr: PT;
  public
    // -------------------------------------------------------------------------
    // Factory Methods
    // -------------------------------------------------------------------------

    /// <summary>
    ///   Creates a new Smart Pointer, allocating memory for AValue on the heap.
    ///   The memory is automatically freed when all references go out of scope.
    /// </summary>
    class function Create(AValue: T): TSmartPointer<T>; static;

    // -------------------------------------------------------------------------
    // Custom Managed Record Operators
    // -------------------------------------------------------------------------

    class operator Initialize(out Dest: TSmartPointer<T>);
    class operator Finalize(var Dest: TSmartPointer<T>);
    class operator Assign(var Dest: TSmartPointer<T>; const [ref] Src: TSmartPointer<T>);

    // -------------------------------------------------------------------------
    // Syntax Sugar Operators
    // -------------------------------------------------------------------------

    /// <summary>Implicit cast to the raw pointer type (^T).</summary>
    class operator Implicit(const AValue: TSmartPointer<T>): PT;

    /// <summary>Implicit cast to the underlying value type (T).</summary>
    class operator Implicit(const AValue: TSmartPointer<T>): T;

    /// <summary>Checks if the smart pointer contains data.</summary>
    function IsAssigned: Boolean; inline;

    procedure PrintStatus(AIdent: integer; AName: string);

    // -------------------------------------------------------------------------
    // Properties
    // -------------------------------------------------------------------------

    property ValuePTR: PT read GetValuePtr;

    /// <summary>Return copy of the underlied value .</summary>
    property Value: T read GetValue;

    /// <summary>The current number of active references.</summary>
    property RefCount: Integer read GetRefCount;
  end;

// ---------------------------------------------------------------------------
  // ARC Class Wrapper
  // ---------------------------------------------------------------------------

  /// <summary>
  ///   A generic Smart Pointer for Classes.
  ///   Provides Automatic Reference Counting (ARC) and deterministic destruction.
  /// </summary>
  TArcClass<T: class> = record
  private type
    PControlBlock = ^TControlBlock;

    /// <summary>
    ///   The shared control block allocated on the heap.
    ///   Holds the object instance and the atomic reference count.
    /// </summary>
    TControlBlock = record
    private
      FRefCount: TAtomicInt;
      FInstance: T;
      function GetRefCount: Integer; inline;
    public
      constructor Create(AInstance: T);

      /// <summary>Decrements RefCount. Calls Destroy on the instance if 0.</summary>
      class function ReleaseBlock(var ABlock: PControlBlock): Integer; static;

      /// <summary>Increments RefCount. Returns new count.</summary>
      function UseBlock: Integer; inline;

      property RefCount: Integer read GetRefCount;
      property Instance: T read FInstance;
    end;

  private
    FBlock: PControlBlock;

    procedure Release;
    function GetInstance: T; inline;
    function GetRefCount: Integer; inline;
  public
    // -------------------------------------------------------------------------
    // Factory Methods
    // -------------------------------------------------------------------------

    /// <summary>
    ///   Takes ownership of a created object instance.
    ///   The object's Destroy method is called when all references are lost.
    /// </summary>
    class function Create(AInstance: T): TArcClass<T>; static;

    // -------------------------------------------------------------------------
    // Custom Managed Record Operators
    // -------------------------------------------------------------------------

    class operator Initialize(out Dest: TArcClass<T>);
    class operator Finalize(var Dest: TArcClass<T>);
    class operator Assign(var Dest: TArcClass<T>; const [ref] Src: TArcClass<T>);

    // -------------------------------------------------------------------------
    // Syntax Sugar Operators
    // -------------------------------------------------------------------------

    /// <summary>Implicit cast to the underlying class type.</summary>
    class operator Implicit(const AValue: TArcClass<T>): T;

    /// <summary>Checks if the instance is assigned.</summary>
    function IsAssigned: Boolean; inline;

    // -------------------------------------------------------------------------
    // Properties
    // -------------------------------------------------------------------------

    /// <summary>Direct access to the underlying object instance.</summary>
    property Instance: T read GetInstance;

    /// <summary>The current number of active references.</summary>
    property RefCount: Integer read GetRefCount;
  end;

implementation

{ TSmartPointer<T>.TControlBlock }

constructor TSmartPointer<T>.TControlBlock.Create(AValuePtr: PT);
begin
  FRefCount:=1;
  FValuePtr:=AValuePtr;
end;

function TSmartPointer<T>.TControlBlock.GetValue: T;
begin
  if Assigned(FValuePtr) then
    Result:=FValuePtr^
  else
    Result:=Default(T);
end;

function TSmartPointer<T>.TControlBlock.GetRefCount: Integer;
begin
  Result:=FRefCount.Value;
end;

class function TSmartPointer<T>.TControlBlock.ReleaseBlock(var ABlock: PControlBlock): Integer;
begin
  if not Assigned(ABlock) then
    Exit(0);

  Result:=ABlock^.FRefCount.Decrement;
  Writeln(Format('>>[SmartPtr] Released reference. RefCount remaining: %d', [Result]));

  if Result <= 0 then
  begin
    Writeln(Format('>>[SmartPtr] RefCount 0. Freeing ValuePtr %p', [Pointer(ABlock^.FValuePtr)]));
    if Assigned(ABlock^.FValuePtr) then
      Dispose(ABlock^.FValuePtr);

    Dispose(ABlock);
    ABlock:=nil;
    Writeln('>>[SmartPtr] Block destroyed.');
  end;
end;

function TSmartPointer<T>.TControlBlock.UseBlock: Integer;
begin
  Result:=FRefCount.Increment;
end;

{ TSmartPointer<T> }

class function TSmartPointer<T>.Create(AValue: T): TSmartPointer<T>;
var
  lValuePtr: PT;
begin
  // 1. Allocate memory for the value and copy data
  New(LValuePtr);
  lValuePtr^:=AValue;

  // 2. Allocate and initialize the Control Block
  New(Result.FBlock);
  Result.FBlock^:=TControlBlock.Create(LValuePtr);

  Writeln(Format('  [SmartPtr] Created Block %p. RefCount: %d',
    [Pointer(Result.FBlock), Result.FBlock^.RefCount]));
end;

procedure TSmartPointer<T>.Release;
var
  lRemaining: Integer;
begin
  if not Assigned(FBlock) then
    Exit;

  // Atomically decrement the reference count, free it and assign FBlock:=nil if 0
  lRemaining:=TControlBlock.ReleaseBlock(FBlock);
end;

// --- Managed Record Operators ---

class operator TSmartPointer<T>.Initialize(out Dest: TSmartPointer<T>);
begin
  Dest.FBlock:=nil;
end;

class operator TSmartPointer<T>.Finalize(var Dest: TSmartPointer<T>);
begin
  Dest.Release;
end;

class operator TSmartPointer<T>.Assign(var Dest: TSmartPointer<T>; const [ref] Src: TSmartPointer<T>);
var
  lOldBlock, lNewBlock: PControlBlock;
begin
  // 1. Pre-increment the new block's RefCount (Optimistic)
  lNewBlock:=Src.FBlock;
  if Assigned(LNewBlock) then
    lNewBlock^.UseBlock;

  // 2. Atomically swap the FBlock pointer in Dest
  // Thread-Safe: Even if multiple threads write to Dest simultaneously,
  // InterlockedExchange guarantees no leaked blocks.
  lOldBlock:=PControlBlock(TInterlocked.Exchange(Pointer(Dest.FBlock), Pointer(LNewBlock)));

  // 3. If Dest previously held a block, release it now
  if Assigned(LOldBlock) then
    TControlBlock.ReleaseBlock(LOldBlock);
end;

// --- Syntax Sugar ---

class operator TSmartPointer<T>.Implicit(const AValue: TSmartPointer<T>): PT;
begin
  if Assigned(AValue.FBlock) then
    Result:=AValue.FBlock^.ValuePtr
  else
    Result:=nil;
end;

class operator TSmartPointer<T>.Implicit(const AValue: TSmartPointer<T>): T;
begin
  Result:=AValue.GetValue;
end;

function TSmartPointer<T>.IsAssigned: Boolean;
begin
  Result:=Assigned(FBlock) and Assigned(FBlock^.ValuePtr);
end;

procedure TSmartPointer<T>.PrintStatus(AIdent: integer; AName: string);
begin
  Writeln(sLineBreak+
    Format('%s[%s] RefCount %d. ValuePtr  %p',
      [StringOfChar(' ', AIdent), AName, FBlock^.RefCount, Pointer(FBlock^.ValuePtr)]));
end;

function TSmartPointer<T>.GetValue: T;
begin
  if not IsAssigned then
    raise Exception.Create('Dereferencing nil Smart Pointer');
  Result:=FBlock^.Value;
end;

function TSmartPointer<T>.GetValuePtr: PT;
begin
  if IsAssigned then
    Result:=FBlock.ValuePtr
  else
    Result:=nil;
end;

function TSmartPointer<T>.GetRefCount: Integer;
begin
  if Assigned(FBlock) then
    Result:=FBlock^.RefCount
  else
    Result:=0;
end;


{ TArcClass<T>.TControlBlock }

constructor TArcClass<T>.TControlBlock.Create(AInstance: T);
begin
  FRefCount:=1;
  FInstance:=AInstance;
end;

function TArcClass<T>.TControlBlock.GetRefCount: Integer;
begin
  Result:=FRefCount.Value;
end;

class function TArcClass<T>.TControlBlock.ReleaseBlock(var ABlock: PControlBlock): Integer;
begin
  if not Assigned(ABlock) then Exit(0);

  Result:=ABlock^.FRefCount.Decrement;
  Writeln(Format('>>[ARC] Released reference. RefCount remaining: %d', [Result]));

  if Result <= 0 then
  begin
    Writeln(Format('>>[ARC] RefCount 0. Destroying Object %s', [ABlock^.FInstance.ClassName]));

    // Call Destroy via Free to be safe against nil instances
    if Assigned(ABlock^.FInstance) then
      ABlock^.FInstance.Free;

    Dispose(ABlock);
    ABlock:=nil;
    Writeln('>>[ARC] Block destroyed.');
  end;
end;

function TArcClass<T>.TControlBlock.UseBlock: Integer;
begin
  Result:=FRefCount.Increment;
end;

{ TArcClass<T> }

class function TArcClass<T>.Create(AInstance: T): TArcClass<T>;
begin
  // Allocate and initialize the Control Block
  New(Result.FBlock);
  Result.FBlock^:=TControlBlock.Create(AInstance);

  Writeln(Format('>>[ARC] Created Block %p. RefCount: %d',
    [Pointer(Result.FBlock), Result.FBlock^.RefCount]));
end;

procedure TArcClass<T>.Release;
var
  lRemaining: Integer;
begin
  if not Assigned(FBlock) then Exit;

  // Atomically decrement the reference count, free it and assign FBlock:=nil if 0
  lRemaining:=TControlBlock.ReleaseBlock(FBlock);
end;

// --- Managed Record Operators ---

class operator TArcClass<T>.Initialize(out Dest: TArcClass<T>);
begin
  Dest.FBlock:=nil;
end;

class operator TArcClass<T>.Finalize(var Dest: TArcClass<T>);
begin
  Dest.Release;
end;

class operator TArcClass<T>.Assign(var Dest: TArcClass<T>; const [ref] Src: TArcClass<T>);
var
  lOldBlock, lNewBlock: PControlBlock;
begin
  // 1. Pre-increment the new block's RefCount (Optimistic)
  lNewBlock:=Src.FBlock;
  if Assigned(LNewBlock) then
    lNewBlock^.UseBlock;

  // 2. Atomically swap the FBlock pointer in Dest
  lOldBlock:=PControlBlock(TInterlocked.Exchange(Pointer(Dest.FBlock), Pointer(LNewBlock)));

  // 3. If Dest previously held a block, release it now (Thread-Safe)
  if Assigned(LOldBlock) then
    TControlBlock.ReleaseBlock(LOldBlock);
end;

// --- Syntax Sugar ---

class operator TArcClass<T>.Implicit(const AValue: TArcClass<T>): T;
begin
  Result:=AValue.GetInstance;
end;

function TArcClass<T>.IsAssigned: Boolean;
begin
  Result:=Assigned(FBlock) and Assigned(FBlock^.FInstance);
end;

function TArcClass<T>.GetInstance: T;
begin
  if not IsAssigned then
    raise Exception.Create('Dereferencing nil ARC Instance');
  Result:=FBlock^.FInstance;
end;

function TArcClass<T>.GetRefCount: Integer;
begin
  if Assigned(FBlock) then
    Result:=FBlock^.RefCount
  else
    Result:=0;
end;

end.
