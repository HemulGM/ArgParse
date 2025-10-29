# ArgParse
Delphi argparse

![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.3+-yellow)

- Working with unnamed arguments.
- Specifying a short and a long parameter.
- Requiring a parameter to be specified.
- Flag parameters.
- Checking parameter types (number, floating-point number, boolean).
- Specifying available values.
- The ability to specify dependent arguments.

Example
```pascal
program ArgParseExample;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  ArgParse in '..\ArgParse.pas';

begin
  var Parser: IArgumentParser := TArgumentParser.Create('ArgParseExample.exe');
  try
    Parser.SetDescription('An example of using argparse for Delphi.');

    // Add args
    Parser.AddArgument('filename', '', '', 'The name of the file to process', True, TArgAction.Store, TArgType.AsString, '', [], ['output']);
    Parser.AddArgument('count', '-c', '--count', 'Number of repetitions', False, TArgAction.Store, TArgType.AsInteger, '1');
    Parser.AddArgument('mode', '-m', '--mode', 'Operating mode', False, TArgAction.Store, TArgType.AsString, 'safe', ['fast', 'safe']);
    Parser.AddArgument('verbose', '-v', '--verbose', 'Detailed output', False, TArgAction.Flag, TArgType.AsBoolean);
    Parser.AddArgument('output', '-o', '--output', 'Output path', False, TArgAction.Store, TArgType.AsString, '', [], []);
    Parser.AddArgument('size', '-s', '--size', 'Scale', False, TArgAction.Store, TArgType.AsFloat, '1');

    // Parse param args
    var Args := Parser.ParamArgs;

    var filename := Args.GetAsString('filename');
    var count := Args.GetAsInteger('count');
    var verbose := Args.GetAsBoolean('verbose');
    var mode := Args.GetAsString('mode');
    var size := Args.GetAsFloat('size');

    // Using example
    if verbose then
      Writeln('File: ', filename, ', Repeats: ', count, ', Mode: ', mode, ', Size: ', size);

    for var i := 1 to count do
      Writeln(Format('Processing %d/%d file %s in mode %s...', [i, count, filename, mode]));

    //raise Exception.Create('Test error');
  except
    on E: EArgumentParserError do
    begin
      Writeln(E.Message);
      // Print help
      Parser.PrintHelp(True);
    end;
    on E: Exception do
    begin
      Writeln(E.Message);
      readln;
    end;
  end;
  readln;
end.
```

Output
```
ArgumentParser error: Argument required: filename
Usage: example [options]
An example of using argparse for Delphi.

Options:
  filename             The name of the file to process
  -c, --count          Number of repetitions
  -m, --mode           Operating mode (fast|safe)
  -v, --verbose        Detailed output
```
