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

# Thank You!

**License:** MIT (Educational Use)