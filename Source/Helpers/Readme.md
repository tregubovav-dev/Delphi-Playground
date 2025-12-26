# Pascal Helpers Presentation Demos

This directory contains code examples accompanying the presentation **"Modernizing Pascal: Readability, Safety, and Sustainability with Helpers"**.

These demos illustrate how to transition from traditional global utility functions to modern, object-oriented Helper patterns in Delphi.

## Directory Structure

### `01 - Introduction`
Contains the core demos showing the "Why" and "How" of Helpers.
*   **Intro_01.SimpleTypes**
    *   **Focus:** Readability & Fluent Syntax.
    *   **Comparison:** Contrasts `IntToStr()`, `Trim()`, and `UpperCase()` with their helper equivalents (`.ToString`, `.Trim`, `.ToUpper`).
*   **Intro_02.Classes**
    *   **Focus:** Sustainability, Polymorphism, and Fluent Interfaces.
    *   **Scenario:** Extending `TStrings` without inheritance.
    *   **Key Feature:** Demonstrates chaining methods (e.g., `.Append(A).Append(B)`).

### `02 - Simple Types`
Demonstrates how to overcome the limitation that Record Helpers cannot be attached to generic primitive types directly without conflict.

*   **SimpleTypes_01_CustomBoolean**
    *   **Concept:** The "Distinct Type" Strategy (`type TMyBool = type Boolean`).
    *   **Feature:** Adds `ToString('Yes', 'No')` and parsing capabilities while maintaining assignment compatibility with standard `Boolean`.
*   **SimpleTypes_02_CustomInteger**
    *   **Concept:** Domain Logic on Primitives.
    *   **Feature:** Validation (`IsBetween`), clamping (`EnsureBetween`), and property checks (`IsEven`) on a distinct integer type (`TMyInt`).
*   **SimpleTypes_03_SimpleEnum**
    *   **Concept:** Metadata Attachment.
    *   **Feature:** Safely converting Integers to Enums (`TFruit`) and attaching string names for display without RTTI overhead.
*   **SimpleTypes_04_DynamicArray**
    *   **Concept:** Fluent Arrays.
    *   **Feature:** Turns `TArray<string>` into a powerful list-like object with `Add`, `Insert`, `Delete`, and `Join` methods.

### `03 - Enums and Sets`
Demonstrates how to bridge the gap between Pascal's strict, safe Enums and C-style loose Enums and Bitmasks.

*   **CStyleTypes_01_SimpleEnum**
    *   **Concept:** Zero-Cost Mapping.
    *   **Feature:** Mapping a contiguous C-Enum (0..N) to a Pascal Enum using `Ord()` conversion in a Helper, keeping the API type-safe.
*   **CStyleTypes_02_SparseEnum**
    *   **Concept:** Sparse Mapping Logic.
    *   **Feature:** Handling non-contiguous C-Enums (`-1, 0, 1024`) by mapping them to a clean, iterable Pascal Enum via a Lookup Table in the Helper.
*   **CStyleTypes_03_Bitmasks**
    *   **Concept:** Sets as Bitmasks.
    *   **Feature:** Using `TSimpleFlagsHelper` to convert a standard Pascal `set of TEnum` into a raw Integer bitmask for C-APIs, enabling `Include/Exclude` syntax instead of messy bitwise `OR/AND` operations.

*   **CStyleTypes_04_SparseBitmasks**
    *   **Concept:** Sparse Bitmasks (Explicit Ordinals).
    *   **Feature:** Handling complex C-bitmasks with reserved "holes" (e.g., skipping bits 8-15) by aligning Pascal Enum ordinals directly to bit positions (`eVal = 1`) and using a Helper mask to sanitize data.

 ### `04 - C API Wrappers`
Demonstrates how to wrap raw C-style Handles (`HKEY`, `HWND`, etc.) into safe, Object-Oriented interfaces using Helpers on Distinct Types.

*   **CStyleTypes_01_RegWrapper**
    *   **Concept:** Opaque Handle Wrapper.
    *   **Feature:** Wraps the Windows Registry API (`HKEY`) into a clean `TRegHandle` type.
    *   **Benefit:** Turns `RegOpenKeyEx/RegCloseKey` into `Key.Open/Key.Close` while maintaining binary compatibility with the OS.   

## Prerequisites

*   **Compiler:** **Delphi 10.4 Sydney** or newer.
    *   *Why?* While Helpers were introduced in XE3, this project uses modern features like **Inline Variables** (10.3) and the **`AtomicCmpExchange`** overload with the `Success` parameter (10.4).
*   **Target:** Console Application (Windows/Linux/macOS).

## How to Run
1.  Navigate to `01 - Introduction`.
2.  Open the project file in your Delphi IDE.
3.  Ensure `Playground.Utils.pas` is in the search path.
4.  Build and Run. Follow the on-screen instructions to step through the presentation slides.

## License and Usage

**Source: [Delphi-Playground](https://github.com/tregubovav-dev/Delphi-Playground)**

This code is provided for **educational and training purposes**.

*   **The Patterns:** You are free to use the coding patterns, techniques, and helper implementations demonstrated in this project in your own proprietary or open-source applications without restriction or attribution.
*   **The Source Files:** If you redistribute these specific source files (e.g., in a tutorial or collection), please retain the reference to the original GitHub repository.