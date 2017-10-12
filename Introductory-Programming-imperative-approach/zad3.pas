{program Collatz
* Agnieszka Kusnierz 
* 332284
* }

program Coll;

type tList = ^listItem;
    listItem = record 
        item :Longint;
        next :tList;
    end;

const MAXHEAT = 19;

{pomocniczna procedura, wstawiajaca element 'what' do listy,
* na miejsce za elementem 'where'}
procedure InsertFor(var where, what :tList);
var temp :tList;
begin
    temp := where^.next;
    where^.next := what;
    what^.next := temp;
end;

procedure wypisz(l :tList);
begin
    while l <> Nil do begin
        write(l^.item, ' ');
        l := l^.next;
    end;
    writeln;
end;

{pomocnicza procedura usuwajaca liste l}
procedure Clean(var l :tList);
var temp :tList;
begin
    while l <> Nil do
    begin
        temp := l;
        l := l^.next;
        dispose(temp);
    end;
end;

{pomocnicza procedura, usuwa element what, ktory znajduje sie za 
* elementem prev i ustawia wskaznik what na elemencie, ktory
* pierwotnie byl za nim}
procedure Remove(var what, prevItem :tList);
begin
    prevItem^.next := what^.next;
    dispose(what);
    what:= prevItem^.next;
end;

{procedura wykorzystana w funkcji Addition i Multiplication, na wejsciu dostaje liste
l, ktora jest uporzadkowana niemalejaco}
procedure Add(var l :tList);
var guard, flunkey, sup, prev :tList;
    x :Longint;
begin
    if l <> Nil then
    begin
        new(guard);
        guard^.next := l;
        x := l^.item;
        flunkey := l;
        prev := guard;
        l := l^.next;
        while l <> Nil do
        begin
            if l^.item = x then
            begin
                if l^.next <> Nil then
                begin
                    if l^.item = l^.next^.item then
                    begin
                        sup := l^.next;
                        l^.next := sup^.next;
                        dispose(sup);
                        l^.item := l^.item + 1;
                        l := l^.next;
                        if l <> Nil then
                            if l^.item <> x then
                            begin
                                flunkey := flunkey^.next;
                                prev := prev^.next;
                                l := flunkey^.next;
                                x := flunkey^.item;
                            end;
                    end
                    else begin
                        sup := flunkey;
                        flunkey := flunkey^.next;
                        prev^.next := flunkey;
                        dispose(sup);
                        l^.item := l^.item + 1;
                        x := flunkey^.item;
                        l := flunkey^.next;
                    end;
                end
                else begin
                    sup := flunkey;
                    flunkey := flunkey^.next;
                    prev^.next := flunkey;
                    dispose(sup);
                    x := flunkey^.item;
                    l^.item := l^.item + 1;
                    l := flunkey^.next;
                end;
            end
            else begin
                flunkey := flunkey^.next;
                prev := prev^.next;
                x := flunkey^.item;
                l := flunkey^.next;
            end;
        end;
        l := guard^.next;
        dispose(guard);
    end;
end;

{zamiana liczby dziesietnej na reprezentacje Napiera}
function Napier(var l1 :tList) :tList;
var l2, temp, flunkey, guard, rem :tList;
    ifOdd, stop :Boolean;
    count :Longint;
begin
    if l1 <> Nil then
    begin
        stop := false;
        new(l2);
        temp := l2;
        flunkey := l2;
        l2^.next := Nil;
        count := 0;
        new(guard);
        guard^.next := l1;
        while guard^.next <> Nil do
        begin
            ifOdd := false;
            stop := false;
            while not stop do
            begin
                if l1 = Nil then stop := true
                else if l1^.item <> 0 then stop := true
                else begin
                    rem := l1;
                    l1 := l1^.next;
                    dispose(rem);
                end;
            end;
            guard^.next := l1;
            while l1 <> Nil do
            begin
                if ifOdd then
                begin
                    if odd(l1^.item) then ifOdd := true
                    else ifOdd := false;
                    l1^.item := l1^.item div 2 + 5;
                end
                else begin
                    if odd(l1^.item) then ifOdd := true
                    else ifOdd := false;
                    l1^.item := l1^.item div 2;
                end;
                l1 := l1^.next;
            end;
            if ifOdd then 
            begin
                new(l2);
                temp^.next := l2;
                temp := temp^.next;
                l2^.next := Nil;
                l2^.item := count;
            end;
            count := count + 1; 
            l1 := guard^.next;
        end;
        Napier := flunkey^.next;
        dispose(flunkey);
        dispose(guard);
    end;
end;

{funkcja , ktora na wejsciu dostaje dwie listy uporzadkowane rosnaco,
* kazda lista reprezentuje liczbe w rep. Napiera, funkcja zwraca wynik
* dodawania danych dwoch liczb}
function Addition(var l1, l2 :tList) :tList;
var l, guard :tList;
begin
    if (l1 <> Nil) and (l2 <> Nil) then
    begin
        new(guard);
        l := guard;
        while (l1 <> Nil) and (l2 <> Nil) do
        begin
            if l1^.item <= l2^.item then
            begin
                l^.next := l1;
                l1 := l1^.next;
            end
            else begin
                l^.next := l2;
                l2 := l2^.next;
            end;
            l := l^.next;
        end;
        if l1 <> Nil then l^.next := l1
        else if l2 <> Nil then l^.next := l2;
        l := guard^.next;
        dispose(guard);
    end
    else if l1 <> Nil then l := l1
    else if l2 <> Nil then l := l2;
    {w tej chwili mamy uporzadkowana niemalejaco liste l i zaczynamy
    * wykonywac dzialanie dodawania dla liczb w reprezentacji Napiera}
    Add(l);
    Addition := l;
end;

{funkcja dostaje liczbe wymierna w postaci Napiera i zwraca podloge z tej liczby}
function Floor(var l :tList) :tList;
var stop :Boolean;
    guard, l1, pom :tList;
begin
    new(guard);
    l1 := guard;
    guard^.next := Nil;
    pom := l;
    while pom <> Nil do 
    begin
        new(l1^.next);
        l1 := l1^.next;
        l1^.item := pom^.item;
        pom := pom^.next;
        l1^.next := Nil;
    end;
    l1 := guard^.next;
    dispose(guard);
    if l1 <> Nil then
    begin
        new(guard);
        guard^.next := l1;
        stop := false;
        while (l1 <> Nil) and (not stop) do
        begin
            if l1^.item < 0 then
            begin
                guard^.next := l1^.next;
                dispose(l1);
                l1 := guard^.next;
            end
            else stop := true;
        end;
    end;
    l1 := guard^.next;
    dispose(guard);
    Floor := l1;
end;

{funkcja zamienia liczbe (co najwyzej MAXLONGINT) na reprezentacje Napiera}
function Napier2(x :Longint) :tList;
var guard, l :tList;
    y :Longint;
begin
    new(guard);
    guard^.next := Nil;
    l := guard;
    y := 0;
    while x <> 0 do
    begin
        if (x mod 2) <> 0 then
        begin
            new(l^.next);
            l := l^.next;
            l^.item := y;
            l^.next := Nil;
        end;
        y := y + 1;
        x := x div 2;
    end;
    Napier2 := guard^.next;
    dispose(guard);
end;

{zwraca podloge z logarytmu przy podstawie 2 liczby l}
function Log(var l :tList) :tList;
var guard :tList;
begin
    guard := l;
    if l <> Nil then
    begin
        while l^.next <> Nil do l := l^.next;
        Log := Napier2(l^.item);
        l := guard;
    end
    else Log := Nil;
end;

{Funkcja zwraca true jeśli l1 > l2, false w przeciwnym przypadku}
function Compare(l1, l2 :tList) :Boolean;
var guard, l, support, l1rev, l2rev, first1, first2 :tList;
    stop :Boolean;
begin
    l := l1;
    new(guard);
    guard^.next := Nil;
    while l <> Nil do
    begin
        new(support);
        support^.item := l^.item;
        support^.next := guard^.next;
        guard^.next := support;
        l := l^.next;
    end;
    l1rev := guard^.next;
    guard^.next := Nil;
    l := l2;
    while l <> Nil do
    begin
        new(support);
        support^.item := l^.item;
        support^.next := guard^.next;
        guard^.next := support;
        l := l^.next;
    end;
    l2rev := guard^.next;
    dispose(guard);
    first1 := l1rev;
    first2 := l2rev;
    stop := false;
    while (l1rev <> Nil) and (l2rev <> Nil) and (not stop) do
    begin
        if l1rev^.item = l2rev^.item then
        begin
            l1rev := l1rev^.next;
            l2rev := l2rev^.next;
        end
        else stop := true;
    end;
    if stop then
    begin
        Compare := (l1rev^.item > l2rev^.item);
    end
    else if l1rev = Nil then Compare := false
    else Compare := true;
    clean(first1);
    clean(first2);
end;

{funkcja wykonuje mnozenie na liczbach w reprezentcji Napiera}
function Multiplication(var l1, l2 :tList) :tList;
var guard, l, temp, prev, mem1, mem2 :tList;
    stop :Boolean;
begin
    if (l1 <> Nil) and (l2 <> Nil) then
    begin
        mem1 := l1;
        mem2 := l2;
        new(temp);
        new(guard);
        temp^.item := l1^.item + l2^.item;
        guard^.next := temp;
        prev := guard;
        temp^.next := Nil;
        l := temp;
        l2 := l2^.next;
        while l1 <> Nil do
        begin
            while l2 <> Nil do
            begin
                l := guard^.next;
                prev := guard;
                stop := false;
                new(temp);
                temp^.item := l1^.item + l2^.item;
                while not stop do
                begin
                    if l<> Nil then
                    begin
                        if l^.item <= temp^.item then
                        begin
                            l := l^.next;
                            prev := prev^.next;
                        end
                        else begin
                            InsertFor(prev, temp);
                            stop := true; 
                        end;
                    end
                    else begin
                        InsertFor(prev, temp);
                        stop := true;
                    end;
                end;
                l2 := l2^.next;
            end;
            l2 := mem2;
            l1 := l1^.next;
        end;
        {w tej chwili mamy liste uporzadkowana niemalejaco, powstalal ze scalenia dwoch list, 
        ktore chcemy pomnozyc, i wykonujemy procedure Add}
        Add(guard^.next);
        Multiplication := guard^.next;
        clean(mem1);
        clean(mem2);
        dispose(guard);
    end
    else begin
        clean(l1);
        clean(l2);
        Multiplication := Nil;
    end;
end;
   
{zastępuje wartość na czubku stosu wynikiem zaaplikowania funkcji T do jej podłogi
 i wypisuje ten wynik na wyjście} 
function Collatz(var l :tList) :Tlist;
var odd, stop :Boolean;
    l1, l2, l3, guard :tList;
begin
    stop := false;
    odd := false;
    new(guard);
    guard^.next := l;
    if l <> Nil then
    begin
        while (not stop) and (l <> Nil) do
        begin
            if l^.item < 0 then
            begin
                guard^.next := l^.next;
                dispose(l);
                l := guard^.next;
            end
            else if l^.item = 0 then
            begin
                odd := true;
                stop := true;
            end
            else stop := true;
        end;
        l := guard^.next;
    end;
    dispose(guard);
    new(l1);
    guard := l1;
    l1^.item := 0;
    new(l1^.next);
    l1 := l1^.next;
    l1^.item := 1;
    l1^.next := Nil;
    l1 := guard;
    if odd then 
    begin
        new(l2);
        l2^.item := 0;
        l2^.next := Nil;
        l := Multiplication(l1,l);
        l := Addition(l2,l);
    end;
    new(l3);
    l3^.item := -1;
    l3^.next := Nil;
    l := Multiplication(l,l3);
    Collatz := l;
    clean(l1);
end;

{uruchamia poszukiwania potencjalnych kontrprzykładów dla hipotezy Collatza.
 Poszukiwania są parametryzowane leżącymi na stosie wartościami A, B, C, D, E.
 Parametr A jest na głębokości 4, B na 3, C na 2, D na 1 a E leży na czubku stosu}
procedure find(A, B, C, D, E :tList);
var x, y, i, j, l, sup, B2, C2, D2, first :tList;
    dosc :Boolean;
begin
    writeln('{');
    sup := D;
    new(D2);
    l := D2;
    D2^.next := Nil;
    while sup <> Nil do 
    begin
        new(D2^.next);
        D2 := D2^.next;
        D2^.item := sup^.item;
        D2^.next := Nil;
        sup := sup^.next;
    end;
    D2 := l^.next;
    dispose(l);
    x := D2;
    i := Nil;
    repeat 
        y := Floor(x);
        i := Nil;
        dosc := false;
        sup := B;
        new(B2);
        l := B2;
        B2^.next := Nil;
        while sup <> Nil do 
        begin
            new(B2^.next);
            B2 := B2^.next;
            B2^.item := sup^.item;
            B2^.next := Nil;
            sup := sup^.next;
        end;
        B2 := l^.next;
        dispose(l);
        l := Log(y);
        j := Multiplication(B2, l);
        while (not dosc) and (Compare(y, A)) do
        begin
            if not Compare(j, i) then
            begin
                dosc := true;
            end
            else begin
                y := Collatz(y);
                new(l);
                l^.item := 0;
                l^.next := Nil;
                first := l;
                i := Addition(i, l);
            end;
        end;
        if dosc then
        begin
            l := x;
            write('^');
            if l <> Nil then begin
                while l^.next <> Nil do 
                begin
                    write(l^.item, ' '); 
                    l := l^.next;
                end;
                write(l^.item);
            end;
            writeln;
        end;
        sup := C;
        new(C2);
        l := C2;
        C2^.next := Nil;
        while sup <> Nil do 
        begin
            new(C2^.next);
            C2 := C2^.next;
            C2^.item := sup^.item;
            C2^.next := Nil;
            sup := sup^.next;
        end;
        C2 := l^.next;
        dispose(l);
        x := Addition(x, C2);
        clean(y);
        clean(j);
        clean(i);
    until Compare(x, E);
    writeln('}'); 
    clean(x);
end;

{program glowny}
var l, l1, l2, first :tList;
    x :Longint; 
    c :char;
    T :array[0..MAXHEAT] of tList;
    numb, i, d :Integer;

{ponizej: poszczegolne procedury dla odpowiadajacych im polecen}
procedure PushNorm;
begin
    new(first);
    first^.next := Nil;
    l := first;
    while not eoln do
    begin
        new(l^.next);
        l := l^.next;
        read(c);
        l^.item := ord(c)-48;
        l^.next := Nil;
    end;
    l1 := Napier(first^.next);
    numb := numb + 1;
    T[numb] := l1;
    dispose(first);
end;

procedure PushNapier;
begin
    new(first);
    first^.next := Nil;
    l := first;
    while not eoln do
    begin
        new(l^.next);
        l := l^.next;
        read(x);
        l^.item := x;
        l^.next := Nil;
    end;
    l := first^.next;
    numb := numb + 1;
    T[numb] := l;
    dispose(first);
end;

procedure Plus;
begin
    l1 := T[numb - 1];
    l2 := T[numb];
    l :=  Addition(l1,l2);
    T[numb - 1]:= l;
    T[numb] := Nil;
    numb := numb - 1;
end;

procedure Mult;
begin
    l1 := T[numb - 1];
    l2 := T[numb];
    l := Multiplication(l1,l2);
    T[numb - 1] := l;
    T[numb] := Nil;
    numb := numb - 1;
end;

procedure Duplicate;
begin
    l := T[numb];
    if l = Nil then l1 := Nil
    else begin
        new(first);
        l1 := first;
        l1^.next := Nil;
        while l <> Nil do 
        begin
            new(l1^.next);
            l1 := l1^.next;
            l1^.item := l^.item;
            l1^.next := Nil;
            l := l^.next;
        end;
        l1 := first^.next;
        dispose(first);
    end;
    T[numb + 1] := l1;
    numb := numb + 1;
end;

procedure RemoveTop;
begin
    clean(T[numb]);
    numb := numb - 1;
end;

procedure WriteHeat;
begin
    writeln('[');
    for i := 0 to numb do
    begin
        l := T[i];
        write((numb - i) mod 10, ': ^');
        if l <> Nil then 
        begin
            while l^.next <> Nil do begin write(l^.item, ' '); l := l^.next; end;
            writeln(l^.item);
        end
        else writeln;
    end;
    writeln(']');
end;

procedure TakePush;
begin
    read(d);
    l := T[numb - d];
    for i := numb - d to numb -1 do T[i] := T[i+1];
    T[numb] := l;
end;

procedure EmptyCommand;
begin
    T[numb] := Collatz(T[numb]);
    l1 := T[numb];
    write('^');
    if l1 <> Nil then 
    begin
        while l1^.next <> Nil do
        begin
            write(l1^.item, ' ');
            l1 := l1^.next;
        end;
        write(l1^.item);
    end;
    writeln;
    read(c);
end;

begin
    for i := 0 to MAXHEAT do T[i] := Nil;
    numb := -1;
    while not eof do
    begin
        if eoln then
        begin
            EmptyCommand;
        end
        else begin
            read(c);
            case c of
                '#': 
                begin
                    PushNorm;
                end;    
                '^':
                begin
                    PushNapier;
                end;
                '+':
                begin
                    Plus;
                end;
                '*':
                begin
                    Mult;
                end;
                '=':
                begin
                    Duplicate;
                end;
                '\':
                begin
                    RemoveTop;
                end;
                '$':
                begin
                    WriteHeat;
                end;
                '?':
                begin
                    find(T[numb-4], T[numb-3], T[numb-2], T[numb-1], T[numb]);
                end;
                '@':
                begin
                    TakePush;
                end;
            end;
            read(c);
        end;
    end; 
    for i := 0 to MAXHEAT do clean(T[i]);
end.
