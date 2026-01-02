# Advanced Records & Operator Overloading

This directory demonstrates how to use **Advanced Records** to create powerful, zero-overhead wrappers. Unlike Helpers (which patch existing types), Records allow us to define **New Types** with custom operators, memory layout control, and atomic safety.

## Directory Structure

### `01 - Operand Overloads`
**Goal:** Zero-Overhead Wrappers.
Demonstrates wrapping a primitive type (`Double`) to add custom behavior without runtime cost.
*   **Records_01_Basics:**
    *   **Implicit/Explicit Casting:** Seamless assignment between `String` and `Record`.
    *   **Equality Operators:** Comparing records directly with literals (`if Rec = '10.5'`).
    *   **Zero Overhead:** Proves that `SizeOf(Wrapper) == SizeOf(Double)`.

### `02 - Safe Sets`
**Goal:** Fixed-Size Bitmasks.
Standard Pascal Sets vary in size (1, 2, 4, 32 bytes), making them dangerous for C-Interop or Records.
*   **Records_02_SafeSet:**
    *   **Auto-Sizing:** A record that behaves like a Set but guarantees fixed storage (e.g., 4 bytes).
    *   **Operators:** `+`, `-`, `in`, `Include`, `Exclude`.
    *   **Interop:** Safe to pass to C-APIs expecting `uint32` flags.

### `03 - Atomic`
**Goal:** Thread-Safe Value Types.
Implements wrappers that enforce atomic access patterns using `LOCK` intrinsics and `[Volatile]` storage.
*   **Records_03_AtomicInt:**
    *   **Concept:** A thread-safe Integer wrapper.
    *   **Features:** Atomic `Increment`, `Add`, `Exchange`, and `CAS` (Compare-And-Swap).
    *   **Demonstration:** Toggles between `Integer` (Data Corruption/Race Condition) and `TAtomicInt` (Perfect Data Integrity).
*   **Records_04_AtomicSet:**
    *   **The Ultimate Wrapper:** Combines **Safe Sets** (Fixed Size) with **Atomic CAS Loops**.
    *   **Features:** `AtomicInclude`, `AtomicExclude`, `AtomicTransition`. Allows thread-safe flag management without critical sections.

## Prerequisites
*   **Compiler:** Delphi 10.4 Sydney or newer (Required for `AtomicCmpExchange` intrinsics).
*   **Platform:** Windows/Linux/macOS (Console).