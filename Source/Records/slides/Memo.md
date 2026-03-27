# Advanced Records in Delphi: Operator Overloading, Atomics, and Smart Pointers

**By Alexander Tregubov**

*Source Code available at: [Delphi-Playground](https://github.com/tregubovav-dev/Delphi-Playground)*

---

In modern Object Pascal, **Helpers** are a fantastic way to add syntax sugar to existing types (e.g., `MyInt.ToString`). However, Helpers have hard limitations: you cannot add new state (fields), and you cannot intercept standard language operators like assignment (`:=`) or equality (`=`). 

When we need total control over how a type behaves in memory, across threads, and in expressions, we must step beyond Helpers and utilize **Record Wrappers with Operator Overloading**.

In this article, we will explore how to use Advanced Records to build zero-overhead wrappers, C-compatible Safe Sets, lock-free Atomics, and C++ style Smart Pointers in Delphi.

## 1. The Zero-Overhead Wrapper

The core concept is simple: We wrap a primitive type inside a `record`. Because records in Delphi are value types allocated on the stack (with no Virtual Method Table), the size of our wrapper is exactly the size of the underlying type. For example, `SizeOf(TDoubleRec) == SizeOf(Double)`.

By overloading operators, we can make this wrapper behave exactly like a native type, but with our own rules injected directly into the compiler's output.

### The Declaration
```pascal
type
  TDoubleRec = record
  strict private
    FValue: Double;
  public
    // Seamless string assignment: Rec := '10.5';
    class operator Implicit(const AValue: string): TDoubleRec;
    
    // Direct string comparison: if Rec = '10.5' then...
    class operator Equal(const A: TDoubleRec; const B: string): Boolean; overload;
    
    property Value: Double read FValue;
  end;
```

### The Implementation
When you write `if MyRec = '10.5'`, the compiler replaces the `=` operator with a direct call to our static method. There is no runtime overhead of creating temporary objects.

```pascal
class operator TDoubleRec.Implicit(const AValue: string): TDoubleRec;
begin
  // We can inject validation, localization, or custom parsing here
  Result.FValue := AValue.ToDouble; 
end;

class operator TDoubleRec.Equal(const A: TDoubleRec; const B: string): Boolean;
var
  LFloatB: Double;
begin
  // Safe comparison logic hidden behind a simple '=' sign
  if TryStrToFloat(B, LFloatB) then
    Result := SameValue(A.FValue, LFloatB)
  else
    Result := False;
end;
```

👉 **[See Demo: Operand Overloads](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Records)**

## 2. Safe Sets: Fixing Variable Size Bitmasks

Pascal `Set` types are elegant, but their memory footprint varies (1, 2, 4, or 32 bytes) depending on the number of elements in the Enum. This makes them dangerous to use when interacting with C-APIs that expect a fixed 32-bit integer, or when laying out strictly aligned network packets.

We can solve this by building `TMySafeSet`. We wrap a fixed-size integer, but overload the `+`, `-`, and `in` operators so it *looks and feels* exactly like a Pascal Set.

### Auto-Sizing Storage
To make this reusable, we let the compiler decide the safest underlying integer type using `$IF` directives, while ensuring it never falls below 16-bits for C-API compatibility:

```pascal
type
  TMyFlag = (flOne, flTwo, flThree); 
  TMyFlags = set of TMyFlag;

  TMySafeSet = record
  public type
    // Auto-Detect minimum safe storage size
    {$IF SizeOf(TMyFlags) <= 2}
      TStorage = Word;
    {$ELSEIF SizeOf(TMyFlags) <= 4}
      TStorage = Cardinal;
    {$ELSE}
      TStorage = UInt64;
    {$IFEND}
    
  strict private
    FData: TStorage;
    // Calculate a mask to prevent garbage bits from entering the set
    const cMask = TStorage((1 shl (Ord(High(TMyFlag)) + 1)) - 1);
```

### Bridging Pascal and C
By overloading the `Implicit` operator for native sets, we can write standard Pascal code, and the record handles the bitwise math internally.

```pascal
class operator TMySafeSet.Implicit(Value: TMyFlags): TMySafeSet;
begin
  Result.FData := 0;
  // Safely move the variable-sized native set into our fixed-size storage
  Move(Value, Result.FData, SizeOf(TMyFlags));
  Result.FData := Result.FData and cMask; // Sanitize
end;

class operator TMySafeSet.Add(ALeft: TMySafeSet; ARight: TMyFlag): TMySafeSet;
begin
  // 'ALeft + flTwo' translates to this bitwise OR
  Result.FData := ALeft.FData or (1 shl Ord(ARight));
end;
```

**Usage:**
```pascal
var SafeFlags: TMySafeSet; // Guaranteed fixed size
begin
  SafeFlags :=[flOne];           // Implicit conversion
  SafeFlags := SafeFlags + flTwo; // Overloaded Add operator
  
  C_SetFlags(SafeFlags.AsInteger); // Safe 100% C-Interop
end;
```

👉 **[See Demo: Safe Sets](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Records)**

## 3. Atomic Wrappers: Encapsulating Thread Safety

Multithreading bugs often occur because a developer forgets to use `TInterlocked` or forgets to mark a shared variable as `[Volatile]`. 

By wrapping an Integer inside `TAtomicInt`, we can bake thread-safety directly into the type itself. 

```pascal
type
  TAtomicInt = record
  strict private
    [Volatile] FData: Integer; // Forces memory visibility
  public
    function Increment: Integer;
    function CompareExchange(NewVal, Expected: Integer; out Success: Boolean): Integer;
    
    // Forces Atomic Exchange on assignment
    class operator Assign(var Dest: TAtomicInt; const [ref] Src: TAtomicInt);
  end;
```

### The Power of Atomic Assignment
Because we implemented this as a Wrapper instead of a Helper, we control the assignment operator (`:=`). When a developer writes `MyAtom := OtherAtom`, we ensure a full Hardware Memory Barrier (`LOCK XCHG`) is executed.

```pascal
class operator TAtomicInt.Assign(var Dest: TAtomicInt; const [ref] Src: TAtomicInt);
begin
  // Atomically swap Dest's memory with Src's current value.
  // This guarantees the update is instantly visible to all CPU cores.
  TInterlocked.Exchange(Dest.FData, Src.GetValue);
end;
```

In our repository stress tests—pitting 8 writers against 16 readers without locking primitives—a plain integer completely failed due to Read-Modify-Write races, missing its target by 350 million counts. The `TAtomicInt` wrapper processed over 85 million collisions and hit zero perfectly.

👉 **[See Demo: Atomic Wrappers](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Records)**

## 4. Smart Pointers & ARC (Custom Managed Records)

Introduced in Delphi 10.4, **Custom Managed Records (CMR)** allow records to manage their own lifecycle using `Initialize`, `Finalize`, and `Assign` operators.

We can use this to build `TSmartPointer<T>` and `TArcClass<T>`, bringing Automatic Reference Counting (ARC) and true RAII (Resource Acquisition Is Initialization) to standard Delphi types without the overhead of COM Interfaces.

### The Control Block
To share state between multiple copies of a record, we allocate a small control block on the heap containing the instance and a thread-safe `TAtomicInt` reference counter:

```pascal
  PControlBlock = ^TControlBlock;
  TControlBlock = record
    FRefCount: TAtomicInt;
    FInstance: T;
  end;
```

### The Magic of CMR
The record itself contains only a pointer to this control block. The compiler automatically calls our operators when the record is copied or goes out of scope.

```pascal
class operator TArcClass<T>.Finalize(var Dest: TArcClass<T>);
begin
  // If we are the last owner, destroy the underlying object
  if Assigned(Dest.FBlock) then
    if TControlBlock.ReleaseBlock(Dest.FBlock) <= 0 then
      Dest.FBlock^.FInstance.Free; 
end;

class operator TArcClass<T>.Assign(var Dest: TArcClass<T>; const [ref] Src: TArcClass<T>);
var
  LOldBlock, LNewBlock: PControlBlock;
begin
  // 1. Optimistically increment the new block's RefCount
  LNewBlock := Src.FBlock;
  if Assigned(LNewBlock) then LNewBlock^.UseBlock;

  // 2. Atomically swap the pointer in Dest (100% Thread-Safe Assignment!)
  LOldBlock := PControlBlock(TInterlocked.Exchange(Pointer(Dest.FBlock), Pointer(LNewBlock)));

  // 3. Release the block Dest used to hold
  if Assigned(LOldBlock) then TControlBlock.ReleaseBlock(LOldBlock);
end;
```

### The "Fire and Forget" Pattern
This allows us to create an object, pass it to multiple background threads, and forget about it. The last thread to finish will automatically call `Destroy`.

```pascal
var
  Obj: TArcClass<TService>;
begin
  // Takes ownership of the object (RefCount = 1)
  Obj := TArcClass<TService>.Create(TService.Create);

  // Pass 'Obj' to background threads (RefCount increments automatically)
  for i := 1 to 4 do TWorker.Create(Obj);

  // Main thread drops its reference when Obj goes out of scope here.
  // Memory leaks are impossible.
end;
```

### Why use Managed Records instead of Interfaces?
1.  **No VMT Overhead:** Records do not require a Virtual Method Table.
2.  **No Refactoring Required:** You don't need your classes to inherit from `TInterfacedObject` or implement `_AddRef`. You can wrap *any* existing class.
3.  **Deterministic Cleanup:** The compiler guarantees `Finalize` is called exactly when the record leaves the local scope, making it highly predictable even during exceptions.

👉 **[See Demo: Smart Pointers](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Records)**

## Conclusion

While Helpers are great for adding syntax sugar, **Advanced Records** give you total control over memory layout, language operators, and lifecycle management. They allow you to encapsulate thread-safety and automate memory management while maintaining the absolute zero-overhead performance that Delphi is known for.

All the code examples, including the multithreaded stress tests and Smart Pointer implementations, are available in the **[Delphi-Playground Repository](https://github.com/tregubovav-dev/Delphi-Playground)**.

Happy Coding!