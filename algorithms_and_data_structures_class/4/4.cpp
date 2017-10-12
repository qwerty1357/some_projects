#include <iostream>
#include <string>
#include <stdio.h>
#include <set>
#include <algorithm>
#include <array>

int main() {
    int playersNumb;
    int gamesNumb;
    scanf("%d", &playersNumb);
    scanf("%d", &gamesNumb);
    int player;
    std::set<long long int> st;
    long long int A[playersNumb + 1];

    for (int i = 0; i < playersNumb + 1; i++) {
        A[i] = 0;
    }
    
    long long int counter = 1;
    if ((gamesNumb == 1) && (playersNumb > 2)) {
        printf("NIE\n");
        return 0;
    } else {
        for (int i = 0; i < gamesNumb; i++) {
            for (int j = 1; j < playersNumb/2 + 1; j++) {
                scanf("%d\n", &player);
                A[player] += counter;
            }
            for (int j = playersNumb/2 + 1; j < playersNumb + 1; j++)
                scanf("%d\n", &player);
            counter *= 2;
        }
        st.insert(A[1]);
        for (int k = 2; k < playersNumb + 1; k++) {
            if (st.find(A[k]) == st.end()) {
                st.insert(A[k]);
            }
            else {
                printf("NIE\n");
                return 0;
            }
        }
        printf("TAK\n");
        return 0;
    }
    
}