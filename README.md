# Delphi Playground

**Source: [https://github.com/tregubovav-dev/Delphi-Playground](https://github.com/tregubovav-dev/Delphi-Playground)**

A collection of Delphi code examples, patterns, and best practices for modern Object Pascal development.

## Contents

### [Pascal Helpers](Source/Helpers/)
Located in `Source\Helpers\`.
A comprehensive guide to using Class and Record Helpers to improve code readability, safety, and sustainability.
*   **01 - Introduction:** Basic syntax, Fluent Interfaces, and RTL extension.
*   **02 - Simple Types:** Patterns for extending primitives (Boolean, Integer) using Distinct Types, plus safe Enums and fluent Arrays.
*   **03 - Enums and Sets:** Advanced handling of C-style enumerations and bitmasks.
*   **04 - C API Wrappers** Using C-style Handles as safe Object-Oriented interfaces.

### [Advanced Records](Source/Records/)
Located in `Source\Records\`.
Explores the power of Record Wrappers and Operator Overloading to create robust value types.
*   **01 - Overloads:** Zero-overhead wrappers for primitive types.
*   **02 - Safe Sets:** Fixed-size bitmasks that behave like Pascal Sets (C-Interop safe).
*   **03 - Atomic Wrappers:** Lock-free thread-safe Integers and Sets using CAS loops and Volatile memory.