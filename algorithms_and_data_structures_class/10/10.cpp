#include <iostream>
#include <set>
#include <vector>
#include <unistd.h>

using namespace std;

const int MAXIMUM = 100001;

int main() {
    long n, m, k, zalezny, od_niego_zalezy;
    cin >> n;
    cin >> m;
    cin >> k;
    vector<int> A[MAXIMUM];
    long S[n + 1][2];
    sleep(1);

    for (int i = 1; i <= n; i++) {
        cin >> S[i][0];
        S[i][1] = 0;
    }
    for (int i = 1; i <= m; i++) {
        cin >> zalezny;
        cin >> od_niego_zalezy;
        S[zalezny][1]++;
        A[od_niego_zalezy].push_back(zalezny);
    }

    set< pair<int, int> > set_of_pair;
    for (int i = 1; i <= n; i++) {
        if (S[i][1] == 0){
            //cout << "para   " << S[i][0] << ", " << i << endl;
            set_of_pair.insert(make_pair(S[i][0], i)); // taka para: ilu programistów + index projektu
        }
    }

    set< pair<int, int> >::iterator it;
    set< pair<int, int> >::iterator iter;
    int result = 0;
    // Łapię k pierwszych najmniejszych, które w danej chwili mogę, bo nie są od
    // niczego zależne
    for (int i = 1; i <= k; i++) {
        it = set_of_pair.begin();
        if (result < it->first) {
            result = it->first;
        }
        //cout << "it->first= " << it->first << "  second = " << it->second << endl;

        for (auto iter = A[it->second].begin(); iter != A[it->second].end(); iter++) {
            S[*iter][1]--;
            //cout <<"iter = " <<  *iter << endl;
            if (S[*iter][1] == 0) {
                set_of_pair.insert(make_pair(S[*iter][0], *iter));
            }
        }

        set_of_pair.erase(it);

    }

    cout << result << endl;

}
