program ArgParseExample;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  ArgParse in '..\ArgParse.pas';

begin
  var Parser := TArgumentParser.Create('ArgParseExample.exe');
  try
    Parser.SetDescription('An example of using argparse for Delphi.');

    // Add args
    Parser.AddArgument('filename', '', '', 'The name of the file to process', True);
    Parser.AddArgument('count', '-c', '--count', 'Number of repetitions', False, TArgAction.Store, TArgType.AsInteger, '1');
    Parser.AddArgument('mode', '-m', '--mode', 'Operating mode', False, TArgAction.Store, TArgType.AsString, 'safe', ['fast', 'safe']);
    Parser.AddArgument('verbose', '-v', '--verbose', 'Detailed output', False, TArgAction.Flag, TArgType.AsBoolean);

    // Parse param args
    var Args := Parser.ParamArgs;

    var filename := Args.GetAsString('filename');
    var count := Args.GetAsInteger('count');
    var verbose := Args.GetAsBoolean('verbose');
    var mode := Args.GetAsString('mode');

    // Using example
    if verbose then
      Writeln('File: ', filename, ', Repeats: ', count, ', Mode: ', mode);

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
  Parser.Free;
end.

