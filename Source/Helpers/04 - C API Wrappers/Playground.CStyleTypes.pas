unit Playground.CStyleTypes;

interface

{$IFDEF MSWINDOWS}
uses
  System.SysUtils,
  Winapi.Windows;

{$REGION 'Windows Registry Wrapper'}


// Requires Winapi.Windows in interface/implementation uses clauses
// Ensure 'Winapi.Windows' is added to 'uses' section of the UNIT.

type
  /// <summary>
  ///   Distinct type for HKEY to prevent mixing with other THandles.
  /// </summary>
  TRegHandle = type HKEY;

  /// <summary>
  ///   Helper providing Object-Oriented access to Windows Registry API.
  /// </summary>
  TRegHandleHelper = record helper for TRegHandle
  public
    /// <summary>Opens a subkey under the hive in Root parameter (Read Only).</summary>
    class function Open(Root: HKEY; const SubKey: string): TRegHandle; static;

    /// <summary>Opens a subkey under HKEY_LOCAL_MACHINE (Read Only).</summary>
    class function OpenLocalMachine(const SubKey: string): TRegHandle; static;

    /// <summary>Opens a subkey under HKEY_CURRENT_USER (Read Only).</summary>
    class function OpenCurrentUser(const SubKey: string): TRegHandle; static;

    /// <summary>Reads a string value. Returns Default if not found or empty.</summary>
    function ReadString(const Name: string; const Default: string = ''): string;

    /// <summary>Closes the registry key.</summary>
    procedure Close;

    /// <summary>Checks if handle is non-zero.</summary>
    function IsValid: Boolean; inline;
  end;
{$ENDIF}

{$ENDREGION}

implementation

{$REGION 'Windows Registry Wrapper Implementation'}

{$IFDEF MSWINDOWS}

class function TRegHandleHelper.Open(Root: HKEY; const SubKey: string): TRegHandle;
var
  LRes: Integer;
  LKey: HKEY;
begin
  // Wraps RegOpenKeyEx
  LRes := RegOpenKeyEx(Root, PChar(SubKey), 0, KEY_READ, LKey);
  if LRes = ERROR_SUCCESS then
    Result := TRegHandle(LKey)
  else
    Result := TRegHandle(0);
end;

class function TRegHandleHelper.OpenLocalMachine(const SubKey: string): TRegHandle;
begin
  Result := Open(HKEY_LOCAL_MACHINE, SubKey);
end;

class function TRegHandleHelper.OpenCurrentUser(const SubKey: string): TRegHandle;
begin
  Result := Open(HKEY_CURRENT_USER, SubKey);
end;

function TRegHandleHelper.ReadString(const Name: string; const Default: string): string;
var
  LType: DWORD;
  LSize: DWORD;
  LRes: Integer;
  LBuffer: TBytes;
begin
  if not IsValid then Exit(Default);

  // 1. Get Size
  LSize := 0;
  LRes := RegQueryValueEx(HKEY(Self), PChar(Name), nil, @LType, nil, @LSize);

  if (LRes <> ERROR_SUCCESS) or (LSize = 0) then Exit(Default);
  if (LType <> REG_SZ) and (LType <> REG_EXPAND_SZ) then Exit(Default);

  // 2. Read Data
  SetLength(LBuffer, LSize);
  LRes := RegQueryValueEx(HKEY(Self), PChar(Name), nil, nil, @LBuffer[0], @LSize);

  if LRes = ERROR_SUCCESS then
  begin
    // Trim null terminator if present
    if (LSize > 0) and (LBuffer[LSize - 1] = 0) then
      SetLength(LBuffer, LSize - 1)
    else if (LSize > 1) and (LBuffer[LSize - 2] = 0) then // WideChar null
      SetLength(LBuffer, LSize - 2);

    Result := TEncoding.Unicode.GetString(LBuffer);
  end
  else
    Result := Default;
end;

procedure TRegHandleHelper.Close;
begin
  if IsValid then
    RegCloseKey(HKEY(Self));
end;

function TRegHandleHelper.IsValid: Boolean;
begin
  Result := Self <> TRegHandle(0);
end;

{$ENDIF}

{$ENDREGION}
end.
