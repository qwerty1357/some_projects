{
* Program SetGame.pas
* Agnieszka Kusnierz
* 332284
}

program SetGame;

const	DECK = 81;
		TABLE = 21;	//istnieje max 20 kart bez seta
		CARDS_DEAL = 12;

{kazda karta jest rekordem, ktory przechowuje:
* jej numer, ten podany na wejsciu, cztery atrybuty
* i aktualna pozycje - numer na stole}
type
	card = record
		cardNumber :integer;
		number :integer;
		color :integer;
		lining :integer;
		shape :integer;
		numberOnTable :integer;
	end;

{tablica reprezentujaca karty w talii}
type tDeck = array[1..DECK] of card;

{tablica reprezentujaca karty na stole}
type tTable = array[1..TABLE] of card;

{tablica reprezentujaca karty w secie}
type tSet = array[1..3] of card;

var X :tDeck;
	ifSet :boolean;
	onTable,inDeck :integer;
	Ts :tSet;
	Tab :tTable;

{wczytanie talii kart}
procedure ReadDeck(var A :tDeck);
var i,x :integer;
begin
	for i := 1 to DECK do
	begin
		read(x);
		A[i].cardNumber := x;
		A[i].number := (((x div 10)-1)div 3);
		A[i].color := ((x div 10) mod 3);
		A[i].lining := (((x mod 10)-1) div 3);
		A[i].shape := ((x mod 10) mod 3);
		A[i].numberOnTable := i;
	end;
end;

{wczytanie stolu, pierwsze rozdanie}
procedure ReadTable(var B :tTable);
var i :integer;
begin
	for i := 1 to CARDS_DEAL do B[i] := X[i];
end;

{wyszukanie i zapisanie seta, jesli znajdziemy seta,
* to go zapamietujemy i konczymy szukanie,
* jesli nie ma na stole seta, to zmienna ifSet := false}
function FindSet(var A :tTable):tSet;
var i,j,k,compat :integer;
	P :tSet;

{pomocnicza procedura porownujaca poszczegolne wartosci}
procedure Compare(v1,v2,v3 :Integer);
begin
	if (v1 = v2) and (v1 = v3) then compat:=compat+1
	else if (v1 <> v2) and (v1 <> v3) and (v2 <> v3) then compat:=compat+1;
end;

begin
	i := 1;
	ifSet := false;
	while (i <= onTable - 2) and (not ifSet) do
	begin
		j := i+1;
		while (j <= onTable - 1) and (not ifSet) do
		begin
			k := j + 1;
			while (k <= onTable) and (not ifSet) do 
			begin
				compat := 0;
				Compare(A[i].number,A[j].number,A[k].number);
				Compare(A[i].color,A[j].color,A[k].color);
				Compare(A[i].lining,A[j].lining,A[k].lining);
				Compare(A[i].shape,A[j].shape,A[k].shape);
				if compat = 4 then 
				begin
					ifSet := true;
					P[1] := A[i];
					P[2] := A[j];
					P[3] := A[k];
				end
				else k := k+1;
			end;
			j := j+1;
		end;
		i := i+1;
	end;
	FindSet := P;
end;

{wypisanie stanu stolu na ekran}
procedure WriteTable(var D :tTable);
var i :integer;
begin
	write('=');
	for i := 1 to onTable do write(' ',D[i].cardNumber);
	Writeln;
end;

{wypisanie seta na ekran}
procedure WriteSet(var D :tSet);
var i :integer;
begin
	write('-');
	for i := 1 to 3 do write(' ',D[i].cardNumber);
	writeln;
end;

{ usuwanie seta ze stolu:
* karty, ktore sa przed pierwsza karta seta pozostaja bez zmian
* karty, ktore sa za pierwsza karta seta i przed druga
* przesuwamy o 1 miejsce, te, ktore sa za druga i przed 3
* przesuwamy o 2 miejsca, a te, ktore sa za trzecia
* przesuwamy o 3 miejsca}
procedure DeleteSet(var D :tTable);
var i :integer;
begin
	i := ts[1].numberOnTable+1;
	while i <= onTable do
	begin
		if i = Ts[2].numberOnTable then i := i + 1
		else if i = Ts[3].numberOnTable then i := i + 1
		else begin
			if i < Ts[2].numberOnTable then
			begin
				D[i].numberOnTable := D[i].numberOnTable - 1;
				D[i - 1] := D[i];
			end
			else if i < Ts[3].numberOnTable then 
			begin
				D[i].numberOnTable := D[i].numberOnTable - 2;
				D[i - 2] := D[i];
			end
			else begin
				D[i].numberOnTable := D[i].numberOnTable - 3;
				D[i - 3] := D[i];
			end;
			i := i + 1;
		end;
	end;
end;

{procedura dokladajaca na stol 3 karty}
procedure AddCards(var D :tTable);
var i :integer;
begin
	for i := 1 to 3 do
	begin
		D[onTable + i] := X[inDeck + i - 1];
		D[onTable + i].numberOnTable := onTable + i;
	end;
end;

{ciag ruchow, w przypadku, gdy mamy seta na stole}
procedure HaveSet;
begin
	WriteTable(Tab);
	WriteSet(Ts);
	DeleteSet(Tab);
	onTable := onTable - 3;
	if onTable < CARDS_DEAL then
	begin
		AddCards(Tab);
		inDeck := inDeck + 3;
		onTable := onTable + 3;
	end;
end;

{procedura wykonuje sie, gdy na stole nie ma seta}
procedure DontHaveSet;
begin
	WriteTable(Tab);
	Writeln('-');
	AddCards(Tab);
	inDeck := inDeck + 3;
	onTable := onTable + 3;
end;

{gdy nie ma juz kart w talii, to zabieramy ewentualne sety}
procedure NoCardsInDeck;
begin
	WriteTable(Tab);
	WriteSet(Ts);
	DeleteSet(Tab);
	onTable := onTable - 3;
	Ts := FindSet(tab);
end;

{ustalenie ile jest aktuanie kart na stole 
* i ile pozostaje w talii,
* wczytanie talii i wczytanie kart na stol}
procedure Start;
begin
	onTable := CARDS_DEAL;	//poczatkowo na stole, tyle, ile przy rozdaniu
	inDeck := CARDS_DEAL + 1;	//karta, od ktorej zaczniemy dokladanie kart na stol
	ReadDeck(X);
	ReadTable(Tab);
end;

{program glowny}
begin
	Start;
	while inDeck <= DECK do	//poki w talii mamy karty
	begin
		Ts := FindSet(Tab);
		if ifSet then HaveSet
		else DontHaveSet;
	end;
	Ts := FindSet(tab);
	While (ifSet) and (onTable > 1) do NoCardsInDeck;
	WriteTable(tab);	//ostateczny stan stolu
end.
