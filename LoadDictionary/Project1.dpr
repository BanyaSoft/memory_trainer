﻿program Project1;

{$APPTYPE CONSOLE}
{$R *.res}

uses
    System.SysUtils;

type
    TDictionary = array [1 .. 4] of array of AnsiString;

procedure LoadDictionary(var words: TDictionary);
var
    fileVar: TextFile;
    files: array [1 .. 4] of string;
    count: integer;
    i, k: integer;
    line: string;
begin
    // Инициализация в процедурах запрещена, поэтому присваивание в основном блоке
    files[1] := '..\..\..\dictionaries\words5.txt';
    files[2] := '..\..\..\dictionaries\words6.txt';
    files[3] := '..\..\..\dictionaries\words7.txt';
    files[4] := '..\..\..\dictionaries\words8.txt';

    for i := 1 to 4 do
    begin
        // Открытие файла в режиме чтения
        AssignFile(fileVar, files[i]);
        Reset(fileVar);

        // Чтение первой строки, где хранится число слов, приведение ее в тип integer и установка длины динамического массива
        readln(fileVar, line);
        count := StrToInt(line);
        SetLength(words[i], count);
        k := 0;

        // Построчное чтение и запись
        while (not EOF(fileVar)) do
        begin
            readln(fileVar, line);
            words[i][k] := line;
            inc(k);
        end;
        CloseFile(fileVar);
    end;

end;

var
    words: TDictionary;

begin
    LoadDictionary(words);
    // writeln('The path of the current executable is: ' + ExtractFilePath(ParamStr(0)));

    readln;
end.