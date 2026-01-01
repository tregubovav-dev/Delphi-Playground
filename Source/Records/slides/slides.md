---
marp: true
theme: default
paginate: true
backgroundColor: #ffffff
style: |
  /* 1. Standard Slides (Left Aligned, Sidebar) */
  section {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    border-left: 30px solid #2b5797; /* Delphi Blue Sidebar */
    padding-left: 40px;
    text-align: left; /* Force left align */
  }

  /* 2. Title/Divider Slides (Centered, No Sidebar) */
  section.lead {
    border-left: none;
    padding-left: 50px; /* Center balance */
    text-align: center;
    background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
    display: flex;
    flex-direction: column;
    justify-content: center;
  }

  /* 3. Pagination Color */
  section::after {
    font-weight: bold;
    color: #2b5797;
  }

  /* 4. Code & Typography */
  code { font-family: 'Consolas', 'Courier New', monospace; background: #f0f0f0; padding: 2px 5px; border-radius: 4px; }
  h1 { color: #2b5797; }
  h2 { color: #20406b; }
  strong { color: #b91d47; }

    /* 1. The Container (Blue Screen) */
    pre {
        background-color: #000080 !important; /* Turbo Blue */
        border: 4px double #C0C0C0; /* DOS-style Border */
        padding: 15px;
    }

    /* 2. Base Text (Yellow - like normal identifiers in TP) */
    pre code {
        color: #FFFF00 !important; /* Yellow */
        background-color: transparent !important;
    }

    /* 3. Keywords (White - 'begin', 'end', 'var') */
    .hljs-keyword, 
    .hljs-built_in, 
    .hljs-type {
        color: #FFFFFF !important; /* White */
        font-weight: bold;
    }

    /* 4. Strings (Cyan or Light Green - readable on Blue) */
    /* TP used #00FFFF (Cyan) or #FFFFFF for strings often. Let's try Cyan for contrast. */
    .hljs-string {
        color: #00FFFF !important; /* Cyan */
    }

    /* 5. Numbers (Light Green or Bright White) */
    .hljs-number {
        color: #00FF00 !important; /* Bright Green */
    }

    /* 6. Comments (Gray or Dimmed) */
    .hljs-comment {
        color: #C0C0C0 !important; /* Light Gray */
        font-style: italic;
    }  
---

<!-- _class: lead -->

# Advanced Records
## Operator Overloading and Zero-Cost Wrappers

**Source:** `Source/Records`

---

<!-- _class: default -->

# Beyond Helpers

In previous demos, we used **Helpers** to add methods to existing types.
*   ✅ Great for syntax sugar (`Int.ToString`).
*   ❌ Cannot add fields.
*   ❌ Cannot intercept operators (`:=`, `=`, `+`).

**The Next Step: Wrappers**
Sometimes we need total control. We want to intercept assignment, type casting, and comparison.
For this, we need **Record Wrappers with Operator Overloading**.

---

# The Concept: Zero-Overhead Wrapper

We wrap a primitive type (like `Double`) inside a Record.

~~~pascal
type
  TDoubleRec = record
  private
    FValue: Double;
  public
    // ... Operators ...
  end;
~~~

**The Promise:**
*   **Size:** `SizeOf(TDoubleRec) == SizeOf(Double)`. (8 bytes).
*   **Performance:** No VMT, no heap allocation. Just raw stack memory.
*   **Power:** We can make `TDoubleRec` behave like a String, or an Object, or a Validator.

---

# Demo 1: The Basics (`Overloads_01`)

We will implement `TDoubleRec` to demonstrate the core operators.

**1. Implicit Conversion**
Seamlessly assign `String` to `Record`.
~~~pascal
Rec := '10.5'; // Calls Implicit(String): TDoubleRec
Str := Rec;    // Calls Implicit(TDoubleRec): String
~~~

**2. Equality**
Compare `Record` directly with `String`.
~~~pascal
if Rec = '10.5' then ...
~~~

---

# How it works

The compiler injects calls to our static class operators.

**Source:**
~~~pascal
if Rec = '10.5' then ...
~~~

**Compiled Logic:**
~~~pascal
if TDoubleRec.Equal(Rec, '10.5') then ...
~~~

> **Note:** This allows us to inject custom logic (logging, validation, rounding) into basic language syntax.

---

<!-- _class: lead -->

# Demo Time
## `Overloads_01_Basics`

Checking Size, Implicit Casts, and Equality.

---

<!-- _class: lead -->

# Safe Sets
## Fixed-Size Bitmasks with Set Syntax

**Source:** `Source/Records` (SafeSet Demo)

---

# The Problem: Variable Size Sets

Pascal Sets are great, but their size varies (1, 2, 4, 32 bytes) depending on the Enum range.
*   ❌ Hard to use in Fixed-Size structures (Records/Packets).
*   ❌ Dangerous for C-Interop (expecting `int`).
*   ❌ Risky for Atomic operations (need 4 bytes).

**The Goal:**
A type that *behaves* like a Pascal Set (`in`, `Include`, `+`) but is guaranteed to be **4 bytes** (or fixed size).

---

# The Solution: Record Wrapper

We wrap the storage (`Cardinal`) in a Record and overload operators.

~~~pascal
type
  TMySafeSet = record
  private
    FData: Cardinal; // Fixed 4 bytes
  public
    // Syntax Sugar
    class operator Add(Left: TMySafeSet; Right: TMyFlag): TMySafeSet;
    class operator In(Item: TMyFlag; Set: TMySafeSet): Boolean;
    class operator Implicit(Native: TMyFlags): TMySafeSet;
  end;
~~~

---

# Implementation: Auto-Sizing Storage

To make it robust, we can auto-detect the required storage size at compile time.

~~~pascal
type
  TMySafeSet = record
  public type
    {$IF SizeOf(TMyFlags) <= 1} TStorage = Byte;
    {$ELSEIF SizeOf(TMyFlags) <= 2} TStorage = Word;
    {$ELSE} TStorage = Cardinal; {$IFEND}
  private
    FData: TStorage;
~~~

> This ensures `TMySafeSet` is always the smallest fixed integer that fits the Enum, aligned to standard boundaries (1, 2, 4).

---

# Usage: Natural Syntax & Interop

The result feels like Pascal but acts like C.

~~~pascal
var
  Safe: TMySafeSet; // Guaranteed 4 bytes (if Enum fits)
begin
  // 1. Pascal Syntax
  Safe := [flOne, flTwo]; 
  if flTwo in Safe then ...

  // 2. C-Interop (Zero Cost)
  // Safe to pass to C-API expecting 'int flags'
  C_SetFlags(Safe.AsInteger); 
end;
~~~

---

# Why not just use Helpers?

In the previous section, we used **Helpers** to patch native sets for C-Interop.
*   **Helper:** Adds `ToInteger` method to `set of TEnum`.
*   **Wrapper:** *IS* an Integer (in memory).

**The Wrapper Advantage:**
*   **Safety:** You cannot accidentally pass a 1-byte Set to a 4-byte C-API function. `TMySafeSet` enforces the size.
*   **Structs:** You can use `TMySafeSet` inside a `packed record` or C-compatible struct safely.

> **Use Helpers** for existing types. **Use Wrappers** when defining new API structures.

---

<!-- _class: lead -->

# Demo Time
## `Records_02_SafeSet`

Creating, Modifying, and Interoperating with Native Sets.

---

<!-- _class: lead -->

# Atomic Wrappers
## Encapsulating Thread Safety

**Source:** `Source/Records` (AtomicInt Demo)

---

# Why not just use Helpers?

We previously used Helpers for Atomic Sets. Why build a Record Wrapper (`TAtomicInt`) for Integers?

**1. Implicit Casting**
Helpers cannot overload operators. Wrappers can.
*   `TAtomicInt` behaves like an Integer in expressions.

**2. Atomic Assignment**
Helpers cannot override `:=`.
*   **Helper:** `Val.AsAtomic := 10;` (Property trick).
*   **Wrapper:** `Val := 10;` (Natural syntax triggers `AtomicExchange`).

---

# The "Volatile" Advantage

Multithreading bugs often happen because the compiler optimizes reads (caching a variable in a CPU register).

**The Raw Integer Risk:**
~~~pascal
var Flag: Integer; // Compiler might optimize this!
...
while Flag = 0 do; // Infinite loop if cached
~~~

**The Wrapper Solution:**
~~~pascal
type
  TAtomicInt = record
  strict private
    [Volatile] FData: Integer; // Compiler forced to read memory
  end;
~~~
> **Benefit:** The safety is baked into the type. You cannot "forget" to mark the variable as volatile.

---

# The API Difference

**Standard TInterlocked:**
~~~pascal
// Verbose, repeats variable name, hard to read
TInterlocked.CompareExchange(MyVar, NewVal, OldVal);
TInterlocked.Increment(MyVar);
~~~

**TAtomicInt Wrapper:**
~~~pascal
// Object-Oriented, Clean, Discoverable
MyAtom.CompareExchange(NewVal, OldVal);
MyAtom.Increment;
~~~

---

# Atomic Assignment Details

We overload `Assign` to ensure thread safety during copies.

~~~pascal
class operator Assign(var Dest: TAtomicInt; const [ref] Src: TAtomicInt);
begin
  
  // Ensures 'Dest' update is immediately visible to all threads
  Dest.Exchange(Src.GetValue); // It wraps TInterlocked.Exchange (Full Memory Barrier)
end;
~~~

*   **Standard `:=`**: Simple memory copy (might be reordered by CPU).
*   **Atomic `:=`**: Guaranteed `LOCK` prefix (Hardware Fence).


---

# Enhancing TAtomicInt

We can make the wrapper behave even more like a native type by overloading comparison operators.

~~~pascal
// Allow direct comparison in "if" statements
class operator LessThan(const A: TAtomicInt; const B: Integer): Boolean;
class operator GreaterThan(const A: TAtomicInt; const B: Integer): Boolean;
~~~

**Usage:**
~~~pascal
if MyAtomic > 0 then ... 
// effectively: if MyAtomic.Value > 0 then ...
~~~

---

# The Ultimate Test: Multithreading

We built a stress test (`Records_04_Multithreading`) to simulate high contention.

*   **Setup:** 8 Writers fighting to decrement a counter from `33,554,430` to `0`.
*   **The Switch:** `{$DEFINE USE_PLAIN_INTEGER}` vs `TAtomicInt`.

---

# Result 1: The "Plain Integer" Disaster

Without atomics, threads overwrite each other's work (Read-Modify-Write race). The counter overshoots zero and spirals out of control.

~~~text
  [Status] Timeout. Terminating threads...
  
  [Writer 0] ... reached ZERO in 1,276 ms
  [Writer 1] ... can not reach ZERO in 11,007 ms
  
  [Final Counter State] -357,719,688 (Expected = 0)
~~~

> **Verdict:** Catastrophic Logic Failure. The counter missed 0 by **350 million**.

---

# Result 2: The "Atomic" Success

With `TAtomicInt`, the **CAS Loop** handles the contention. Threads spin until they successfully decrement.

~~~text
  [Result] Success. All threads finished.
  
  [Writer 0] ... reached ZERO in 4,427 ms
  [Writer 7] ... reached ZERO in 4,460 ms
  
  [Total Writers' Iterations] 85,731,220
  [Final Counter State]       0 (Expected = 0)
~~~

> **Verdict:** Perfect Data Integrity.
> Note: **85M attempts** were required to perform **33M decrements**. The wrapper handled ~52 million collisions transparently!
---

<!-- _class: lead -->

# Demo Time
## `Records_03_AtomicInt`

Atomic Arithmetic, CAS, and Assignment.