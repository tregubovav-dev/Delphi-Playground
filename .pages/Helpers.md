---
layout: post
title: Delphi Playground
date: 2026-04-04
---
# Modernizing Object Pascal: Readability, Safety, and Sustainability with Helpers

**By Alexander Tregubov**

*Source Code available at:[Delphi-Playground](https://github.com/tregubovav-dev/Delphi-Playground)*

---

Developers have long embraced Object-Oriented Programming (OOP) and class-based designs. However, we often treat primitive types—like Integers, Booleans, and Strings—as "givens," relying on legacy global procedures and functions to manipulate them. 

This results in codebases that speak **two parallel languages**: a clean, fluent object syntax for classes, and a disjointed procedural style for simple types.

In this article, I will present a modern alternative using **Helpers**. We will explore how to unify these styles to improve code readability and maintainability, while significantly reducing the risk of logical errors and unsafe API usage.

## The Utility Unit Problem

Object Pascal (Delphi/FreePascal) is a language famous for its readability. However, as projects grow, legacy code often accumulates into what I call "The Utility Unit Problem."

We have all seen code like this:

```pascal
// The "Matryoshka" (Russian Doll) Effect
Result := QuotedStr(UpperCase(Trim(IntToStr(Value))));
```

To understand this, you have to read it backwards—from the inside out. The data itself is passive; it merely gets passed around to global routines scattered across units (`SysUtils`, `StrUtils`, `MyUtils`, etc.) that you are forced to memorize.

Let's look at how **Class and Record Helpers** can modernize your Pascal code, transforming it into a more fluent, type-safe, and sustainable structure.

## 1. Readability: Shifting from Passive to Active

The first step to modernization is changing the way we communicate in our code. Instead of thinking, *"I need a function to trim this string,"* we should think: *"String, trim yourself."*

By using Helpers on simple types (provided out-of-the-box in modern `System.SysUtils`), we can convert nested function calls into a clear, linear pipeline:

```pascal
// Classic Approach (Nested)
Result := QuotedStr(UpperCase(Trim(AStr)));

// Helper Approach (Fluent)
Result := AStr.Trim.ToUpper.QuotedString;
```

This version reads like a sentence. It lowers cognitive load because the operations follow the natural flow of data (Left-to-Right). 

**The Discoverability Bonus:** 
Beyond readability, Helpers fix IDE discoverability. Instead of guessing which unit contains the string manipulation function you need, you simply type `AStr.` and Code Insight (IntelliSense) immediately lists every available operation for that type.

👉 **[See Demo: Introduction to Simple Types](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Helpers/01%20-%20Introduction)**

## 2. Sustainability: The Inheritance Trap

A common challenge in Delphi development is extending standard classes like `TStrings`. The traditional object-oriented approach relies on Inheritance:

```pascal
type 
  TMyStringList = class(TStringList) 
    procedure Append(Source: TStrings);
  end;
```

However, this leads to an architectural trap. You cannot use `TMyStringList` with standard VCL/FMX components. For example, a `TMemo.Lines` property is already instantiated as the base `TStrings` type. Your derived class is completely ineffective there.

**The Solution: Helper Polymorphism**

By defining a **Class Helper** for the abstract base class `TStrings`, we effectively enhance every string list in the entire application instantly.

```pascal
type
  TStringsHelper = class helper for TStrings
    procedure Append(Source: TStrings);
  end;
```

Because the helper attaches to the base class, this newly defined method is now available on `TStringList`, `TMemo.Lines`, and `TComboBox.Items`. 

```pascal
// This now works natively, without subclassing the UI control!
Memo1.Lines.Append(OtherList); 
```

We write the functionality once, and it becomes accessible everywhere without breaking the visual designer.

👉 **[See Demo: Class Helpers](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Helpers/01%20-%20Introduction)**

## 3. Architecture: The Power of Distinct Types

While Class Helpers are widely recognized, **Record Helpers** on simple types (like `Integer`) are often avoided due to conflicts with standard RTL helpers (like `TIntegerHelper`).

The solution is the **Distinct Type**. Pascal allows us to declare a new type that shares the exact same memory structure but has a unique identity:

```pascal
type
  TMyInt = type Integer;
  
  TMyIntHelper = record helper for TMyInt
    function EnsureBetween(const AMin, AMax: Integer): Integer;
    function IsEven: Boolean;
  end;
```

By doing this, we can attach a specific helper to `TMyInt` without interfering with the global `TIntegerHelper`.

**The Magic of Compatibility**

The greatest advantage of this pattern is that Pascal treats these distinct types as **Assignment Compatible**. You can assign a standard `Integer` to `TMyInt` without an explicit cast:

```pascal
var
  Std: Integer;
  Mine: TMyInt;
begin
  Std := 10;
  Mine := Std; // Implicit assignment works!
  
  // Now we use our custom domain logic
  if Mine.IsEven then
    Mine := Mine.EnsureBetween(0, 50);
end;
```

This allows us to easily introduce strict domain logic (Validation, Formatting, State Checking) into legacy codebases with zero disruptions to the underlying data flow.

👉 **[See Demos: Simple Types and Logic](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Helpers/02%20-%20Simple%20types)**

## 4. Advanced C-Interop: Taming Enums and Bitmasks

Interfacing with C/C++ APIs is a daily reality, but C enums and bitmasks can be quite challenging compared to Pascal's strict, safe typing.

### Scenario A: Sparse Enums

**The Problem:**
C enums often contain non-contiguous values (gaps or negative numbers):

```c
typedef enum {
  STATUS_ERROR = -1,
  STATUS_OFF   = 0,
  STATUS_RESET = 1024
} t_status;
```

While Pascal allows explicitly assigned enums (`type TStatus = (sError = -1, sReset = 1024)`), using them in this scenario leads to architectural pitfalls:
1.  **Broken Sets:** You cannot declare `set of TStatus` if the range exceeds 255 values. A value of `1024` makes sets impossible.
2.  **Fragile Iteration:** Iterating over non-contiguous enums with `for..in` loops is complex and prone to errors.
3.  **Leaky Abstraction:** Developers are forced to constantly think about the "magic numbers" rather than focusing on the logical state.

**The Solution:** Separate the **Logic** from the **Value**.
1.  Define a clean, standard Pascal Enum: `TLegacyStatus = (lsError, lsOff, lsReset);`
2.  Use a Helper to map it to the raw C values using a hidden lookup table.

```pascal
  TLegacyStatusHelper = record helper for TLegacyStatus
  private const
    cValues: array[TLegacyStatus] of Integer = (-1, 0, 1024);
  public
    function ToInteger: Integer; // Returns cValues[Self]
    class function FromInteger(Value: Integer): TLegacyStatus;
  end;
```

This approach keeps our business logic **Pure Pascal**. We can use `for..in` loops, Sets, and RTTI, while the Helper handles the ugly translation to `-1` or `1024` entirely behind the scenes.

👉 **[See Demo: Enums and Sparse Mapping](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Helpers/03%20-%20Enums%20and%20Sets)**

### Scenario B: Safe Bitmasks

C APIs love bitmasks (`int flags`). Pascal developers love `Sets`.

However, directly casting a Set to an Integer is not valid syntax in modern Delphi, and using indirect pointer casting (`PInteger(@MySet)^`) can be highly dangerous since Pascal Sets vary in size (1, 2, 4 bytes, etc.). Attempting to read 4 bytes from a 1-byte set reads stack garbage.

We can solve this with a **Bitmask Helper** that uses compile-time size detection to guarantee memory safety:

```pascal
class function TFlagsHelper.ToInteger(Value: TMyFlags): Integer;
begin
  // Compile-time check for safe memory reads
  {$IF SizeOf(TMyFlags) = 1}
    Result := PByte(@Value)^;
  {$ELSEIF SizeOf(TMyFlags) = 2}
    Result := PWord(@Value)^;
  {$ELSEIF SizeOf(TMyFlags) = 4}
    Result := PCardinal(@Value)^;
  {$ENDIF}
  
  // Sanitize high bits
  Result := Result and cMask;
end;
```

This allows us to interact with C APIs using clean, fluent Pascal syntax, replacing messy bitwise `OR`/`AND` operations with native `Include` and `Exclude` logic:

```pascal
// Clean construction
Flags :=[flsRead, flsAsync];

// Safe API call
C_SetFlags(Flags.ToInteger);
```

👉 **[See Demo: Bitmasks and Sets](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Helpers/03%20-%20Enums%20and%20Sets)**

## 5. API Wrappers: Opaque Handles

Finally, consider Opaque Handles like Windows `HKEY` or `HWND`. In raw API calls, these handles are represented as integers (or pointers). This makes it incredibly easy to accidentally pass a File Handle to a Registry function, or simply forget to close them properly.

To address this issue, we can use the **Distinct Type** strategy again:

```pascal
type
  TRegHandle = type HKEY; // Distinct from Cardinal/Integer
```

By attaching a helper, we can transform the procedural WinAPI into an Object-Oriented interface with **zero runtime overhead** (by marking the helper methods as `inline`):

```pascal
var
  Key: TRegHandle;
begin
  // Factory Method
  Key := TRegHandle.OpenCurrentUser('Control Panel\International');
  
  if Key.IsValid then
  try
    // Fluent Method wrapping RegQueryValueEx
    Writeln(Key.ReadString('sCountry'));
  finally
    // Encapsulated Cleanup
    Key.Close; 
  end;
end;
```

This approach drastically enhances code clarity and type safety when dealing with raw OS handles.

👉 **[See Demo: API Wrappers](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Helpers/04%20-%20C%20API%20Wrappers)**

## 6. Restrictions: Limitations & The Vision

While Helpers are powerful, they are not a silver bullet. There are current limitations in the Delphi language to keep in mind:

### Current Limitations

1.  **Scope Resolution (The "Closest Helper Wins" Rule):** In Delphi, only *one* helper can be active for a specific type at a time. If two units in your `uses` clause define a helper for `String`, the compiler will only recognize the helper from the unit declared last. This is why the "Distinct Type" (`type TMyInt = type Integer`) pattern is so important for library developers.
2.  **No Generics:** You cannot define a generic helper (`THelper<T>`) or attach a helper to an open generic type (`helper for TList<T>`), although you can target specific constructed instances.
3.  **No Interfaces:** Helpers cannot be attached to `IInterface` types.
4.  **No Record Inheritance:** Unlike Class Helpers, Record Helpers cannot inherit from other helpers (`helper(TParent) for TRecord`). *(Note: This syntax is supported in FreePascal)*.

### The Goal: Unified Syntax

Despite these limits, the vision remains: **One mental model for all data types.**

*   **Universal "Active" Syntax:** Enabling `Data.Action` consistently across Objects, Records, and Primitives.
*   **Bridge, don't Break:** This pattern allows modern syntax to coexist with legacy code without deprecating existing patterns. It simply provides a more expressive, readable, and safer alternative.

## Conclusion

Helpers are more than just syntax sugar. They are a powerful architectural tool that allows us to:
1.  **Modernize** syntax without rewriting underlying business logic.
2.  **Extend** closed libraries and VCL/FMX components safely.
3.  **Bridge** the gap between Pascal's type safety and C-style APIs.

All the code examples demonstrated here are available in the **[Delphi-Playground Repository](https://github.com/tregubovav-dev/Delphi-Playground)**.

Happy Coding!