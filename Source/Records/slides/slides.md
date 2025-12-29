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