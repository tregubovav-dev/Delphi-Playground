# Modernizing Object Pascal: Readability, Safety, and Sustainability with Helpers

**By Alexander Tregubov**

*Source Code available at: [Delphi-Playground](https://github.com/tregubovav-dev/Delphi-Playground)*

---

Developers have long embraced Object-Oriented Programming (OOP) and class-based designs. However, we often treat primitive types—like Integers, Booleans, and Strings—as "givens," relying on legacy global procedures and functions to manipulate them.

This results in codebases that speak **two parallel languages**: a clean, fluent object syntax for classes, and a disjointed procedural style for simple types.

In this article, I will present a modern alternative using Helpers. We will explore how to unify these styles to improve code readability and maintainability, while significantly reducing the risk of logical errors and unsafe API usage.

## The Utility Unit Problem

Object Pascal (Delphi/FreePascal) is a language famous for its readability. However, as projects grow, legacy code often accumulates into what I call "The Utility Unit Problem."

We have all seen code like this:

```pascal
// The "Matryoshka" (Russian Doll) Effect
Result := QuotedStr(UpperCase(Trim(IntToStr(Value))));
```

To understand this, you have to read it backwards—from the inside out. The data itself is passive; it merely gets passed around to global routines found in units (`SysUtils`, `StrUtils`, `MyUtils`, etc.) that you have to memorize.

In this article, I will show you how to use **Class and Record Helpers** to modernize your Pascal code, transforming it into a more fluent, type-safe, and sustainable structure.

## 1. Readability: Shifting from Passive to Active

The first step to modernization is to change the way we communicate in our code. Instead of thinking, "I need a function to trim this string," we should think: "String, trim yourself."

By using Helpers on simple types provided by the `System.SysUtils` unit, we can convert nested function calls into a clear, linear pipeline:

```pascal
// Classic Approach (Nested)
Result := QuotedStr(UpperCase(Trim(AStr)));

// Helper Approach (Fluent)
Result := AStr.Trim.ToUpper.QuotedString;
```

This version reads like a sentence. It lowers cognitive load because the operations follow the natural flow of data (Left-to-Right).

You can find a list of standard helpers for simple types in the [System.SysUtils](https://docwiki.embarcadero.com/Libraries/Florence/en/System.SysUtils) section of the Delphi documentation.

👉 **[See Demo: Introduction to Simple Types](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Helpers/01%20-%20Introduction/Intro_01.SimpleTypes.dpr)**

## 2. Sustainability: The Inheritance Trap

A common challenge in Delphi development is extending standard classes like `TStrings`. The traditional object-oriented approach relies on Inheritance:

```pascal
type 
  TMyStringList = class(TStringList) 
    ... 
  end;
```

However, this can lead to a trap. Why? Because you cannot use `TMyStringList` with standard VCL/FMX components. For example, the `TMemo.Lines` property is already instantiated as `TStrings`, making your derived class ineffective in that context.

**The Solution: Helper Polymorphism**

By defining a **Class Helper** for the base class `TStrings`, we effectively enhance every string list in the entire application instantly.

```pascal
type
  TStringsHelper = class helper for TStrings
    procedure Append(Source: TStrings);
  end;
```

This newly defined method is now available on `TStringList`, `TMemo.Lines`, and `TComboBox.Items`. We write the functionality once, and it becomes accessible everywhere.

👉 **[See Demo: Class Helpers](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Helpers/01%20-%20Introduction/Intro_02.Classes.dpr)**

## 3. Architecture: The Power of Distinct Types

While Class Helpers are widely recognized, **Record Helpers** on simple types (like Integer) are often avoided due to conflicts with standard RTL helpers (`TIntegerHelper`).

The solution is the **Distinct Type**. Pascal allows us to declare a new type that shares the same memory structure but has a unique identity:

```pascal
type
  TMyInt = type Integer;
```

By doing this, we can attach a specific helper to `TMyInt` without interfering with `TIntegerHelper`.

**The Magic of Compatibility**

The greatest advantage of this pattern is that Pascal treats these distinct types as **Assignment Compatible**. You can assign a standard `Integer` to `TMyInt` without a cast:

```pascal
var
  Std: Integer;
  Mine: TMyInt;
begin
  Std := 10;
  Mine := Std; // Implicit assignment works!
  
  // Now we use our custom domain logic
  if Mine.EnsureBetween(0, 50) then ...
end;
```

This allows us to easily introduce strict domain logic (Validation, Formatting) into legacy codebases without disruptions.

👉 **[See Demos: Simple Types and Logic](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Helpers/02%20-%20Simple%20types)**

## 4. Advanced C-Interop: Taming Enums and Bitmasks

Interfacing with C/C++ APIs is a common requirement, but C enums and bitmasks can be challenging compared to Pascal's strict typing.

### Scenario A: Sparse Enums

**The Problem:**
C enums often contain non-contiguous values, as shown here:

```c
typedef enum {
  STATUS_ERROR = -1,
  STATUS_OFF   = 0,
  STATUS_RESET = 1024
} t_status;
```

While Pascal allows explicitly assigned enums (`type TStatus = (sError = -1, sReset = 1024)`), using them in this scenario can lead to architectural pitfalls:

1.  **Broken Sets:** You cannot declare `set of TStatus` if the range exceeds 255 values (0..255). A value of `1024` makes sets impossible.
2.  **Fragile Iteration:** Iterating over non-contiguous enums is complex and prone to errors.
3.  **Leaky Abstraction:** Developers are forced to constantly think about the "magic numbers" rather than focusing on the logical state.

**The Solution:** Separate the **Logic** from the **Value**.
1.  Define a clean Pascal Enum: `TLegacyStatus = (lsError, lsOff, lsReset);`
2.  Use a Helper to map it to the raw C values using a lookup table.

This approach keeps our business logic **Pure Pascal**. We can use `for..in` loops, Sets, and RTTI, while the Helper handles the translation to `-1` or `1024` transparently.

👉 **[See Demo: Enums and Sparse Mapping](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Helpers/03%20-%20Enums)**

### Scenario B: Safe Bitmasks

C APIs love bitmasks (`int flags`). Pascal developers love `Sets`.

However, directly casting a Set to an Integer (`Integer(MySet)`) is not valid syntax in modern Delphi, and using indirect casting (`PInteger(@MySet)^`) can be dangerous since Pascal Sets vary in size (1, 2, 4 bytes). Attempting to read 4 bytes from a 1-byte set reads stack garbage.

We can solve this with a **Bitmask Helper** that uses compile-time size detection:

```pascal
class function TFlagsHelper.ToInteger(Value: TMyFlags): Integer;
begin
  // Compile-time check for size
  {$IF SizeOf(TMyFlags) = 1}
    Result := PByte(@Value)^;
  {$ELSEIF SizeOf(TMyFlags) = 2}
    Result := PWord(@Value)^;
  {$ENDIF}
  
  // Sanitize
  Result := Result and cMask;
end;
```

This allows us to interact with C APIs using clean and fluent Pascal syntax:

```pascal
// Clean construction
Flags := [flsRead, flsAsync];

// Safe API call
C_SetFlags(Flags.AsInteger);
```

👉 **[See Demo: Bitmasks and Sets](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Helpers/03%20-%20Enums)**

## 5. API Wrappers: Opaque Handles

Finally, consider Opaque Handles like Windows `HKEY` or `HWND`. In raw API calls, these handles are represented as integers (or pointers), making it easy to accidentally pass the wrong handle type or forget to close them properly.

To address this issue, we can use the **Distinct Type** strategy again:

```pascal
type
  TRegHandle = type HKEY; // Distinct from Cardinal/Integer
```

By attaching a helper, we can transform the procedural WinAPI into an Object-Oriented interface with zero runtime overhead:

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

This approach enhances code clarity and safety when dealing with API handles.

👉 **[See Demo: API Wrappers](https://github.com/tregubovav-dev/Delphi-Playground/tree/main/Source/Helpers/04%20-%20C%20API%20Wrappers/CStyleTypes_01_OpaqueHandle.dpr)**

## Conclusion

Helpers are more than just syntax sugar. They are a powerful architectural tool that allows us to:
1.  **Modernize** syntax without rewriting logic.
2.  **Extend** closed libraries safely.
3.  **Bridge** the gap between Pascal safety and C-style APIs.

All the code examples demonstrated here are available in the **[Delphi-Playground Repository](https://github.com/tregubovav-dev/Delphi-Playground)**.

Happy Coding!