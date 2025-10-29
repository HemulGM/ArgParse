unit ArgParse;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  {$SCOPEDENUMS ON}

  TArgAction = (
  /// <summary>
  /// Expects a value after the flag (for example, --count 5).
  /// </summary>
  Store,
  /// <summary>
  /// A boolean flag that is set to True if present (for example, --verbose).
  /// </summary>
  Flag);

  TArgType = (AsString, AsInteger, AsBoolean);

  EArgumentParserError = class(Exception);

  TArgument = class
  public
    Name: string;           // logical name, e.g. "verbose" or "filename"
    ShortName: string;      // e.g. "-v"
    LongName: string;       // e.g. "--verbose"
    Help: string;
    Required: Boolean;
    Action: TArgAction;
    ArgType: TArgType;
    DefaultValue: string;
    Choices: TArray<string>;
    Requirements: TArray<string>; // requirements args
    constructor Create(const AName: string);
  end;

  INamespace = interface
    ['{6A3AF304-E7E0-4230-8D0F-C2BFBB63E88D}']
    function Has(const AName: string): Boolean;
    procedure SetValue(const AName: string; const AValues: string);
    function GetAsString(const AName: string; const ADefault: string = ''): string;
    function GetAsInteger(const AName: string; ADefault: Integer = 0): Integer;
    function GetAsBoolean(const AName: string; ADefault: Boolean = False): Boolean;
  end;

  TNamespace = class(TInterfacedObject, INamespace)
  private
    FValues: TDictionary<string, string>;
  public
    constructor Create;
    destructor Destroy; override;
    function Has(const AName: string): Boolean;
    procedure SetValue(const AName: string; const AValues: string);
    function GetAsString(const AName: string; const ADefault: string = ''): string;
    function GetAsInteger(const AName: string; ADefault: Integer = 0): Integer;
    function GetAsBoolean(const AName: string; ADefault: Boolean = False): Boolean;
  end;

  IArgumentParser = interface
    ['{641E3306-0498-49D3-B835-6458FE69412D}']
    function GetParamArgs: INamespace;
    /// <summary>
    /// Adds a description of the use of the program
    /// </summary>
    procedure SetDescription(const ADesc: string);
    /// <summary>
    /// Adds a new command-line argument to the parser.
    /// </summary>
    /// <param name="AName">
    /// The logical name of the argument, which is then used to retrieve the value through Namespace (for example, 'filename')
    /// </param>
    /// <param name="AShort">
    /// A short flag that starts with '-', such as '-v'. It can be empty.
    /// </param>
    /// <param name="ALong">
    /// A long flag that starts with '--', such as '--verbose'. It can be empty.
    /// </param>
    /// <param name="AHelp">
    /// The help text displayed in the PrintHelp method.
    /// </param>
    /// <param name="ARequired">
    /// The requiredness of the argument. If True and the argument is not specified, it will cause an error.
    /// </param>
    /// <param name="AAction">
    /// Defines the behavior when a flag:
    /// Store - expects a value after the flag (for example, --count 5).
    /// Flag — a boolean flag that is set to True if present (for example, --verbose).
    /// </param>
    /// <param name="AArgType">
    /// The type of the value: AsString, AsInteger, AsBoolean. It is used when reading the value.
    /// </param>
    /// <param name="ADefault">
    /// The default value if the argument is not specified.
    /// </param>
    /// <param name="AChoices">
    /// An array of valid values. If specified, the input is checked for matching one of the elements.
    /// </param>
    function AddArgument(const AName: string; const AShort: string = ''; const ALong: string = ''; const AHelp: string = ''; const ARequired: Boolean = False; const AAction: TArgAction = TArgAction.Store; const AArgType: TArgType = TArgType.AsString; const ADefault: string = ''; const AChoices: TArray<string> = []; const ARequirements: TArray<string> = []): TArgument;
    /// <summary>
    /// Parsing the parameter list. Returns a separate object
    /// </summary>
    function ParseArgs(const ARawArgs: TArray<string>): INamespace;
    /// <summary>
    /// Gives access to the program run parameters (ParamStr/ParamCount)
    /// </summary>
    property ParamArgs: INamespace read GetParamArgs;
    /// <summary>
    /// Displays help on startup parameters
    /// </summary>
    procedure PrintHelp(AReadLn: Boolean = False);
    /// <summary>
    /// Get string help on startup parameters
    /// </summary>
    function GetHelp: string;
  end;

  TArgumentParser = class(TInterfacedObject, IArgumentParser)
  private
    FProgName: string;
    FDescription: string;
    FArgs: TObjectList<TArgument>;
    FParamArgs: INamespace;
    procedure RaiseError(const Msg: string);
    function FindByFlag(const AFlag: string): TArgument;
    function IsFlag(const S: string): Boolean;
    function GetParamArgs: INamespace;
  public
    /// <param name="AProgName">
    /// The name of the executive file for reference
    /// </param>
    constructor Create(const AProgName: string = 'program');
    destructor Destroy; override;
    /// <summary>
    /// Adds a description of the use of the program
    /// </summary>
    procedure SetDescription(const ADesc: string);
    /// <summary>
    /// Adds a new command-line argument to the parser.
    /// </summary>
    /// <param name="AName">
    /// The logical name of the argument, which is then used to retrieve the value through Namespace (for example, 'filename')
    /// </param>
    /// <param name="AShort">
    /// A short flag that starts with '-', such as '-v'. It can be empty.
    /// </param>
    /// <param name="ALong">
    /// A long flag that starts with '--', such as '--verbose'. It can be empty.
    /// </param>
    /// <param name="AHelp">
    /// The help text displayed in the PrintHelp method.
    /// </param>
    /// <param name="ARequired">
    /// The requiredness of the argument. If True and the argument is not specified, it will cause an error.
    /// </param>
    /// <param name="AAction">
    /// Defines the behavior when a flag:
    /// Store - expects a value after the flag (for example, --count 5).
    /// Flag — a boolean flag that is set to True if present (for example, --verbose).
    /// </param>
    /// <param name="AArgType">
    /// The type of the value: AsString, AsInteger, AsBoolean. It is used when reading the value.
    /// </param>
    /// <param name="ADefault">
    /// The default value if the argument is not specified.
    /// </param>
    /// <param name="AChoices">
    /// An array of valid values. If specified, the input is checked for matching one of the elements.
    /// </param>
    function AddArgument(const AName: string; const AShort: string = ''; const ALong: string = ''; const AHelp: string = ''; const ARequired: Boolean = False; const AAction: TArgAction = TArgAction.Store; const AArgType: TArgType = TArgType.AsString; const ADefault: string = ''; const AChoices: TArray<string> = []; const ARequirements: TArray<string> = []): TArgument;
    /// <summary>
    /// Parsing the parameter list. Returns a separate object
    /// </summary>
    function ParseArgs(const ARawArgs: TArray<string>): INamespace;
    /// <summary>
    /// Gives access to the program run parameters (ParamStr/ParamCount)
    /// </summary>
    property ParamArgs: INamespace read GetParamArgs;
    /// <summary>
    /// Displays help on startup parameters
    /// </summary>
    procedure PrintHelp(AReadLn: Boolean = False);
    /// <summary>
    /// Get string help on startup parameters
    /// </summary>
    function GetHelp: string;
  end;

implementation

{ TArgument }

constructor TArgument.Create(const AName: string);
begin
  inherited Create;
  Name := AName;
  ShortName := '';
  LongName := '';
  Help := '';
  Required := False;
  Action := TArgAction.Store;
  ArgType := TArgType.AsString;
  DefaultValue := '';
  Choices := [];
  Requirements := [];
end;

{ TNamespace }

constructor TNamespace.Create;
begin
  inherited Create;
  FValues := TDictionary<string, string>.Create;
end;

destructor TNamespace.Destroy;
begin
  FValues.Free;
  inherited;
end;

procedure TNamespace.SetValue(const AName: string; const AValues: string);
begin
  FValues.AddOrSetValue(AName, AValues);
end;

function TNamespace.Has(const AName: string): Boolean;
begin
  Result := FValues.ContainsKey(AName) and not FValues[AName].IsEmpty;
end;

function TNamespace.GetAsBoolean(const AName: string; ADefault: Boolean): Boolean;
begin
  var Value: string;
  if FValues.TryGetValue(AName, Value) then
  begin
    if Length(Value) = 0 then
      Exit(True);
    Result := (Value <> '0') and (Value.ToLower <> 'false');
  end
  else
    Result := ADefault;
end;

function TNamespace.GetAsInteger(const AName: string; ADefault: Integer): Integer;
begin
  var Value: string;
  if FValues.TryGetValue(AName, Value) and (Length(Value) > 0) then
  try
    Result := Value.ToInteger;
  except
    Result := ADefault;
  end
  else
    Result := ADefault;
end;

function TNamespace.GetAsString(const AName: string; const ADefault: string): string;
begin
  var Value: string;
  if FValues.TryGetValue(AName, Value) and (Length(Value) > 0) then
    Result := Value
  else
    Result := ADefault;
end;

{ TArgumentParser }

constructor TArgumentParser.Create(const AProgName: string);
begin
  inherited Create;
  FParamArgs := nil;
  FProgName := AProgName;
  FDescription := '';
  FArgs := TObjectList<TArgument>.Create;
end;

destructor TArgumentParser.Destroy;
begin
  FArgs.Free;
  FParamArgs := nil;
  inherited;
end;

procedure TArgumentParser.RaiseError(const Msg: string);
begin
  raise EArgumentParserError.CreateFmt('Argument parser error: %s', [Msg]);
end;

procedure TArgumentParser.SetDescription(const ADesc: string);
begin
  FDescription := ADesc;
end;

function TArgumentParser.AddArgument(const AName: string; const AShort: string; const ALong: string; const AHelp: string; const ARequired: Boolean; const AAction: TArgAction; const AArgType: TArgType; const ADefault: string; const AChoices: TArray<string>; const ARequirements: TArray<string>): TArgument;
begin
  Result := TArgument.Create(AName);
  FArgs.Add(Result);
  Result.ShortName := AShort;
  Result.LongName := ALong;
  Result.Help := AHelp;
  Result.Required := ARequired;
  Result.Action := AAction;
  Result.ArgType := AArgType;
  Result.DefaultValue := ADefault;
  Result.Choices := Copy(AChoices);
  Result.Requirements := ARequirements;
end;

function TArgumentParser.IsFlag(const S: string): Boolean;
begin
  Result := (Length(S) > 0) and (S[1] = '-')
end;

function TArgumentParser.FindByFlag(const AFlag: string): TArgument;
begin
  for var Arg in FArgs do
  begin
    if (Arg.ShortName <> '') and (Arg.ShortName = AFlag) then
      Exit(Arg);
    if (Arg.LongName <> '') and (Arg.LongName = AFlag) then
      Exit(Arg);
  end;
  Result := nil;
end;

function TArgumentParser.ParseArgs(const ARawArgs: TArray<string>): INamespace;
begin
  Result := TNamespace.Create;
  try
    for var Arg in FArgs do
      if Arg.DefaultValue <> '' then
        Result.SetValue(Arg.Name, Arg.DefaultValue);

    var i: integer := 0;
    while i < Length(ARawArgs) do
    begin
      var Token := ARawArgs[i];
      if IsFlag(Token) then
      begin
        var Arg := FindByFlag(Token);
        if Arg = nil then
          RaiseError(Format('Unknown option: "%s"', [Token]));

        if Arg.Action = TArgAction.Flag then
        begin
          Result.SetValue(Arg.Name, ''); // presence -> true
          Inc(i);
          Continue;
        end;

        // Store value(s)
        if i + 1 >= Length(ARawArgs) then
          RaiseError(Format('Option "%s" requires a value', [Token]));

        var ArgValue := ARawArgs[i + 1];

        // Validate choices
        if Length(Arg.Choices) > 0 then
        begin
          var Found := False;
          for var Choise in Arg.Choices do
            if Choise = ArgValue then
            begin
              Found := True;
              Break;
            end;
          if not Found then
            RaiseError(Format('Value for "%s" not in choices: "%s"', [Token, string.Join('|', Arg.Choices)]));
        end;

        // Validate type
        case Arg.ArgType of
          TArgType.AsInteger:
            try
              ArgValue.ToInt64;
            except
              RaiseError(Format('Value for %s must be Integer', [Token]));
            end;
          TArgType.AsBoolean:
            begin
              if not TArray.Contains<string>(['true', 'false', '1', '0'], ArgValue.ToLower) then
                RaiseError(Format('Value for "%s" must be Boolean (true|false|1|0)', [Token]));
            end;
        end;

        Result.SetValue(Arg.Name, ArgValue);
        Inc(i, 2);
        Continue;
      end
      else
      begin
        // Positional arguments: match against first argument with no flags
        var Found := False;
        for var Arg in FArgs do
          if Arg.ShortName.IsEmpty and Arg.LongName.IsEmpty then
            if not Result.Has(Arg.Name) then
            begin
              Result.SetValue(Arg.Name, Token);
              Found := True;
              Break;
            end;
        if not Found then
          RaiseError(Format('Unexpected positional argument: "%s"', [Token]));
        Inc(i);
      end;
    end;

    // Check required
    for var Arg in FArgs do
      if Arg.Required and not Result.Has(Arg.Name) then
        RaiseError(Format('Argument required: "%s"', [Arg.Name]));

    // For flags with action Flag that were not set, put false
    for var Arg in FArgs do
      if (Arg.Action = TArgAction.Flag) and not Result.Has(Arg.Name) then
        Result.SetValue(Arg.Name, '0');

    // Check requirements
    for var Arg in FArgs do
      for var Req in Arg.Requirements do
        if not Result.Has(Req) then
          RaiseError(Format('Using argument "%s" requires the presence of argument "%s".', [Arg.Name, Req]));
  except
    Result := nil;
    raise;
  end;
end;

function TArgumentParser.GetHelp: string;
begin
  var Builder := TStringBuilder.Create;
  try
    Builder.AppendFormat('Usage: %s [options]', [FProgName]);
    Builder.AppendLine;
    if FDescription <> '' then
      Builder.AppendLine(FDescription);
    Builder.AppendLine;
    Builder.AppendLine('Options:');
    for var Arg in FArgs do
    begin
      var Flags := '';
      if Arg.ShortName <> '' then
        Flags := Flags + Arg.ShortName;
      if Arg.LongName <> '' then
      begin
        if Flags <> '' then
          Flags := Flags + ', ';
        Flags := Flags + Arg.LongName;
      end;
      if Flags = '' then
        Flags := Arg.Name;
      var Help := Arg.Help;
      if Length(Arg.Choices) > 0 then
        Help := Help + ' (' + string.Join('|', Arg.Choices) + ')';
      Builder.AppendFormat('  %-20s %s', [Flags, Help]);
      Builder.AppendLine;
    end;
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

function TArgumentParser.GetParamArgs: INamespace;
begin
  if not Assigned(FParamArgs) then
  begin
    var Args: TArray<string>;
    for var i := 1 to ParamCount do
      Args := Args + [ParamStr(i)];
    FParamArgs := ParseArgs(Args);
  end;
  Result := FParamArgs;
end;

procedure TArgumentParser.PrintHelp(AReadLn: Boolean = False);
begin
  Writeln(GetHelp);
  if AReadLn then
    Readln;
end;

end.

