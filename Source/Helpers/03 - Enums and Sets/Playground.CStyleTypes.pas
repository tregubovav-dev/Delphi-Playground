(*  Delphi Playground: Delphi and/or FreePascal Presentation Demos            *)
(*  Source: https://github.com/tregubovav-dev/Delphi-Playground               *)
(*                                                                            *)
(*  This code is provided for educational and training purposes.              *)
(*  The coding patterns and techniques demonstrated herein may be freely used *)
(*  in any commercial or open-source project without restriction.             *)
(*                                                                            *)
(*  If you share or distribute these source files, please include a reference *)
(*  to the original repository linked above.                                  *)

unit Playground.CStyleTypes;

interface

uses
  System.SysUtils;

{$REGION 'C common declarations'}
(*
/* C common declarations for all examples */
/* "typedef" allows us to use "SOME_CTX" instead of "struct SOME_CTX" */
typedef struct {
    /* some complex structure */
    int dummy;
} SOME_CTX;
*)

type
  // Using a Pointer to a record to simulate the opaque C struct pointer
  PSomeCtx = ^TSomeCtx;
  TSomeCtx = record
  end;
{$ENDREGION}

{$REGION 'C-style simple enumeration'}
(*
/* C style zero-based continuous enumeration */
#define TEST_SIMPLE_ENUM_ZERO  0
#define TEST_SIMPLE_ENUM_ONE   1
...
#define TEST_SIMPLE_ENUM_SEVEN 7

void SOME_CTX_do_with_simple_enum(SOME_CTX *ctx, int enum_val);
int SOME_CTX_get_simple_enum(SOME_CTX *ctx);
*)

const
  TEST_SIMPLE_ENUM_ZERO   = 0;
  TEST_SIMPLE_ENUM_ONE    = 1;
  TEST_SIMPLE_ENUM_TWO    = 2;
  TEST_SIMPLE_ENUM_THREE  = 3;
  TEST_SIMPLE_ENUM_FOUR   = 4;
  TEST_SIMPLE_ENUM_FIVE   = 5;
  TEST_SIMPLE_ENUM_SIX    = 6;
  TEST_SIMPLE_ENUM_SEVEN  = 7;

type
  /// <summary>
  ///   Pascal mapping for a contiguous C-Style enum (0..N).
  /// </summary>
  TSimpleTestEnum = (steZero, steOne, steTwo, steThree,
                     steFour, steFive, steSix, steSeven);
type
  /// <summary>
  ///   Helper to safely convert between the Pascal Enum and the raw C-Integer.
  /// </summary>
  TSimpleTestEnumHelper = record helper for TSimpleTestEnum
  public const
    MinIntegerValue = Ord(Low(TSimpleTestEnum));
    MaxIntegerValue = Ord(High(TSimpleTestEnum));
  private const
{$REGION 'TSimpleTestEnumHelper conditional optimization'}
{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF SizeOf(TSimpleTestEnum) = 4}
    cOutMask = $FFFFFFFF;
  {$ELSEIF SizeOf(TSimpleTestEnum) = 2}
    cOutMask = $FFFF;
  {$ELSE}
    cOutMask = $FF;
  {$IFEND}
{$ELSE}
  {$MESSAGE Hint 'Update TSimpleTestEnum.cOutMask if SizeOf(TSimpleTestEnum) > 1'}
    cOutMask = = $FF;
{$ENDIF}
{$ENDREGION}

  private
    class procedure CheckRange(Value: integer); static; {$IFNDEF DEBUG}inline;{$ENDIF}
    function GetAsInteger: integer; {$IFNDEF DEBUG}inline;{$ENDIF}
    procedure SetAsInteger(Value: integer); {$IFNDEF DEBUG}inline;{$ENDIF}
  public
    /// <summary>Converts the Enum to its underlying integer value.</summary>
    class function ToInteger(Value: TSimpleTestEnum): integer; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>
    ///   Converts a raw integer to the Enum.
    ///   Raises ERangeError if the value is out of bounds.
    /// </summary>
    class function FromInteger(Value: integer): TSimpleTestEnum; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Checks if the Enum matches a specific raw integer value.</summary>
    class function IsEqual(AEnumVal: TSimpleTestEnum; Value: integer): boolean;
      overload; static; {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Instance version of IsEqual.</summary>
    function IsEqual(Value: integer): boolean; overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Property access for easier usage.</summary>
    property AsInteger: integer read GetAsInteger write SetAsInteger;
  end;

  TSimpleTestEnums = set of TSimpleTestEnum;

  // Mock procedures for C-API simulation
  procedure SOME_CTX_do_with_simple_enum(ACtx: PSomeCtx; Value: integer); cdecl;
  function SOME_CTX_get_simple_enum(ACtx: PSomeCtx): integer; cdecl;

{$ENDREGION}

{$REGION 'C-style Non-contiguous enumeration'}
(*
/* C style Non-contiguous enumeration */
typedef enum {
  STATUS_OFF      = 0,
  STATUS_WARMING  = 8,
  STATUS_PUMPING  = 24,
  STATUS_DRAINING = 32,
  STATUS_RESET    = 1024,
  STATUS_ERROR    = -1
} t_status;

int SOME_CTX_set_status(SOME_CTX *ctx, int enum_val);
int SOME_CTX_get_status(SOME_CTX *ctx);

*)

type
(*
  // This declaration looks obvious until you need iterate through
  // this type values and using a derived set from this type.
  TLegacyStatus = (lsError = -1, lsOff = 0, lsWarming = 8,
                   lsPumping = 24, lsDraining = 32, lsReset = 1024);

*)

  // Pascal Enums are contiguous usually (0, 1, 2, 3...).
  // We define the logical names here, but their Ord() values will NOT match the C values.
  // We use the Helper to map them.
  TLegacyStatus = (lsError, lsOff, lsWarming,
                   lsPumping, lsDraining, lsReset);
  TLegacyStatuses = set of TLegacyStatus;

{$REGION 'Conditional definition for TLegacyStatusHelper optimizations'}
const
  cTLegacyStatusElements = Succ(Ord(High(TLegacyStatus))-Ord(Low(TLegacyStatus)));
{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF cTLegacyStatusElements > 15}
    {$DEFINE TLegacyStatusBinarySearch}
  {$IFEND}
{$ENDIF}
{$ENDREGION}

type
  /// <summary>
  ///   Helper to map the contiguous Pascal Enum to the non-contiguous C values.
  /// </summary>
  TLegacyStatusHelper = record helper for TLegacyStatus
  private const
    // MAPPING TABLE: Maps Pascal Ordinal (Index) -> C Value.
    // MUST BE SORTED for Binary Search to work!
    cValues: array[TLegacyStatus] of integer = (-1, 0, 8, 24, 32, 1024);
  public const
    MinValue = Low(TLegacyStatus);
    MaxValue = High(TLegacyStatus);

  private
    class procedure RaiseError; static; {$IFNDEF DEBUG}inline;{$ENDIF}
    function GetAsInteger: integer; {$IFNDEF DEBUG}inline;{$ENDIF}
    procedure SetAsInteger(Value: integer); {$IFNDEF DEBUG}inline;{$ENDIF}

    class function SimpleScan(Value: integer;
      out ARetValue: TLegacyStatus): boolean; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    class function BinarySearch(Value: integer;
      out ARetValue: TLegacyStatus): boolean; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}
  public
    /// <summary>Returns the specific C-Value mapped to this Enum.</summary>
    class function ToInteger(Value: TLegacyStatus): integer; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>
    ///   Finds the Enum corresponding to the C-Value.
    ///   Raises ERangeError if not found.
    /// </summary>
    class function FromInteger(Value: integer): TLegacyStatus; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>
    ///   Attempts to find the Enum for a C-Value.
    ///   Returns False if the value is not in the map.
    /// </summary>
    class function TryFromInteger(Value: integer;
      out ARetValue: TLegacyStatus): boolean; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    class function IsEqualTo(Value: TLegacyStatus;
      IntValue: integer): boolean; overload; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    function IsEqualTo(Value: integer): boolean; overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    property AsInteger: integer read GetAsInteger write SetAsInteger;
  end;

  // Mock procedures for C-API simulation
  function SOME_CTX_set_status(ACtx: PSomeCtx; Value: integer): integer; cdecl;
  function SOME_CTX_get_status(ACtx: PSomeCtx): integer; cdecl;

{$ENDREGION}

{$REGION 'C-style Simple Flags'}

(*
/* C style flags (bttmasks) */
#define TEST_SIMPLE_FLAG_ZERO   1     /* bit 0: 2^0 = 1   */
...
#define TEST_SIMPLE_FLAG_NINE  512    /* bit 9: 2^9 = 512 */
*)

const
  TEST_SIMPLE_FLAG_ZERO   = 1 shl 0;
  TEST_SIMPLE_FLAG_ONE    = 1 shl 1;
  TEST_SIMPLE_FLAG_TWO    = 1 shl 2;
  TEST_SIMPLE_FLAG_THREE  = 1 shl 3;
  TEST_SIMPLE_FLAG_FOUR   = 1 shl 4;
  TEST_SIMPLE_FLAG_FIVE   = 1 shl 5;
  TEST_SIMPLE_FLAG_SIX    = 1 shl 6;
  TEST_SIMPLE_FLAG_SEVEN  = 1 shl 7;
  TEST_SIMPLE_FLAG_EIGHT  = 1 shl 8;
  TEST_SIMPLE_FLAG_NINE   = 1 shl 9;

type
  /// <summary>
  ///   Enumeration representing individual bit positions (0..9).
  /// </summary>
  TSimpleFlag = (flsZero, flsOne, flsTwo, flsThree, flsFour, flsFive,
                 flsSix, flsSeven, flsEight, flsNine);

  /// <summary>
  ///   Helper for manipulating single-bit flags.
  /// </summary>
  TSimpleFlagHelper = record helper for TSimpleFlag
  private const
    cMask = $3FF; // Covers bits 0..9 (10 bits)

  private
    class procedure InvalidTypeCast; static; {$IFNDEF DEBUG}inline;{$ENDIF}
    function GetAsInteger: integer; {$IFNDEF DEBUG}inline;{$ENDIF}
    procedure SetAsInteger(Value: integer); {$IFNDEF DEBUG}inline;{$ENDIF}

  public
    /// <summary>Converts the Enum to its bitmask value (1 shl Ord).</summary>
    class function ToInteger(Value: TSimpleFlag): integer; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>
    ///   Converts a raw integer to a Single Flag.
    ///   Raises EInvalidCast if Value is 0, has multiple bits set, or is out of range.
    /// </summary>
    class function FromInteger(Value: integer): TSimpleFlag; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Checks if the single flag matches the integer value.</summary>
    function IsEqualTo(Value: integer): boolean; inline;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Gets or Sets the integer value (1 shl N).</summary>
    property AsInteger: integer read GetAsInteger write SetAsInteger;
  end;

  /// <summary>
  ///   Set of flags representing a combined bitmask.
  /// </summary>
  TSimpleFlags = set of TSimpleFlag;

  /// <summary>
  ///   Helper for converting Pascal Sets to C-Style integer bitmasks.
  /// </summary>
  TSimpleFlagsHelper = record helper for TSimpleFlags
  public const
    cMask = TSimpleFlag.cMask;
  private
    function GetAsInteger: integer; {$IFNDEF DEBUG}inline;{$ENDIF}
    procedure SetAsInteger(Value: integer); {$IFNDEF DEBUG}inline;{$ENDIF}
  public
    /// <summary>
    ///   Converts the Set to a 32-bit Integer bitmask.
    ///   Uses safe pointer casting and masking.
    /// </summary>
    class function ToInteger(Value: TSimpleFlags): integer; overload; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>
    ///   Converts a raw Integer bitmask to a Pascal Set.
    ///   Masks the input value to ensure safety.
    /// </summary>
    class function FromInteger(Value: integer): TSimpleFlags; overload; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Checks if the Set's bitmask equals the integer value.</summary>
    function IsEqualTo(Value: integer): boolean; inline;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Gets or Sets the bitmask value.</summary>
    property AsInteger: integer read GetAsInteger write SetAsInteger;
  end;

  // Mock procedures for C-API simulation
  function SOME_CTX_set_simple_flags(ACtx: PSomeCtx; Value: integer): integer; cdecl;
  function SOME_CTX_get_simple_flags(ACtx: PSomeCtx): integer; cdecl;

{$ENDREGION}

{$REGION 'C-style Sparse Flags'}

(*
/* Non-contiguous bitmasks  */
/* bit zero (1) skipped for a reason */
/* bits 2 to 7 are declared as consts */
#define TEST_NC_FLAG_01         $0002    /* bit 0: 2^1 = 2         */
...
#define TEST_NC_FLAG_07         $0080    /* bit 7: 2^7 = 128       */
/* bits 8 to 15 for internal usage
...
#define TEST_NC_FLAG_16         $10000   /* bit 16: 2^16 = 65536   */
...
#define TEST_NC_FLAG_22         $40000   /* bit 22: 2^22 = 4194304 */

int SOME_CTX_set_nc_flags(SOME_CTX *ctx, int enum_val);
int SOME_CTX_get_nc_flags(SOME_CTX *ctx);
*)
{----}
{$REGION 'C-style Sparse Flags'}

(*
/* Non-contiguous bitmasks */
/* bit zero (1) skipped */
/* bits 1 to 7 are defined */
#define TEST_NC_FLAG_01         $0002    /* bit 1: 2^1 = 2         */
...
#define TEST_NC_FLAG_07         $0080    /* bit 7: 2^7 = 128       */
/* bits 8 to 15 skipped */
#define TEST_NC_FLAG_16         $10000   /* bit 16: 2^16 = 65536   */
...
#define TEST_NC_FLAG_22         $40000   /* bit 22 */
*)

const
  TEST_NC_FLAG_01   = 1 shl 1;
  TEST_NC_FLAG_02   = 1 shl 2;
  TEST_NC_FLAG_03   = 1 shl 3;
  TEST_NC_FLAG_04   = 1 shl 4;
  TEST_NC_FLAG_05   = 1 shl 5;
  TEST_NC_FLAG_06   = 1 shl 6;
  TEST_NC_FLAG_07   = 1 shl 7;

  TEST_NC_FLAG_16   = 1 shl 16;
  TEST_NC_FLAG_17   = 1 shl 17;
  TEST_NC_FLAG_18   = 1 shl 18;
  TEST_NC_FLAG_19   = 1 shl 19;
  TEST_NC_FLAG_20   = 1 shl 20;
  TEST_NC_FLAG_21   = 1 shl 21;
  TEST_NC_FLAG_22   = 1 shl 22;

type
  /// <summary>
  ///   Sparse Enumeration using Explicit Ordinals to match Bit Positions.
  ///   Note: Iterating Low(TNcFlag)..High(TNcFlag) will visit invalid "holes".
  ///   Iterating a "set of TNcFlag" is safe.
  /// </summary>
  TNcFlag = (
    ncfl01 = 1 {bit 1}, ncfl02, ncfl03, ncfl04, ncfl05, ncfl06, ncfl07,
    // Gap: bits 8..15 skipped
    ncfl016 = 16 {bit 16}, ncfl17, ncfl18, ncfl19, ncfl20, ncfl21, ncfl22
  );

  /// <summary>Helper for individual sparse flags.</summary>
  TNcFlagHelper = record helper for TNcFlag
  public const
    // Mask covering bits 1..7 and 16..22
    cMask = $7F00FE;
  private
    class procedure InvalidTypeCast; static; {$IFNDEF DEBUG}inline;{$ENDIF}
    function GetAsInteger: integer; {$IFNDEF DEBUG}inline;{$ENDIF}
    procedure SetAsInteger(Value: integer); {$IFNDEF DEBUG}inline;{$ENDIF}
  public
    class function ToInteger(Value: TNcFlag): integer; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>
    ///   Converts integer (power of 2) to Flag.
    ///   Raises exception if value is 0, multi-bit, or falls in a "hole".
    /// </summary>
    class function FromInteger(Value: integer): TNcFlag; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    function IsEqualTo(Value: integer): boolean; inline;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    property AsInteger: integer read GetAsInteger write SetAsInteger;
  end;

  TNcFlags = set of TNcFlag;

  /// <summary>Helper for Sets of sparse flags.</summary>
  TNcFlagsHelper = record helper for TNcFlags
  public const
    cMask = TNcFlag.cMask;
  private
    class procedure InvalidTypeCast; static; {$IFNDEF DEBUG}inline;{$ENDIF}
    function GetAsInteger: integer; {$IFNDEF DEBUG}inline;{$ENDIF}
    procedure SetAsInteger(Value: integer); {$IFNDEF DEBUG}inline;{$ENDIF}
  public
    /// <summary>Safe cast from Set to 32-bit Integer.</summary>
    class function ToInteger(Value: TNcFlags): integer; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Strict conversion. Raises exception if garbage bits found.</summary>
    class function FromInteger(Value: integer): TNcFlags; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    /// <summary>Safe conversion. Silently ignores garbage/hole bits.</summary>
    class function SafeFromInteger(Value: integer): TNcFlags; static;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    function IsEqualTo(Value: integer): boolean; inline;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    property AsInteger: integer read GetAsInteger write SetAsInteger;
  end;

  // Mock C-API
  function SOME_CTX_set_nc_flags(ACtx: PSomeCtx; Value: integer): integer; cdecl;
  function SOME_CTX_get_nc_flags(ACtx: PSomeCtx): integer; cdecl;

{$ENDREGION}{$ENDREGION}

implementation

uses
  System.SysConst;

{$REGION 'Support procedures'}
procedure _RangeCheckInteger(Value, AMin, AMax: integer);
{$IFNDEF DEBUG}inline;{$ENDIF}
begin
  if (Value < AMin) or (Value > AMax) then
      raise ERangeError.Create(SRangeError);
end;
{$ENDREGION}

{$REGION 'C-style simple enumeration'}

procedure SOME_CTX_do_with_simple_enum(ACtx: PSomeCtx; Value: integer); cdecl;
begin
  Writeln(Format('  [C-API] do_with_simple_enum. Setting %d', [Value]));
end;

function SOME_CTX_get_simple_enum(ACtx: PSomeCtx): integer; cdecl;
begin
  // Return a valid random value for the simple enum range (0..7)
  Result:=Random(Ord(High(TSimpleTestEnum))+1);
  Writeln(Format('  [C-API] get_simple_enum called. Returning %d', [Result]));
end;

{ TSimpleTestEnumHelper }

class procedure TSimpleTestEnumHelper.CheckRange(Value: integer);
begin
  _RangeCheckInteger(Value, MinIntegerValue, MaxIntegerValue);
end;

function TSimpleTestEnumHelper.GetAsInteger: integer;
begin
  Result:=ToInteger(Self);
end;

function TSimpleTestEnumHelper.IsEqual(Value: integer): boolean;
begin
  Result:=IsEqual(Self, Value);
end;

class function TSimpleTestEnumHelper.IsEqual(AEnumVal: TSimpleTestEnum;
  Value: integer): boolean;
begin
  Result:=AEnumVal.AsInteger = Value;
end;

procedure TSimpleTestEnumHelper.SetAsInteger(Value: integer);
begin
  Self:=FromInteger(Value);
end;

class function TSimpleTestEnumHelper.ToInteger(Value: TSimpleTestEnum): integer;
begin
  // Simple Cast: Pascal Ordinal matches C Value (0..7)
  // Use mask to clear garbage bits
  Result:=Ord(Value) and cOutMask;
end;

class function TSimpleTestEnumHelper.FromInteger(
  Value: integer): TSimpleTestEnum;
begin
  CheckRange(Value);
  // Safe cast after range check
  Result:=TSimpleTestEnum(Value);
end;

{$ENDREGION}

{$REGION 'C-style Non-contiguous enumeration'}

var
  GLegacyVal: integer = 0;

function SOME_CTX_set_status(ACtx: PSomeCtx; Value: integer): integer; cdecl;
begin
  Writeln(Format('  [C-API] set_status called with Value=%d', [Value]));
  case Value of
    -1, 0, 8, 24, 32, 1024:
      begin
        Writeln('  Value set successfuly.');
        GLegacyVal:=Value;
      end;
    else
      Writeln('  Value is not in the range.');
  end;
  Result:=0; // Success
end;

function SOME_CTX_get_status(ACtx: PSomeCtx): integer; cdecl;
begin
  Result:=GLegacyVal;
  Writeln(Format('  [C-API] get_status called. Returning %d', [Result]));
end;

{ TLegacyStatusHelper }

class procedure TLegacyStatusHelper.RaiseError;
begin
  raise ERangeError.Create(SRangeError);
end;

function TLegacyStatusHelper.GetAsInteger: integer;
begin
  Result:=ToInteger(Self);
end;

procedure TLegacyStatusHelper.SetAsInteger(Value: integer);
begin
  Self:=FromInteger(Value);
end;

class function TLegacyStatusHelper.SimpleScan(Value: integer;
  out ARetValue: TLegacyStatus): boolean;
var
  lRetValue: TLegacyStatus;
begin
  for lRetValue:=MinValue to MaxValue do
    if Value = cValues[lRetValue] then
    begin
      ARetValue:=lRetValue;
      Exit(True);
    end;
  Result:=False;
end;

class function TLegacyStatusHelper.BinarySearch(Value: integer;
  out ARetValue: TLegacyStatus): boolean;
var
  lLow, lHigh: TLegacyStatus;
  lRetValue: TLegacyStatus;
begin
  lLow:=MinValue;
  lHigh:=MaxValue;

  // Optimization: Quick check bounds before entering loop
  if ((Value >= cValues[lLow]) and (Value <= cValues[lHigh])) then
    while lLow <= lHigh do
    begin
      // Calculate middle index
      lRetValue:=TLegacyStatus(Ord(lLow)+((Ord(lHigh)-Ord(lLow)) div 2));

      if Value = cValues[lRetValue] then
      begin
        ARetValue:=lRetValue;
        Exit(True);
      end;

      if Value < cValues[lRetValue] then
        lHigh:=Pred(lRetValue)
      else
        lLow:=Succ(lRetValue);
    end;

  Result:=False;
end;

class function TLegacyStatusHelper.FromInteger(Value: integer): TLegacyStatus;
begin
  if not TryFromInteger(Value, Result) then
    RaiseError;
end;

class function TLegacyStatusHelper.ToInteger(Value: TLegacyStatus): integer;
begin
  // Look up the explicit C-Value from the mapping table
  Result:=cValues[Value];
end;

class function TLegacyStatusHelper.TryFromInteger(Value: integer;
  out ARetValue: TLegacyStatus): boolean;
begin
{$IFDEF TLegacyStatusBinarySearch}
  Result:=BinarySearch(Value, ARetValue);
{$ELSE}
  Result:=SimpleScan(Value, ARetValue);
{$ENDIF}
end;

class function TLegacyStatusHelper.IsEqualTo(Value: TLegacyStatus;
  IntValue: integer): boolean;
begin
  Result:=Value.AsInteger = IntValue;
end;

function TLegacyStatusHelper.IsEqualTo(Value: integer): boolean;
begin
  Result:=IsEqualTo(Self, Value);
end;

{$IFDEF TLegacyStatusBinarySearch}
  {$UNDEF TLegacyStatusBinarySearch}
{$ENDIF}

{$ENDREGION}

{$REGION 'C-style Simple Flags'}

var
  GSimpleFlags: integer = TEST_SIMPLE_FLAG_ONE or TEST_SIMPLE_FLAG_NINE;

// Mock procedures for C-API simulation
function SOME_CTX_set_simple_flags(ACtx: PSomeCtx; Value: integer): integer; cdecl;
begin
  GSimpleFlags:=Value;
  Writeln(Format('  [C-API] set_simple_flags called setting value 0x%x', [Value]));
  Result:=0; // success
end;

function SOME_CTX_get_simple_flags(ACtx: PSomeCtx): integer; cdecl;
begin
  Result:=GSimpleFlags;
  Writeln(Format('  [C-API] get_simple_flags called. Returning 0x%x', [Result]));
end;

{ TSimpleFlagHelper }

class procedure TSimpleFlagHelper.InvalidTypeCast;
begin
  raise EInvalidCast.Create('Invalid TEST_SIMPLE_FLAG Value.');
end;

function TSimpleFlagHelper.GetAsInteger: integer;
begin
  Result:=ToInteger(Self);
end;

procedure TSimpleFlagHelper.SetAsInteger(Value: integer);
begin
  Self:=FromInteger(Value);
end;

function TSimpleFlagHelper.IsEqualTo(Value: integer): boolean;
begin
  Result:=AsInteger = Value;
end;

class function TSimpleFlagHelper.FromInteger(Value: integer): TSimpleFlag;
var
  i: integer;

begin
  // Check validity: Not zero, Power of 2 (single bit), Inside Mask
  if (Value = 0) or ((Value and (Value-1)) <> 0)
    or ((Value or cMask) <> cMask) then
    InvalidTypeCast;

  // Find Log2 (Bit Index)
  i:=Ord(Low(TSimpleFlag));
  while (1 shl i) < Value do
    Inc(i);

  // Cast index to Enum.
  // Since we checked cMask, 'i' is guaranteed to be a valid ordinal.
  Result:=TSimpleFlag(i);
end;

class function TSimpleFlagHelper.ToInteger(Value: TSimpleFlag): integer;
begin
  Result:=(1 shl Ord(Value)) and cMask;
end;

{ TSimpleFlagsHelper }

function TSimpleFlagsHelper.GetAsInteger: integer;
begin
  Result:=ToInteger(Self);
end;

procedure TSimpleFlagsHelper.SetAsInteger(Value: integer);
begin
  Self:=FromInteger(Value);
end;

class function TSimpleFlagsHelper.FromInteger(Value: integer): TSimpleFlags;
begin
  Value:=Value and cMask;
  Result:=TSimpleFlags((@Value)^);
end;

{$REGION 'Range check OFF'}
{$IFDEF DEBUG}
  {$IFOPT R+}
    {$R-}
    {$DEFINE R_ON}
  {$ENDIF}
{$ENDIF}
{$ENDREGION}
class function TSimpleFlagsHelper.ToInteger(Value: TSimpleFlags): integer;
begin
// we need to be sure that the variable is correctly aligned
{$IF SizeOf(TSimpleFlags) = 1 }
  Result:=PByte(@Value)^;
{$ELSEIF SizeOf(TSimpleFlags) = 2}
  Result:=PWord(@Value)^;
{$ELSEIF SizeOf(TSimpleFlags) = 4}
  Result:=PCardinal(@Value)^;
(* for bigger sets and 64-bit result
{$ELSEIF SizeOf(TSimpleFlags) = 8}
  Result:=PUInt64(@Value)^;
*)
{$ELSE}
  {$Message Fatal 'Pascal Set size exceeded return size.'}
{$IFEND}
  Result:=Result and cMask;
end;
{$REGION 'Range check ON'}
{$IFDEF DEBUG}
  {$IFDEF R_ON}
    {$R+}
    {$UNDEF R_ON}
  {$ENDIF}
{$ENDIF}
{$ENDREGION}

function TSimpleFlagsHelper.IsEqualTo(Value: integer): boolean;
begin
  Result:=AsInteger = Value;
end;

{$ENDREGION}

{$REGION 'C-style Sparse Flags'}

var
  GNcFlags: integer = TEST_NC_FLAG_01 or TEST_NC_FLAG_22;

// Mock procedures for C-API simulation
function SOME_CTX_set_nc_flags(ACtx: PSomeCtx; Value: integer): integer; cdecl;
begin
  GNcFlags:=Value;
  Writeln(Format('  [C-API] set_nc_flags called setting value 0x%x', [Value]));
  Result:=0;
end;

function SOME_CTX_get_nc_flags(ACtx: PSomeCtx): integer; cdecl;
begin
  Result:=GNcFlags;
  Writeln(Format('  [C-API] get_nc_flags called. Returning 0x%x', [Result]));
end;

  { TNcFlagHelper }

class procedure TNcFlagHelper.InvalidTypeCast;
begin
  raise EInvalidCast.Create('Invalid TNcFlag Value.');
end;


function TNcFlagHelper.GetAsInteger: integer;
begin
  Result:=ToInteger(Self);
end;

procedure TNcFlagHelper.SetAsInteger(Value: integer);
begin
  Self:=FromInteger(Value);
end;

class function TNcFlagHelper.FromInteger(Value: integer): TNcFlag;
var
  i: integer;

begin
  // Check validity: Not zero, Power of 2 (single bit), Inside Mask
  if (Value = 0) or ((Value and (Value-1)) <> 0)
    or ((Value or cMask) <> cMask) then
    InvalidTypeCast;

  // Find Log2 (Bit Index)
  i:=Ord(Low(TNcFlag));
  while (1 shl i) < Value do
    Inc(i);

  // Cast index to Enum.
  // Since we checked cMask, 'i' is guaranteed to be a valid ordinal (not a hole).
  Result:=TNcFlag(i);
end;

class function TNcFlagHelper.ToInteger(Value: TNcFlag): integer;
begin
  // Explicit Ordinals match Bit Positions. Direct shift works.
  Result:=(1 shl Ord(Value)) and cMask;
end;

function TNcFlagHelper.IsEqualTo(Value: integer): boolean;
begin
  Result:=AsInteger = Value;
end;

{ TNcFlagsHelper }

class procedure TNcFlagsHelper.InvalidTypeCast;
begin
  raise EInvalidCast.Create('Invalid TNcFlags Value.');
end;

function TNcFlagsHelper.GetAsInteger: integer;
begin
  Result:=ToInteger(Self);
end;

procedure TNcFlagsHelper.SetAsInteger(Value: integer);
begin
  Self:=FromInteger(Value);
end;

{$REGION 'Range check OFF'}
{$IFDEF DEBUG}
  {$IFOPT R+}
    {$R-}
    {$DEFINE R_ON}
  {$ENDIF}
{$ENDIF}
{$ENDREGION}
class function TNcFlagsHelper.ToInteger(Value: TNcFlags): integer;
begin
// we need to be sure that the variable is correctly aligned
{$IF SizeOf(TNcFlags) = 1 }
  Result:=PByte(@Value)^;
{$ELSEIF SizeOf(TNcFlags) = 2}
  Result:=PWord(@Value)^;
{$ELSEIF SizeOf(TNcFlags) = 4}
  Result:=PCardinal(@Value)^;
(* for 33+ bit sets and 64-bit result
{$ELSEIF SizeOf(TNcFlags) = 8}
  Result:=PUInt64(@Value)^;
*)
{$ELSE}
  {$Message Fatal 'Pascal Set size exceeded return size.'}
{$IFEND}
  Result:=Result and cMask;
end;
{$REGION 'Range check ON'}
{$IFDEF DEBUG}
  {$IFDEF R_ON}
    {$R+}
    {$UNDEF R_ON}
  {$ENDIF}
{$ENDIF}
{$ENDREGION}


class function TNcFlagsHelper.FromInteger(Value: integer): TNcFlags;
begin
  if (Value or cMask) <> cMask then
    InvalidTypeCast;
  Result:=SafeFromInteger(Value);
end;

class function TNcFlagsHelper.SafeFromInteger(Value: integer): TNcFlags;
begin
  Value:=Value and cMask;
  Result:=TNcFlags((@Value)^);
end;

function TNcFlagsHelper.IsEqualTo(Value: integer): boolean;
begin
  Result:=AsInteger = Value;
end;

{$ENDREGION}

end.
