#include <iostream>

using namespace std;

struct condition {
    int cost;
    int city; //pamiętam tylko po to, żeby nie czyścić tablicy po każdym przejściu(0,0,0,0,0)
};

int main() {
    condition c;
    int a[1002][3];
    int tripLength, x, firstTaxiPrice, maxTaxi, l;
    scanf("%d\n", &tripLength);
    scanf("%d\n", &maxTaxi);
    scanf("%d\n", &firstTaxiPrice);
    l = tripLength/2;
    a[0][1] = firstTaxiPrice;
    for (int i = 1; i <= tripLength; i++)
        for (int j = 0; j < 3; j++) {
            scanf("%d\n", &x);
            a[i][j] = x;
        }
    condition b[2][l + 1][maxTaxi + 1];
    for (int j = 0; j <= l; j++)
        for (int k = 0; k <= maxTaxi; k++) {
            b[0][j][k].cost = 1100003;
            b[1][j][k].cost = 1100003;
            b[0][j][k].city = -1;
            b[1][j][k].city = -1;
        }
    c.cost = a[1][0];
    c.city = 1;
    b[0][1][0] = c;
    c.cost = a[1][2] + a[0][1];
    b[0][0][1] = c;
    int v;
    for (int i = 1; i < tripLength; i++) {
        x = i % 2;
        if (x == 1) { //lecę po tab[0] i wpisuję do tab[1]
            for (int j = 0; j < l; j++) {
                for (int k = 0; k < maxTaxi; k++) {
                    if (b[0][j][k].city == i) {  //sprawdzam, czy to nie śmieciowe dane, tylko z poprzedniego miasta
                        if (!(k % 2)) {   //jestem na dworcu, dla dworca parzyście taxi
                            v = b[0][j][k].cost + a[i + 1][0];
                            //najpierw jadę trainem
                            if ((b[1][j + 1][k].cost > v) || (b[1][j + 1][k].city != i + 1)) { //dodać city, bo może być stare!
                                b[1][j + 1][k].city = i + 1;
                                b[1][j + 1][k].cost = v;
                            }
                            //a teraz taxi + plane, na pewno moge jeszcze, bo k < maxTaxi w pętli
                            if (i + 1 - j <= l) {
                                v = b[0][j][k].cost + a[i + 1][2] + a[i][1];
                                if ((b[1][j][k + 1].cost > v) || (b[1][j][k + 1].city != i + 1)) {
                                    b[1][j][k + 1].cost = v;
                                    b[1][j][k + 1].city = i + 1;
                                }
                            }
                        //teraz jestem na lotnisku
                        } else {
                            //najpierw lecę, jeśli mogę
                            if (i + 1 - j <= l) {
                                v = b[0][j][k].cost + a[i + 1][2];
                                if ((b[1][j][k].cost > v) || (b[1][j][k].city != i + 1)) {
                                    b[1][j][k].cost = v;
                                    b[1][j][k].city =  i + 1;
                                }
                            }
                            //a teraz taxi + train
                            v = b[0][j][k].cost + a[i + 1][0] + a[i][1];
                            if ((b[1][j + 1][k + 1].cost > v) || (b[1][j + 1][k + 1].city != i + 1)) {
                                b[1][j + 1][k + 1].cost = v;
                                b[1][j + 1][k + 1].city = i + 1;
                            }

                        }

                    }
                } //dla k = maxTaxi
                if (b[0][j][maxTaxi].city == i) {
                    if (!(maxTaxi % 2)) {   //jestem na dworcu, dla dworca parzyście taxi
                        v = b[0][j][maxTaxi].cost + a[i + 1][0];
                        // jadę trainem, bo nie mam już taxi :(
                        if ((b[1][j + 1][maxTaxi].cost > v) || (b[1][j + 1][maxTaxi].city != i + 1)) {
                            b[1][j + 1][maxTaxi].city = i + 1;
                            b[1][j + 1][maxTaxi].cost = v;
                        }
                    } else {
                        //jestem na lotnisku i lecę samolotem, jeśli mogę, bo nie mam już taxi :()
                        if (i + 1 - j <= l) {
                            v = b[0][j][maxTaxi].cost + a[i + 1][2];
                            if ((b[1][j][maxTaxi].cost > v) || (b[1][j][maxTaxi].city != i + 1)) {
                                b[1][j][maxTaxi].cost = v;
                                b[1][j][maxTaxi].city =  i + 1;
                            }
                        }
                    }
                }
            }// dla j = l, mogę tylko samolotem już latać
            for (int k = 0; k < maxTaxi; k++) {
                if (b[0][l][k].city == i) {
                    if (!(k % 2)) {   //jestem na dworcu, dla dworca parzyście taxi
                        //taxi + plane, na pewno moge jeszcze, bo k < maxTaxi w pętli
                        if (i + 1 - l <= l) {
                            v = b[0][l][k].cost + a[i + 1][2] + a[i][1];
                            if ((b[1][l][k + 1].cost > v) || (b[1][l][k + 1].city != i + 1)) {
                                b[1][l][k + 1].cost = v;
                                b[1][l][k + 1].city = i + 1;
                            }
                        }
                    //teraz jestem na lotnisku
                    } else {
                        // lecę, jeśli mogę
                        if (i + 1 - l <= l) {
                            v = b[0][l][k].cost + a[i + 1][2];
                            if ((b[1][l][k].cost > v) || (b[1][l][k].city != i + 1)) {
                                b[1][l][k].cost = v;
                                b[1][l][k].city =  i + 1;
                            }
                        }
                    }
                }
            }
            if (b[0][l][maxTaxi].city == i) {
                if (maxTaxi % 2) {   //jestem na lotnisku
                    //jestem na lotnisku i lecę samolotem, jeśli mogę, bo nie mam już taxi :()
                    if (i + 1 - l <= l) {
                        v = b[0][l][maxTaxi].cost + a[i + 1][2];
                        if ((b[1][l][maxTaxi].cost > v) || (b[1][l][maxTaxi].city != i + 1)) {
                            b[1][l][maxTaxi].cost = v;
                            b[1][l][maxTaxi].city =  i + 1;
                        }
                    }
                }
            }
        // lecę po tab[1] i wpisuję do tab[0]
        } else {
            for (int j = 0; j < l; j++) {
                for (int k = 0; k < maxTaxi; k++) {
                    if (b[1][j][k].city == i) {  //sprawdzam, czy to nie śmieciowe dane, tylko z poprzedniego miasta
                        if (!(k % 2)) {   //jestem na dworcu, dla dworca parzyście taxi
                            v = b[1][j][k].cost + a[i + 1][0];
                            //najpierw jadę trainem
                            if ((b[0][j + 1][k].cost > v) || (b[0][j + 1][k].city != i + 1)) { //dodać city, bo może być stare!
                                b[0][j + 1][k].city = i + 1;
                                b[0][j + 1][k].cost = v;
                            }
                            //a teraz taxi + plane, na pewno moge jeszcze, bo k < maxTaxi w pętli
                            if (i + 1 - j <= l) {
                                v = b[1][j][k].cost + a[i + 1][2] + a[i][1];
                                if ((b[0][j][k + 1].cost > v) || (b[0][j][k + 1].city != i + 1)) {
                                    b[0][j][k + 1].cost = v;
                                    b[0][j][k + 1].city = i + 1;
                                }
                            }
                        //teraz jestem na lotnisku
                        } else {
                            //najpierw lecę, jeśli mogę
                            if (i + 1 - j <= l) {
                                v = b[1][j][k].cost + a[i + 1][2];
                                if ((b[0][j][k].cost > v) || (b[0][j][k].city != i + 1)) {
                                    b[0][j][k].cost = v;
                                    b[0][j][k].city =  i + 1;
                                }
                            }
                            //a teraz taxi + train
                            v = b[1][j][k].cost + a[i + 1][0] + a[i][1];
                            if ((b[0][j + 1][k + 1].cost > v) || (b[0][j + 1][k + 1].city != i + 1)) {
                                b[0][j + 1][k + 1].cost = v;
                                b[0][j + 1][k + 1].city = i + 1;
                            }

                        }

                    }
                } //dla k = maxTaxi
                if (b[1][j][maxTaxi].city == i) {
                    if (!(maxTaxi % 2)) {   //jestem na dworcu, dla dworca parzyście taxi
                        v = b[0][j][maxTaxi].cost + a[i + 1][0];
                        // jadę trainem, bo nie mam już taxi :()
                        if ((b[0][j + 1][maxTaxi].cost > v) || (b[0][j + 1][maxTaxi].city != i + 1)) { //dodać city, bo może być stare!
                            b[0][j + 1][maxTaxi].city = i + 1;
                            b[0][j + 1][maxTaxi].cost = v;
                        }
                    } else {
                        //jestem na lotnisku i lecę samolotem, jeśli mogę, bo nie mam już taxi :(
                        if (i + 1 - j <= l) {
                            v = b[1][j][maxTaxi].cost + a[i + 1][2];
                            if ((b[0][j][maxTaxi].cost > v) || (b[0][j][maxTaxi].city != i + 1)) {
                                b[0][j][maxTaxi].cost = v;
                                b[0][j][maxTaxi].city =  i + 1;
                            }
                        }
                    }
                }
            }// dla j = l, mogę tylko samolotem już latać
            for (int k = 0; k < maxTaxi; k++) {
                if (b[1][l][k].city == i) {
                    if (!(k % 2)) {   //jestem na dworcu, dla dworca parzyście taxi
                        //taxi + plane, na pewno moge jeszcze, bo k < maxTaxi w pętli
                        if (i + 1 - l <= l) {
                            v = b[1][l][k].cost + a[i + 1][2] + a[i][1];
                            if ((b[0][l][k + 1].cost > v) || (b[0][l][k + 1].city != i + 1)) {
                                b[0][l][k + 1].cost = v;
                                b[0][l][k + 1].city = i + 1;
                            }
                        }
                    //teraz jestem na lotnisku
                    } else {
                        // lecę, jeśli mogę
                        if (i + 1 - l <= l) {
                            v = b[1][l][k].cost + a[i + 1][2];
                            if ((b[0][l][k].cost > v) || (b[0][l][k].city != i + 1)) {
                                b[0][l][k].cost = v;
                                b[0][l][k].city =  i + 1;
                            }
                        }
                    }
                }
            }
            if (b[1][l][maxTaxi].city == i) {
                if (maxTaxi % 2) {   //jestem na lotnisku
                    //jestem na lotnisku i lecę samolotem, jeśli mogę, bo nie mam już taxi :(
                    if (i + 1 - l <= l) {
                        v = b[1][l][maxTaxi].cost + a[i + 1][2];
                        if ((b[0][l][maxTaxi].cost > v) || (b[0][l][maxTaxi].city != i + 1)) {
                            b[0][l][maxTaxi].cost = v;
                            b[0][l][maxTaxi].city =  i + 1;
                        }
                    }
                }
            }
        }
    }
    for (int k = 0; k < maxTaxi; k++) {
        if (b[1][l][k].city == tripLength) {
            if (!(k % 2)) { //tylko dla pociągów
                v = b[1][l][k].cost + a[tripLength][1];
                if (b[1][l][k + 1].cost > v) {
                    b[1][l][k + 1].cost = v;
                    b[1][l][k + 1].city = tripLength;
                }
            }
        }
    }
    //kompletnie bez sensu, bo mogłam x używać
    x = 1100009;
    for (int i = 0; i <= maxTaxi; i++)
        if ((b[1][l][i].cost < x) && (i % 2) && (b[1][l][i].city == tripLength))
            x = b[1][l][i].cost;

    cout << x;
}
