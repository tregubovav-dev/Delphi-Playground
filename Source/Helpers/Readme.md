# Pascal Helpers Presentation Demos

This directory contains code examples accompanying the presentation **"Modernizing Pascal: Readability, Safety, and Sustainability with Helpers"**.

These demos illustrate how to transition from traditional global utility functions to modern, object-oriented Helper patterns in Delphi.

## Directory Structure

### `01 - Introduction`
Contains the core demos showing the "Why" and "How" of Helpers.
*   **Intro_01.SimpleTypes.pas**
    *   **Focus:** Readability & Fluent Syntax.
    *   **Comparison:** Contrasts `IntToStr()`, `Trim()`, and `UpperCase()` with their helper equivalents (`.ToString`, `.Trim`, `.ToUpper`).
*   **Intro_02.Classes.pas**
    *   **Focus:** Sustainability, Polymorphism, and Fluent Interfaces.
    *   **Scenario:** Extending `TStrings` without inheritance.
    *   **Key Feature:** Demonstrates chaining methods (e.g., `.Append(A).Append(B)`).

### `02 - Simple Types`
Demonstrates how to overcome the limitation that Record Helpers cannot be attached to generic primitive types directly without conflict.

*   **SimpleTypes_01_CustomBoolean.pas**
    *   **Concept:** The "Distinct Type" Strategy (`type TMyBool = type Boolean`).
    *   **Feature:** Adds `ToString('Yes', 'No')` and parsing capabilities while maintaining assignment compatibility with standard `Boolean`.
*   **SimpleTypes_02_CustomInteger.pas**
    *   **Concept:** Domain Logic on Primitives.
    *   **Feature:** Validation (`IsBetween`), clamping (`EnsureBetween`), and property checks (`IsEven`) on a distinct integer type (`TMyInt`).
*   **SimpleTypes_03_SimpleEnum.pas**
    *   **Concept:** Metadata Attachment.
    *   **Feature:** Safely converting Integers to Enums (`TFruit`) and attaching string names for display without RTTI overhead.
*   **SimpleTypes_04_DynamicArray.pas**
    *   **Concept:** Fluent Arrays.
    *   **Feature:** Turns `TArray<string>` into a powerful list-like object with `Add`, `Insert`, `Delete`, and `Join` methods.

### `03 - Enums and Sets` (Planned)
Helpers for C-style enumerations, bitmasks, and set operations.

## Prerequisites
*   **Compiler:** Delphi XE3 or newer (required for Helper support).
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