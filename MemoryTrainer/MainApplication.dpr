program MainApplication;

{$APPTYPE CONSOLE}
{$R *.res}

uses
    System.SysUtils,
    Windows,
    System.StrUtils;

const
    WARNING_COLOR = $6F;
    INCORRECT_COLOR = $4F;
    CORRECT_COLOR = $2F;

type
    TDictionary = array [1 .. 4] of array of string;
    TSetOfWords = array [1 .. 8] of string;

    // ****************************************
    // PROCEDURES' AND FUNCTIONS' PROTOTYPES
    // ****************************************
    // Console handling functions and procedures
procedure ColourOneLine(relPosition: integer; colour: LongWord); forward;
procedure ClearScreen(keepFirstLine: boolean = false); forward;
procedure DeleteOneLine(relPosition: integer); forward;
procedure MoveCursor(relPosition: integer); forward;
procedure SwitchConsoleMode; forward;
procedure NewLevelAnimation; forward;
// work with files functions and procedures
procedure LoadDictionary(var words: TDictionary); forward;
// string handling functions
function RandomArr(words: TDictionary; numberOfWords: byte)
  : TSetOfWords; forward;
procedure TrimString(var str: string); forward;
// Check of validation of input functions and procedures
function IsValid(checkStr: string): byte; forward;
function IsValidS1(stageStr, userStr: string): boolean; forward;
function IsValidS2(stageArr: TSetOfWords; numOfWords: byte; userStr: string)
  : boolean; forward;
function IsValidS3(stageArr: TSetOfWords; numOfWords: byte; userStr: string)
  : boolean; forward;
function IsValidS4(stageArr: TSetOfWords; numOfWords: byte; userStr: string)
  : boolean; forward;
function IsValidS5(stageArr: TSetOfWords; numOfWords: byte; userStr: string)
  : boolean; forward;
// Gaming functions and procedures
function SetDifficultyLevel(): integer; forward;
procedure Stage1(words: TDictionary; difficulty: integer); forward;
procedure Stage2(words: TDictionary; difficulty: integer); forward;
procedure Stage3(words: TDictionary; difficulty: integer); forward;
procedure Stage4(words: TDictionary; difficulty: integer); forward;
procedure Stage5(words: TDictionary; difficulty: integer); forward;
procedure StartGame(); forward;

// ****************************************
// PROCEDURES AND FUNCTIONS
// ***************************************
procedure LoadDictionary;
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

        // Чтение первой строки, где хранится количество слов, приведение ее в тип integer и установка длины динамического массива
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

procedure NewLevelAnimation;
begin
    ClearScreen;
    writeln('╔═══════════════════════════════════════════════════════════════════════════════════════════════════╗');
    writeln('║     ╔═      ╗  ╔══════  ╔          ╗     ╗         ╔══════  ╔       ╗  ╔══════  ╗        ╔╦╦╗     ║');
    writeln('║     ║ ╚     ║  ║        ║          ║     ║         ║        ║       ║  ║        ║        ╠╬╬╣     ║');
    writeln('║     ║  ╚    ║  ╠═════   ╚          ╝     ║         ╠═════   ╚       ╝  ╠═════   ║        ╠╬╬╣     ║');
    writeln('║     ║   ╚   ║  ║         ║   ╔╗   ║      ║         ║         ║     ║   ║        ║         ╠╣      ║');
    writeln('║     ║    ╚  ║  ║         ╚  ╔  ╗  ╝      ║         ║          ║   ║    ║        ║         ╚╝      ║');
    writeln('║     ╚     ╚═╝  ╚══════    ╚═    ═╝       ╚══════╝  ╚══════     ╚═╝     ╚══════  ╚══════╝  ╚╝      ║');
    writeln('╚═══════════════════════════════════════════════════════════════════════════════════════════════════╝');
    Sleep(1500);
    ClearScreen;
end;

procedure ClearScreen;
var
    ConsoleSize, NumWritten: LongWord;
    Origin: COORD;
    ScreenBufferInfo: CONSOLE_SCREEN_BUFFER_INFO;
    hStdOut: THandle;
begin
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
    GetConsoleScreenBufferInfo(hStdOut, ScreenBufferInfo);

    Origin.x := 0;
    if keepFirstLine then
    begin
        ConsoleSize := ScreenBufferInfo.dwSize.x *
          (ScreenBufferInfo.dwSize.y - 1);
        Origin.y := 1;
    end
    else
    begin
        ConsoleSize := ScreenBufferInfo.dwSize.x * ScreenBufferInfo.dwSize.y;
        Origin.y := 0;
    end;

    FillConsoleOutputCharacter(hStdOut, ' ', ConsoleSize, Origin, NumWritten);
    FillConsoleOutputAttribute(hStdOut, ScreenBufferInfo.wAttributes,
      ConsoleSize, Origin, NumWritten);
    SetConsoleCursorPosition(hStdOut, Origin);
end;

function SetDifficultyLevel;
var
    inputDifLvl: string;
    repeatInputFlag: boolean;
    difLvl: integer;
begin
    repeatInputFlag := false;
    difLvl := 0;
    repeat
        ClearScreen();
        if repeatInputFlag then
        begin
            writeln('Введен несуществующий уровень сложности! Попробуйте еще раз.');
            ColourOneLine(-1, INCORRECT_COLOR);
        end;

        writeln('Введите число для выбора уровня сложности игры: ');
        writeln('1. Нормальный');
        writeln('2. Ты не пройдешь!');
        readln(inputDifLvl);
        // Compare in ASCII code to prevent from text input and errors linked with this fact
        if (Length(inputDifLvl) = 1) and
          ((Ord(inputDifLvl[1]) = 49) or (Ord(inputDifLvl[1]) = 50)) then
        begin
            difLvl := StrToInt(inputDifLvl);
            repeatInputFlag := false;
        end
        else
            repeatInputFlag := True;
    until not repeatInputFlag;
    Result := difLvl;
end;

procedure DeleteOneLine;
var
    ConsoleSize, NumWritten: LongWord;
    Origin, Starting: COORD;
    ScreenBufferInfo: CONSOLE_SCREEN_BUFFER_INFO;
    hStdOut: THandle;
begin
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
    GetConsoleScreenBufferInfo(hStdOut, ScreenBufferInfo);

    Starting.x := ScreenBufferInfo.dwCursorPosition.x;
    Starting.y := ScreenBufferInfo.dwCursorPosition.y;

    ConsoleSize := ScreenBufferInfo.dwSize.x;
    Origin.x := 0;
    Origin.y := ScreenBufferInfo.dwCursorPosition.y + relPosition;

    FillConsoleOutputCharacter(hStdOut, ' ', ConsoleSize, Origin, NumWritten);
    FillConsoleOutputAttribute(hStdOut, ScreenBufferInfo.wAttributes,
      ConsoleSize, Origin, NumWritten);
    SetConsoleCursorPosition(hStdOut, Starting);
end;

procedure MoveCursor;
var
    Origin: COORD;
    ScreenBufferInfo: CONSOLE_SCREEN_BUFFER_INFO;
    hStdOut: THandle;
begin
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
    GetConsoleScreenBufferInfo(hStdOut, ScreenBufferInfo);

    Origin.x := 0;
    Origin.y := ScreenBufferInfo.dwCursorPosition.y + relPosition;

    SetConsoleCursorPosition(hStdOut, Origin);
end;

procedure SwitchConsoleMode;
var
    hStdIn: THandle;
    originConsoleMode: cardinal;
begin
    hStdIn := GetStdHandle(STD_INPUT_HANDLE);
    GetConsoleMode(hStdIn, originConsoleMode);

    if originConsoleMode and (ENABLE_ECHO_INPUT or ENABLE_QUICK_EDIT_MODE) <> 0
    then
    begin
        originConsoleMode := originConsoleMode xor (ENABLE_ECHO_INPUT or
          ENABLE_QUICK_EDIT_MODE);
    end
    else
    begin
        originConsoleMode := originConsoleMode or
          (ENABLE_ECHO_INPUT or ENABLE_QUICK_EDIT_MODE);
        FlushConsoleInputBuffer(hStdIn);
    end;

    SetConsoleMode(hStdIn, originConsoleMode);
end;

procedure ColourOneLine;
var
    ConsoleSize, NumWritten: LongWord;
    Origin, Starting: COORD;
    ScreenBufferInfo: CONSOLE_SCREEN_BUFFER_INFO;
    hStdOut: THandle;
begin
    hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
    GetConsoleScreenBufferInfo(hStdOut, ScreenBufferInfo);

    Starting.x := ScreenBufferInfo.dwCursorPosition.x;
    Starting.y := ScreenBufferInfo.dwCursorPosition.y;

    ConsoleSize := ScreenBufferInfo.dwSize.x;
    Origin.x := 0;
    Origin.y := ScreenBufferInfo.dwCursorPosition.y + relPosition;

    FillConsoleOutputAttribute(hStdOut, colour, ConsoleSize, Origin,
      NumWritten);
    SetConsoleCursorPosition(hStdOut, Starting);
end;

procedure TrimString;
const
    doubleSpace = '  ';
begin
    str := Trim(str);
    while Pos(doubleSpace, str) <> 0 do
        Delete(str, Pos(doubleSpace, str), 1);
end;

function IsValid;
var
    i, number: integer;
    flag: boolean;
    value: byte;
begin
    flag := True;
    value := $00;
    if Length(checkStr) = 0 then
        value := $01
    else
    begin
        for i := 1 to Length(checkStr) do
        begin
            number := Ord(checkStr[i]);
            if not(((number >= 1040) and (number <= 1071)) or (number = 32))
            then
                flag := false;
        end;
        if not flag then
            value := $10
        else
            value := $00;
    end;
    Result := value;
end;

function RandomArr;
var
    arrTemp: TSetOfWords;
    rIndex: word;
begin
    Randomize;
    for var i := 1 to 8 do
        arrTemp[i] := '';
    for var j := 1 to numberOfWords do
    begin
        rIndex := random(4) + 1;
        arrTemp[j] := words[rIndex][random(Length(words[rIndex]))];
    end;
    Result := arrTemp;
end;

function IsValidS1;
var flag: boolean;
begin
    stageStr := ReverseString(stageStr);
    if stageStr = userStr then
        flag := True
    else
        flag := false;
    Result := flag;
end;

function IsValidS2;
const
    space = ' ';
var
    checkWord: string;
    i: byte;
    flag: boolean;
begin
    userStr := Concat(space, userStr, space);

    flag := True;
    i := 1;
    while flag and (i <= numOfWords) do
    begin
        checkWord := stageArr[i];
        checkWord := Concat(space, checkWord, space);
        if Pos(checkWord, userStr) = 0 then
            flag := false
        else
            Delete(userStr, Pos(checkWord, userStr), Length(checkWord) - 1);
        inc(i);
    end;
    Result := flag;
end;

function IsValidS3;
const
    space = ' ';
var
    checkString: string;
    flag: boolean;
begin
    checkString := String.Join(space, stageArr, 0, numOfWords);
    if checkString = userStr then
        flag := True
    else
        flag := False;
    Result := flag;
end;

function IsValidS4;
const
    space = ' ';
var
    i: byte;
    checkWord: string;
    flag: boolean;
begin
    flag := True;
    i := numOfWords;
    while i >= 1 do
    begin
        checkWord := Concat(checkWord, ' ', stageArr[i]);
        dec(i);
    end;
    Delete(checkWord, 1, 1);

    if userStr <> checkWord then
        flag := False;
    Result := flag;

end;

function IsValidS5;
const
    space = ' ';
var
    i: byte;
    checkWord: string;
    flag: boolean;
begin
    for i := 1 to numOfWords do
        stageArr[i] := ReverseString(stageArr[i]);
    userStr := Concat(space, userStr, space);

    flag := True;
    i := 1;
    while flag and (i <= numOfWords) do
    begin
        checkWord := stageArr[i];
        checkWord := Concat(space, checkWord, space);
        if Pos(checkWord, userStr) = 0 then
            flag := False
        else
            Delete(userStr, Pos(checkWord, userStr), Length(checkWord) - 1);
        inc(i);
    end;
    Result := flag;

end;

procedure Stage1;
var
    level, counter, maxLevel, sleepTime: integer;
    showLevelDecrease: integer;
    stageStr, inputStr: string;
begin
    Randomize;
    stageStr := '';
    inputStr := '';
    if difficulty = 1 then
    begin
        showLevelDecrease := 0;
        level := 1;
        maxLevel := 2;
        sleepTime := 3000;
    end
    else
    begin
        showLevelDecrease := 2;
        level := 3;
        maxLevel := 4;
        sleepTime := 2000;
    end;
    while level <= maxLevel do
    begin
        counter := 0;
        writeln('<<<< Этап 1. Уровень: ', level - showLevelDecrease, ' >>>>');

        while counter < 3 do
        begin
            stageStr := words[level][random(Length(words[level]))];

            SwitchConsoleMode;
            writeln(stageStr);
            Sleep(sleepTime);
            ClearScreen(True);
            SwitchConsoleMode;

            writeln('Введите перевёрнутое слово:');

            repeat
                readln(inputStr);
                TrimString(inputStr);
                inputStr := AnsiUpperCase(inputStr);
                DeleteOneLine(0);
                case IsValid(inputStr) of
                    $01:
                        begin
                            writeln('Пустая строка. Повторите ввод.');
                            ColourOneLine(-1, WARNING_COLOR);
                            DeleteOneLine(-2);
                            MoveCursor(-2);
                        end;
                    $10:
                        begin
                            writeln('Неправильный язык. Повторите ввод.');
                            ColourOneLine(-1, WARNING_COLOR);
                            DeleteOneLine(-2);
                            MoveCursor(-2);
                        end;
                end;
            until IsValid(inputStr) = $00;

            if IsValidS1(stageStr, inputStr) = false then
            begin
                ColourOneLine(-1, INCORRECT_COLOR);
                counter := 0;
                writeln('╔═════════════════════════════════════╗');
                writeln('║  Прогресс: ', counter:1, ' из 3.                  ║');
            end
            else
            begin
                ColourOneLine(-1, CORRECT_COLOR);
                inc(counter);
                writeln('╔═════════════════════════════════════╗');
                writeln('║  Прогресс: ', counter:1, ' из 3.                  ║');
            end;

            writeln('║  Нажмите Enter, чтобы продолжить.   ║');
            writeln('╚═════════════════════════════════════╝');
            readln;
            ClearScreen(True);
        end;

        inc(level);
        NewLevelAnimation;
    end;

    writeln('Вы прошли Этап 1! Поздравляем!');
    writeln('Нажмите Enter, чтобы перейти к следующему этапу.');
    readln;
    ClearScreen(false);
end;

procedure Stage2;
var
    level, maxLevel, sleepTime, counter: integer;
    showLevelDecrease: integer;
    inputStr: string;
    stageArr: TSetOfWords;
begin
    inputStr := '';
    if difficulty = 1 then
    begin
        showLevelDecrease := 0;
        level := 1;
        maxLevel := 2;
        sleepTime := 5000;
    end
    else
    begin
        showLevelDecrease := 2;
        level := 3;
        maxLevel := 4;
        sleepTime := 4000;
    end;

    while level <= maxLevel do
    begin
        counter := 0;
        writeln('<<<< Этап 2. Уровень: ', level - showLevelDecrease, ' >>>>');

        while counter < 3 do
        begin
            stageArr := RandomArr(words, level + 4);

            SwitchConsoleMode;
            write(stageArr[1]);
            for var i := 2 to level + 4 do
                write(' ', stageArr[i]);
            writeln;
            Sleep(sleepTime);
            ClearScreen(True);
            SwitchConsoleMode;

            writeln('Введите словa в любом порядке:');

            repeat
                readln(inputStr);
                TrimString(inputStr);
                inputStr := AnsiUpperCase(inputStr);
                DeleteOneLine(0);
                case IsValid(inputStr) of
                    $01:
                        begin
                            writeln('Пустая строка. Повторите ввод.');
                            ColourOneLine(-1, WARNING_COLOR);
                            DeleteOneLine(-2);
                            MoveCursor(-2);
                        end;
                    $10:
                        begin
                            writeln('Неправильный язык. Повторите ввод.');
                            ColourOneLine(-1, WARNING_COLOR);
                            DeleteOneLine(-2);
                            MoveCursor(-2);
                        end;
                end;
            until IsValid(inputStr) = $00;

            if IsValidS2(stageArr, level + 4, inputStr) = false then
            begin
                ColourOneLine(-1, INCORRECT_COLOR);
                counter := 0;
                writeln('╔═════════════════════════════════════╗');
                writeln('║  Прогресс: ', counter:1, ' из 3.                  ║');
            end
            else
            begin
                ColourOneLine(-1, CORRECT_COLOR);
                inc(counter);
                writeln('╔═════════════════════════════════════╗');
                writeln('║  Прогресс: ', counter:1, ' из 3.                  ║');
            end;

            writeln('║  Нажмите Enter, чтобы продолжить.   ║');
            writeln('╚═════════════════════════════════════╝');
            readln;
            ClearScreen(True);
        end;

        inc(level);
        NewLevelAnimation;
    end;

    writeln('Вы прошли Этап 2! Поздравляем!');
    writeln('Нажмите Enter, чтобы перейти к следующему этапу.');
    readln;
    ClearScreen(false);
end;

procedure Stage3;
var
    level, counter, maxLevel, sleepTime: integer;
    showLevelDecrease: integer;
    inputStr: string;
    stageArr: TSetOfWords;
begin
    inputStr := '';
    if difficulty = 1 then
    begin
        showLevelDecrease := 0;
        level := 1;
        maxLevel := 2;
        sleepTime := 5000;
    end
    else
    begin
        showLevelDecrease := 2;
        level := 3;
        maxLevel := 4;
        sleepTime := 4000;
    end;
    while level <= maxLevel do
    begin
        counter := 0;
        writeln('<<<< Этап 3. Уровень: ', level - showLevelDecrease, ' >>>>');

        while counter < 3 do
        begin
            stageArr := RandomArr(words, level + 4);

            SwitchConsoleMode;
            write(stageArr[1]);
            for var i := 2 to level + 4 do
                write(' ', stageArr[i]);
            writeln;
            Sleep(sleepTime);
            ClearScreen(True);
            SwitchConsoleMode;

            writeln('Введите словa в строгом порядке:');

            repeat
                readln(inputStr);
                TrimString(inputStr);
                inputStr := AnsiUpperCase(inputStr);
                DeleteOneLine(0);
                case IsValid(inputStr) of
                    $01:
                        begin
                            writeln('Пустая строка. Повторите ввод.');
                            ColourOneLine(-1, WARNING_COLOR);
                            DeleteOneLine(-2);
                            MoveCursor(-2);
                        end;
                    $10:
                        begin
                            writeln('Неправильный язык. Повторите ввод.');
                            ColourOneLine(-1, WARNING_COLOR);
                            DeleteOneLine(-2);
                            MoveCursor(-2);
                        end;
                end;
            until IsValid(inputStr) = $00;

            if IsValidS3(stageArr, level + 4, inputStr) = false then
            begin
                ColourOneLine(-1, INCORRECT_COLOR);
                counter := 0;
                writeln('╔═════════════════════════════════════╗');
                writeln('║  Прогресс: ', counter:1, ' из 3.                  ║');
            end
            else
            begin
                ColourOneLine(-1, CORRECT_COLOR);
                inc(counter);
                writeln('╔═════════════════════════════════════╗');
                writeln('║  Прогресс: ', counter:1, ' из 3.                  ║');
            end;

            writeln('║  Нажмите Enter, чтобы продолжить.   ║');
            writeln('╚═════════════════════════════════════╝');
            readln;
            ClearScreen(True);
        end;

        inc(level);
        NewLevelAnimation;
    end;

    writeln('Вы прошли Этап 3! Поздравляем!');
    writeln('Нажмите Enter, чтобы перейти к следующему этапу.');
    readln;
    ClearScreen(false);
end;

procedure Stage4;
var
    level, counter, maxLevel, sleepTime: integer;
    showLevelDecrease: integer;
    inputStr: string;
    stageArr: TSetOfWords;
begin
    inputStr := '';
    if difficulty = 1 then
    begin
        showLevelDecrease := 0;
        level := 1;
        maxLevel := 2;
        sleepTime := 5000;
    end
    else
    begin
        showLevelDecrease := 2;
        level := 3;
        maxLevel := 4;
        sleepTime := 4000;
    end;

    while level <= maxLevel do
    begin
        counter := 0;
        writeln('<<<< Этап 4. Уровень: ', level - showLevelDecrease, ' >>>>');

        while counter < 3 do
        begin
            stageArr := RandomArr(words, level + 4);

            SwitchConsoleMode;
            write(stageArr[1]);
            for var i := 2 to level + 4 do
                write(' ', stageArr[i]);
            writeln;
            Sleep(sleepTime);
            ClearScreen(True);
            SwitchConsoleMode;

            writeln('Введите предложение в обратном порядке:');

            repeat
                readln(inputStr);
                TrimString(inputStr);
                inputStr := AnsiUpperCase(inputStr);
                DeleteOneLine(0);
                case IsValid(inputStr) of
                    $01:
                        begin
                            writeln('Пустая строка. Повторите ввод.');
                            ColourOneLine(-1, WARNING_COLOR);
                            DeleteOneLine(-2);
                            MoveCursor(-2);
                        end;
                    $10:
                        begin
                            writeln('Неправильный язык. Повторите ввод.');
                            ColourOneLine(-1, WARNING_COLOR);
                            DeleteOneLine(-2);
                            MoveCursor(-2);
                        end;
                end;
            until IsValid(inputStr) = $00;

            if IsValidS4(stageArr, level + 4, inputStr) = false then
            begin
                ColourOneLine(-1, INCORRECT_COLOR);
                counter := 0;
                writeln('╔═════════════════════════════════════╗');
                writeln('║  Прогресс: ', counter:1, ' из 3.                  ║');
            end
            else
            begin
                ColourOneLine(-1, CORRECT_COLOR);
                inc(counter);
                writeln('╔═════════════════════════════════════╗');
                writeln('║  Прогресс: ', counter:1, ' из 3.                  ║');
            end;

            writeln('║  Нажмите Enter, чтобы продолжить.   ║');
            writeln('╚═════════════════════════════════════╝');
            readln;
            ClearScreen(True);
        end;

        inc(level);
        NewLevelAnimation;
    end;

    writeln('Вы прошли Этап 4! Поздравляем!');
    writeln('Нажмите Enter, чтобы перейти к следующему этапу.');
    readln;
    ClearScreen(false);
end;

procedure Stage5;
var
    level, counter, maxLevel, sleepTime: integer;
    showLevelDecrease: integer;
    inputStr: string;
    stageArr: TSetOfWords;
begin
    inputStr := '';
    if difficulty = 1 then
    begin
        showLevelDecrease := 0;
        level := 1;
        maxLevel := 2;
        sleepTime := 5000;
    end
    else
    begin
        showLevelDecrease := 2;
        level := 3;
        maxLevel := 4;
        sleepTime := 4000;
    end;

    while level <= maxLevel do
    begin
        counter := 0;
        writeln('<<<< Этап 5. Уровень: ', level - showLevelDecrease, ' >>>>');

        while counter < 3 do
        begin
            stageArr := RandomArr(words, level + 4);

            SwitchConsoleMode;
            write(stageArr[1]);
            for var i := 2 to level + 4 do
                write(' ', stageArr[i]);
            writeln;
            Sleep(sleepTime);
            ClearScreen(True);
            SwitchConsoleMode;

            writeln('Введите перевёрнутые словa в любом порядке:');

            repeat
                readln(inputStr);
                TrimString(inputStr);
                inputStr := AnsiUpperCase(inputStr);
                DeleteOneLine(0);
                case IsValid(inputStr) of
                    $01:
                        begin
                            writeln('Пустая строка. Повторите ввод.');
                            ColourOneLine(-1, WARNING_COLOR);
                            DeleteOneLine(-2);
                            MoveCursor(-2);
                        end;
                    $10:
                        begin
                            writeln('Неправильный язык. Повторите ввод.');
                            ColourOneLine(-1, WARNING_COLOR);
                            DeleteOneLine(-2);
                            MoveCursor(-2);
                        end;
                end;
            until IsValid(inputStr) = $00;

            if IsValidS5(stageArr, level + 4, inputStr) = false then
            begin
                ColourOneLine(-1, INCORRECT_COLOR);
                counter := 0;
                writeln('╔═════════════════════════════════════╗');
                writeln('║  Прогресс: ', counter:1, ' из 3.                  ║');
            end
            else
            begin
                ColourOneLine(-1, CORRECT_COLOR);
                inc(counter);
                writeln('╔═════════════════════════════════════╗');
                writeln('║  Прогресс: ', counter:1, ' из 3.                  ║');
            end;

            writeln('║  Нажмите Enter, чтобы продолжить.   ║');
            writeln('╚═════════════════════════════════════╝');
            readln;
            ClearScreen(True);
        end;

        inc(level);
        NewLevelAnimation;
    end;

    writeln('Вы прошли Этап 5! Поздравляем!');
    writeln('Нажмите Enter, чтобы перейти к следующему этапу.');
    readln;
    ClearScreen(false);
end;

procedure StartGame;
var
    words: TDictionary;
    difficulty: integer;
begin
    writeln('Добро пожаловать в приложение Memory Trainer!');
    writeln('Нажмите Enter, чтобы начать.');
    readln;
    difficulty := SetDifficultyLevel;
    ClearScreen(false);
    LoadDictionary(words);
    Stage1(words, difficulty);
    Stage2(words, difficulty);
    Stage3(words, difficulty);
    Stage4(words, difficulty);
    Stage5(words, difficulty);
    writeln('Спасибо, что воспользовались нашим приложением!');
    writeln('Нажмите Enter, чтобы выйти.');
    readln;
end;

begin
    StartGame;

end.
