---
marp: true
theme: default
class: lead
paginate: true
backgroundColor: #ffffff
style: |
  section { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
  code { font-family: 'Consolas', 'Courier New', monospace; background: #f0f0f0; padding: 2px 5px; border-radius: 4px; }
  pre { background: #1e1e1e; color: #d4d4d4; }
  blockquote { font-size: 75%; color: #666; border-left: 4px solid #2b5797; background: #f9f9f9; padding: 10px; }
  h1 { color: #2b5797; }
  h2 { color: #20406b; }
  strong { color: #b91d47; }
---

# Modernizing Pascal
## Readability, Safety, and Sustainability with Helpers

**Source:** `github.com/tregubovav-dev/Delphi-Playground`

---

<!-- _class: default -->

# The Problem: "The Utils Hell"

We've all seen code like this in legacy projects:

~~~pascal
// The "Matreshka" ("Russian Doll") Effect
Result := QuotedStr(UpperCase(Trim(IntToStr(Value))));
~~~

### The Issues:
1.  **Hard to Read:** You must read the logic from the *inside-out*.
2.  **Poor Discoverability:** You must memorize global function names instead of discovering them via Code Completion.
3.  **Disconnected Logic:** Data is passive; it is merely an argument passed to external routines.

---

# Section 1: Readability
## Shifting from "Passive" to "Active"

**Classic Pascal (Procedural)**
*   The Data is the **Object** (passive).
*   The Routine is the **Subject** (active).
*   *Thinking:* "I need a function to trim this string."

**Modern Pascal (Helpers)**
*   The Data is the **Subject** (active).
*   The Data performs actions on itself.
*   *Thinking:* "String, trim yourself."

---

# Demo 1: Simple Types (`Intro_01`)

**Classic Approach:**
~~~pascal
// Nested, Right-to-Left reading
Result := QuotedStr(UpperCase(Trim(AStr)));
~~~

**Helper Approach:**
~~~pascal
// Linear, Left-to-Right reading
Result := AStr.Trim.ToUpper.QuotedString;
~~~

> The code reads like a sentence.

---

# Section 2: Sustainability
## The "Inheritance Trap"

**Scenario:** You need an `Append` method for string lists.

**The Wrong Way:**
~~~pascal
type TMyStringList = class(TStringList) ... end;
~~~
*   ❌ Fails with `TMemo.Lines` (which is `TStrings`).
*   ❌ Fails with `TComboBox.Items`.
*   ❌ Requires changing type definitions everywhere.

---

# The Solution: Helper Polymorphism

**The Right Way:**
~~~pascal
type
  TStringsHelper = class helper for TStrings
  public
    procedure Append(Source: TStrings);
  end;
~~~

*   ✅ Works on `TStringList`.
*   ✅ Works on `TMemo.Lines`.
*   ✅ Works on `TComboBox.Items`.

> We extend the **Abstract Base Class**, effectively patching the entire RTL.

---

# Section 3: The Fluent Interface
## Method Chaining

In `Intro_02`, we changed the procedure to a function:

~~~pascal
function TStringsHelper.Append(Source: TStrings): TStrings;
begin
  // Logic here...
  Result := Self; // <--- The Magic
end;
~~~

By returning `Self`, we allow the object to stay "active" for the next command.

---

# Demo 2: The Chain (`Intro_02`)

This allows us to write expressive, "Story-telling" code:

~~~pascal
lMainList
  .Append(lCiceroList, True, '<-- Cicero -->')
  .Append(lFarFarAwayList, True, '<-- FarFarAway -->')
  .Append(lPanagramList, True, '<-- Panagram -->');
~~~

**Visualizing the Flow:**
`MainList` -> `Append(A)` -> *returns MainList* -> `Append(B)` -> *returns MainList*

---

# Summary

| Feature | Classic Pascal | Modern Helper |
| :--- | :--- | :--- |
| **Syntax** | `Func(Data)` | `Data.Func` |
| **Philosophy** | Data is Passive | Data is Active |
| **Extensibility** | Inheritance / Utils | Helpers on Base Class |
| **Flow** | Nested | Linear / Chained |

### Get the Code
Clone the repository to try the demos:
`github.com/tregubovav-dev/Delphi-Playground`

---

<!-- _class: lead -->

# Section 2: Simple Types
## Overcoming the "Last Helper Wins" Rule

**Source:** `Source/Helpers/02 - Simple Types`

---

<!-- _class: default -->

# The Problem: Helper Conflicts

If you declare a global helper for `Integer`, you might break code that relies on `System.SysUtils.TIntegerHelper`.

~~~pascal
type
  TMyHelper = record helper for Integer ... end;

var I: Integer;
begin
  I.ToString; // Error! TMyHelper hides SysUtils.TIntegerHelper
end;
~~~

### The Goal
We want to add **Domain Logic** (validation, formatting) without breaking standard RTL features.

---

# The Solution: Distinct Types

Pascal allows us to define a **Distinct Type** that shares the same memory structure but has a unique identity.

~~~pascal
type
  // "type Integer" creates a distinct type
  TMyInt = type Integer; 

  // Now we attach the helper to OUR type
  TMyIntHelper = record helper for TMyInt ... end;
~~~

> This allows `TMyInt` to have its own methods, separate from `Integer`.

---

# The Magic of "Type Compatibility"

Even though they are distinct types, Pascal treats them as **Assignment Compatible** because the underlying data structure is identical.

~~~pascal
var
  Std: Integer;
  Mine: TMyInt;
begin
  Std := 10;
  
  // Works! Implicit assignment. No cast needed.
  Mine := Std; 
  
  // Uses OUR helper methods
  Mine.IsBetween(0, 100); 
end;
~~~
---

# Demo 1 & 2: Boolean & Integer (`TMyBool`)

We can replace verbose formatting logic with clean, readable calls.

**Classic:**
~~~pascal
if IsActive then S := 'Yes' else S := 'No';
~~~

**Helper Approach:**
~~~pascal
// TMyBool helper
S := IsActive.ToString('Yes', 'No');
~~~

**Validation (`TMyInt`):**
~~~pascal
// TMyInt helper
if Val.IsBetween(1, 100) then ...
Val := Val.EnsureBetween(0, 50); // Clamping
~~~

---

# Demo 3: Smarter Enums (`TFruit`)

Enums are usually just numbers. We can attach **Metadata** (like names) directly to the type using a helper.

~~~pascal
type
  TFruit = (frApple, frOrange);
  
  TFruitHelper = record helper for TFruit
    const Names: array[TFruit] of string = ('Apple', 'Orange');
    function ToString: string;
  end;
~~~

**Usage:**
~~~pascal
// Calling static method on the Type
Fruit := TFruit.FromInteger(99); // Safe! Returns frUnknown
Writeln(Fruit.ToString);         // Prints "Unknown"
~~~

> No RTTI overhead. Just clean, compile-time logic.

---

# Demo 4: Fluent Arrays (`TStringArray`)

Dynamic Arrays are powerful but primitive. We can give them a **Fluent Interface** to behave like a List.

~~~pascal
var Tags: TStringArray;

Tags := TStringArray.Create(['Delphi']);

Tags
  .Add('Helpers')
  .Insert('Pascal', 0)
  .Delete(1, 1);
  
Writeln(Tags.Join(', ')); 
// Output: Pascal, Helpers
~~~

> **Note:** The helper manages memory reallocation automatically via `Self := ...`.

---

# Summary

| Pattern | Scenario | Benefit |
| :--- | :--- | :--- |
| **Distinct Type** | `type TMyInt = type Integer` | Avoids Helper conflicts. |
| **Compatibility** | `MyInt := StandardInt` | Seamless integration. |
| **Static Factory** | `TFruit.FromInteger` | Safe conversion logic. |
| **Self Mutation** | `Tags.Add(...)` | In-place array modification. |

### Next Steps
Explore the code in `02 - Simple Types` to see the full implementation of the library unit.

---

<!-- _class: lead -->

# Section 3: C-Style Enums
## Bridging the Gap between Pascal and C

**Source:** `Source/Helpers/03 - Enums`

---

<!-- _class: default -->

# The Problem: Enum Mismatches

**Pascal Enums** are strictly ordinal and contiguous (`0, 1, 2...`).
**C Enums** are just named integers and can be sparse or negative.

~~~c
// C Declaration
typedef enum {
  STATUS_OFF   = 0,
  STATUS_ERROR = -1,   // Negative!
  STATUS_RESET = 1024  // Huge Gap!
} t_status;
~~~

### The Challenge
How do we map this to Pascal without losing type safety or using "Magic Numbers"?

---

# Scenario A: Contiguous Enums (`0..N`)

If the C enum is continuous (`0, 1, 2`), we map it directly.

**Helper Pattern:**
~~~pascal
TSimpleEnum = (steZero, steOne, steTwo);

// Helper adds Type Safety
property AsInteger: Integer read GetAsInteger;
~~~

**Usage:**
~~~pascal
// Instead of unsafe cast: Integer(MyEnum)
C_API_Call(MyEnum.AsInteger); 

// Safe conversion with Range Check
MyEnum := TSimpleEnum.FromInteger(C_ReturnValue);
~~~

---

# Scenario B: Sparse Enums (`-1, 1024...`)

For non-contiguous values, we separate the **Logical Type** from the **Physical Value**.

**1. Define Contiguous Pascal Enum:**
~~~pascal
// Standard Pascal Enum (0, 1, 2...)
// Supports Sets, Loops, and RTTI
TLegacyStatus = (lsError, lsOff, lsReset);
~~~

**2. Map in Helper:**
~~~pascal
// The "Dirty" values live here
const cValues: array[TLegacyStatus] of Integer 
      = (-1, 0, 1024);
~~~

---

# The "Magic" Conversion

The Helper transparently translates between the **Index** (Pascal) and the **Value** (C).

**Pascal -> C (Lookup)**
~~~pascal
function ToInteger: Integer;
begin
  Result := cValues[Self]; 
end;
~~~

**C -> Pascal (Reverse Lookup)**
~~~pascal
// Uses Binary Search or Scan
class function FromInteger(Val: Integer): TLegacyStatus;
~~~

---

# The "Pure Pascal" Benefit

Because we use a **standard contiguous enum**, we gain features that are broken or impossible with sparse C-enums.

**1. Sets (Bitmasks)**
~~~pascal
// Safe states: Off(0) or Warming(8)
if Status in [lsOff, lsWarming] then ... 
~~~

**2. Iteration**
~~~pascal
// Loop easily despite gaps (-1...1024)
for Status := Low(TLegacyStatus) to High(TLegacyStatus) do
  Log(Status.AsInteger);
~~~

> **Note:** Explicitly assigned enums (`eVal = 5`) break `set of` support. Our approach keeps it.
> **Contrast:** You cannot `for` loop over `-1, 0, 8, 1024` easily in C without an array. In Pascal + Helpers, it's native.

---

# Why this matters?

This pattern allows your business logic to remain **Pure Pascal**.

*   ✅ Works with `for..in` loops.
*   ✅ Works with `set of TLegacyStatus`.
*   ✅ Works with Array indices.
*   ✅ **Zero** runtime overhead for the Type definition itself.

**The "Dirty" C-mapping logic is encapsulated entirely inside the Helper.**

```pascal
// Clean Code
if Status in [lsOff, lsReset] then ...

// Dirty Work (Hidden)
API_SetStatus(Status.AsInteger); // Sends 0 or 1024