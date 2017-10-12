program SameGame;

const
    MAX_COLUMNS = 26;
    MAX_LINES = 20;

{kazda komorka tablicy jest rekordem,
* przechowuje przechowywany blok, i wartosci logiczne,
* empty mowi, czy mamy wypisywac zawartosc, czy nie,
* bo zostala usunieta, a counted sprawdza, czy komorka zostala juz
* sprawdzona przy szukaniu maksymalnych obszarow. Computer i user 
* mowi, ktory gracz moze usuwac dana komorke}
type tCellInBoard = record
        content :String;
        counted,empty,computer,user :Boolean;
    end;

type tBoard = array[1..MAX_LINES,1..MAX_COLUMNS] of tCellInBoard;

type tPair = record
        k,w : Integer;
    end;

var columns,lines,p1,p2,f1,f2 :Integer;
    s,s1,s2 :String;
    B :tBoard;
    number :Longint; //zmienna uzywana do generowania liczb losowych
    turn :Integer; //wartosc 1 oznacza, ze jest tura gracza, wartosc 2, ze komputera

{wczytanie danych: wymiary tablicy,
* kto zaczyna i liczby sluzacej do generowania tablicy}
procedure ReadBoard;
begin
    read(columns);
    read(lines);
    read(number);
    read(turn);
    readln;
    if turn = 1 then
    begin
        readln(s1);
        readln(s2);
        s := s1 + s2;
    end
    else begin
        readln(s2);
        readln(s1);
        s := s2 + s1;
    end;
end;

{procedura anulujaca 'policzenia' w tablicy}
procedure NotCounted;
var i,j :Integer;
begin
    for i := 1 to lines do
    begin
        for j := 1 to columns do B[i,j].counted := false;
    end;
end;

{wypisanie aktualnego stanu tablicy}
procedure WriteBoard(var B :tBoard);
var i,j :Integer;
    c :Char;
begin
    write('  +');
    for i := 1 to columns do write('--');
    write('-+');
    for i := 1 to lines do
    begin
        writeln;
        write((lines + 1 -i) mod 10,' |');
        for j := 1 to columns do
        begin
            if not B[i,j].empty then write(' ',B[i,j].content)
            else write('  ');
        end;
        write(' |');
    end;
    writeln;
    write('  +');
    for i := 1 to columns do write('--');
    writeln('-+');
    write('   ');
    for c := 'a' to chr(ord('a') + columns - 1) do write(' ',c);
end;

{generowanie tablicy}
procedure GenerateBoard;

{generowanie liczb pseudolosowych}
procedure glp(var x : Longint);
const
    M = MAXLONGINT;
    A = 7 * 7 * 7 * 7 * 7;
    Q = M div A;
    R = M mod A;
begin
    assert(M = 2147483647); {2^31 - 1}
    assert(A = 16807);
    assert(R < Q);
    x := A * (x mod Q) - R * (x div Q);
    if x < 0 then x := x + M;
end;

var i,j,k :Integer;
begin
    ReadBoard;
    for j := 1 to columns do
    begin
        for i := lines downto 1 do
        begin
            glp(number);
            B[i,j].empty := false;
            B[i,j].counted := false;
            B[i,j].content := s[1 + (number mod length(s))];
            B[i,j].user := false;
            B[i,j].computer := false;
            {zaznaczenie komorek, ktore gracze moga usuwac}
            for k := 1 to length(s1) do
            begin
                if B[i,j].content = s1[k] then B[i,j].user := true;
            end;
            for k := 1 to length(s2) do
            begin
                if B[i,j].content = s2[k] then B[i,j].computer := true;
            end;
        end;
    end;
    WriteBoard(B);
end;

{funkcja zwracajaca wielkosc obszaru, w zaleznosci od podanych 
* wspolrzednych (i,j)}
function MaxArea(i,j :Integer) :Integer;
begin
    MaxArea := 1;
    {zapamietanie wspolrzednych pierwszych w porzadku kanonicznym}
    if j < f2 then 
    begin
        f1 := i;
        f2 := j;
    end
    else if j = f2 then
    begin
        if i > f1 then 
        begin
             f1 := i;
             f2 := j;
        end;
    end;
    B[i,j].counted := true;
    if (j < columns) then
    begin
        if (B[i,j].content = B[i,j + 1].content) and (not B[i,j + 1].counted) and (not B[i,j + 1].empty) then
            MaxArea += MaxArea(i,j + 1);
    end;
    if (i > 1) then
    begin 
        if (B[i,j].content = B[i - 1,j].content) and (not B[i - 1,j].counted) and (not B[i - 1,j].empty) then
            MaxArea += MaxArea(i - 1,j);
    end;
    if (j > 1) then
    begin
        if (B[i,j].content = B[i,j - 1].content) and (not B[i,j - 1].counted) and (not B[i,j - 1].empty) then
            MaxArea += MaxArea(i,j-1);
    end;
    if (i < lines) then
    begin
        if (B[i,j].content = B[i + 1,j].content) and (not B[i + 1,j].counted) and (not B[i + 1,j].empty) then
            MaxArea += MaxArea(i + 1,j);
    end;
end;

{usuwanie maksymalnego, spojnego obszaru, w zaleznosci od podanych
* wspolrzednych (i,j)}
procedure RemoveThisArea(i,j :Integer);
begin
    B[i,j].empty := true;
    if (j < columns) then
    begin
        if (B[i,j].content = B[i,j + 1].content) and (not B[i,j + 1].empty) then
            RemoveThisArea(i,j + 1);
    end;
    if (i > 1) then
    begin 
        if (B[i,j].content = B[i - 1,j].content) and (not B[i - 1,j].empty) then
            RemoveThisArea(i - 1,j);
    end;
    if (j > 1) then
    begin
        if (B[i,j].content = B[i,j - 1].content) and (not B[i,j - 1].empty) then
            RemoveThisArea(i,j - 1);
    end;
    if (i < lines) then
    begin
        if (B[i,j].content = B[i + 1,j].content) and (not B[i + 1,j].empty) then
            RemoveThisArea(i + 1,j);
    end;
end;

{przesuwanie elementow po usunieciu pewnego obszaru}
procedure Gravity;

    {przesuniecie w dol}
    procedure DownGravity;
    var i,j,k :Integer;
    begin
        for j := 1 to columns do
        begin
            for i := 1 to lines do
            begin
                if (B[i,j].empty) then
                begin
                    for k := i downto 2 do B[k,j] := B[k - 1,j];
                    B[1,j].empty := true;
                end;
            end;
        end;
    end;

    {przesuniecie w lewo}
    procedure LeftGravity;
    var i,j,k,max_j :Integer;
    begin
        max_j := columns;
        i := lines;
        for j := columns - 1 downto 1 do
        begin
            if (B[lines,j].empty) then 
            begin
                for k := j to columns - 1 do
                begin
                    for i := 1 to lines do B[i,k] := B[i,k + 1];
                end;
                for i := 1 to lines do B[i,max_j].empty := true;
                max_j := max_j - 1;
            end;
        end;
    end;
    
begin
    DownGravity;
    LeftGravity;
end;

{przeszukanie tablicy i znalezienie najwiekszego, mozliwego
* obszaru, ktory moze zwrocic komputer, procedura zwraca wspolrzedne 
* pierwszego w porzadku kanonicznym punktu (p1,p2)}
function FindMaxComputerArea(var B :tBoard) :Integer;
var i,j,res,max :Integer;
begin
    max := 0;
    for i := 1 to lines do
    begin
        for j := 1 to columns do
        begin
            if (not B[i,j].counted) and (not B[i,j].empty) and (B[i,j].computer) then
            begin
                f1 := 1;
                f2 := columns;
                res := MaxArea(i,j);
                if res > max then
                begin
                    max := res;
                    p1 := f1;
                    p2 := f2;
                end
                else if res = max then //gdy mamy obszary o tym samym 
                begin                  //rozmiarze, to do usuniecia 
                    if f2 <= p2 then   //wybieramy ten, ktory jest
                    begin              //pierwszy w porzadku kanonicznym
                        p1 := f1;
                        p2 := f2;
                    end
                end;
            end;
        end;
    end;
    FindMaxComputerArea := max;
end;

{znalezienie maksymalnego obszaru, ktory moze usunac gracz,
* ma na celu stwierdzenie, czy w ogole istnieje mozliwy do wykonania ruch}
function FindMaxUserArea(var B :tBoard) : Integer;
var i,j,res,max :Integer;
begin
    max := 0;
    for i := 1 to lines do
    begin
        for j := 1 to columns do
        begin
            if (not B[i,j].counted) and (not B[i,j].empty) and (B[i,j].user) then
            begin
                res := MaxArea(i,j);
                if (res > max) then
                    max := res;
            end;
        end;
    end;
    FindMaxUserArea := max;
end;

{wczytanie ruchu gracza i sprawdzenie, czy taki ruch jest dozwolony}
function SelectMovement : tPair;
var move :string;
    found :Boolean;
    k,w :Integer;
begin
    found := false;
    while (not found) and (not eof) do
    begin
        readln(move);
        {zamiana wczytanego ruchu na odpowiadajace mu wspolrzedne}
        if length(move) = 2 then 
            k := lines - (ord(move[2]) mod 48) + 1
        else 
            k := lines - ((ord(move[2]) mod 48) * 10 + (ord(move[3]) mod 48)) + 1;
        w := ord(move[1]) mod 96;
        if (k <= lines) and (w <= columns) and (k >= 1) and (w >= 1) then
        begin
            if (not B[k,w].empty) and (B[k,w].user) then 
            begin
                NotCounted;
                if MaxArea(k,w) > 1 then found := true;
            end;
        end;
    end;
    SelectMovement.k := k;
    SelectMovement.w := w;
end;

var stop :Boolean;
    x2, res :Integer;
    x1 :String;
    result :Longint;
    move : tPair;

    procedure PlayerMove();
    begin
        if eof then stop := true
            else begin
                if FindMaxUserArea(B) > 1 then //sprawdzamy czy istnieje obszar wiekszy od 1 
                begin                          //dostepny do usuniecia dla usera
                    move := SelectMovement;
                    NotCounted;
                    res := MaxArea(move.k,move.w);
                    if (res > 1) and B[move.k,move.w].user then 
                    begin                                     //sprawdzamy wielkosc obszaru jeszcze raz,
                        result := result + (res-1)*(res-1);   //bo moglo sie zdarzyc, ze
                        RemoveThisArea(move.k,move.w);        //w procedurze SelectMovement doszlismy do eof,
                        Gravity;                              //a ostatni ruch byl niepoprawny
                        writeln;
                        turn := 2;
                        writeln('wynik: ',result);
                        WriteBoard(B);
                    end;
                end
                else stop := true;
            end
    end;

    procedure ComputerMove();
    begin
        if FindMaxComputerArea(B) > 1 then 
            begin
                writeln;
                NotCounted;
                f1 := p1;
                f2 := p2;
                res := MaxArea(p1,p2);
                result := result - (res-1)*(res-1);
                x1 := chr(ord('a') + p2 - 1);
                x2 := lines - p1 + 1;
                writeln('(',x1,x2,')');
                RemoveThisArea(p1,p2);
                Gravity;
                NotCounted;
                turn := 1;
                writeln('wynik: ',result);
                WriteBoard(B);
            end
        else stop := true;
    end;

{program glowny}
begin
    result := 0;
    GenerateBoard;
    stop := false;
    while not stop do
    begin
        if turn = 1 then PlayerMove
        else if turn = 2 then ComputerMove;
    end;
    writeln;
end.
