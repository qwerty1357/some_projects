

#include <iostream>
#include <map>
#include <set>

using namespace std;

long long a, b, start, last;
char color;
set<pair<long long, long long> > whiteSections;
set<pair<long long, long long> >::iterator fir, sec, thir;

void printWhite() {
    set<pair<long long, long long> >::iterator it;
    it = whiteSections.begin();
    cout << "ARRAY: ";
    while(it != whiteSections.end()) {
        cout << "[" << it->first << ", " << it->second << "] ";
        it++;
    }
    cout << endl;
}

int main() {

    set<pair<long long, long long> >::iterator iterat, tx;

    long long white = 0;

    cin >> a;
    cin >> b;
    pair<long long, long long> p1, p2;
    p1 = make_pair(-1, -1);
    p2 = make_pair(a + 1, a + 1);
    whiteSections.insert(p1);
    whiteSections.insert(p2);
    set<pair<long long, long long> >::iterator iter, temp, tmp;
    long long temporary;
    long long a1, a2, b1, b2;

    for (int i = 0; i < b; i++) {

        cin >> start;
        cin >> last;
        cin >> color;

        p1 = make_pair(start, last); // to mój przedział do wstawienia

        if (color == 'B') {
            iter = whiteSections.lower_bound(p1);
            iter--;
            
            if (start > iter->second) {
                iter++;
                while (iter->second <= last) {
                    temp = iter;
                    iter++;
                    white -= (temp->second - temp->first + 1);
                    whiteSections.erase(temp);
                }
                if (iter->first <= last) {
                    p1 = make_pair(start, iter->second);
                    white -= (iter->second - iter->first + 1);
                    whiteSections.erase(iter);

                    whiteSections.insert(p1);
                    white += (get<1>(p1) - get<0>(p1) + 1);
                } else {
                    p1 = make_pair(start, last);
                    whiteSections.insert(p1);
                    white += (get<1>(p1) - get<0>(p1) + 1);
                }

            } else {
                if (iter->second < last) {
                    start = iter->first;
                    if (iter->second > last) {
                        last = iter->second; //podwojna operacja, najwyzej zmeinic
                    } else {
                        temp = iter;
                        iter++;
                        white -= (temp->second - temp->first + 1);
                        whiteSections.erase(temp);
                        while (iter->second <= last) {
                            temp = iter;
                            iter++;
                            white -= (temp->second - temp->first + 1);
                            whiteSections.erase(temp);
                        }
                        if (iter->first <= last) {
                            last = iter->second;
                            white -= (iter->second - iter->first + 1);
                            whiteSections.erase(iter);
                        }
                        p1 = make_pair(start, last);
                        white += (get<1>(p1) - get<0>(p1) + 1);
                        whiteSections.insert(p1);
                    }
                }
            }
        } else {
            // maluje droge na czarno
            iter = whiteSections.lower_bound(p1);
            iter--;
            if (start > iter->second) {
                iter++;

                while (iter->second <= last) {
                    tmp = iter;
                    iter++;
                    white -= (tmp->second - tmp->first + 1);
                    whiteSections.erase(tmp);
                }
                if (iter->first <= last) {
                    start = last;
                    last = iter->second;
                    white -= (iter->second - iter->first + 1);
                    whiteSections.erase(iter);
                    white += (last - start);
                    whiteSections.insert(make_pair(start + 1, last));
                }
            } else {
                if (iter->second <= last) {
                    temporary = start;
                    start = iter->first;
                    temp = iter;
                    iter++;
                    white -= (temp->second - temp->first + 1);
                    whiteSections.erase(temp);
                    white += (temporary - start);
                    whiteSections.insert(make_pair(start, temporary - 1));
                    while (iter->second <= last) {
                        temp = iter;
                        iter++;
                        white -= (temp->second - temp->first + 1);
                        whiteSections.erase(temp);
                    }
                    if (iter->first <= last) {
                        start = last;
                        last = iter->second;
                        white -= (iter->second - iter->first + 1);
                        whiteSections.erase(iter);
                        white += (last - start);
                        whiteSections.insert(make_pair(start + 1, last));
                    }
                } else {
                    a1 = iter->first;
                    a2 = start;
                    b1 = last;
                    b2 = iter->second;
                    white -= (iter->second - iter->first + 1);
                    whiteSections.erase(iter);
                    white += (a2 - a1);
                    white += (b2 - b1);
                    whiteSections.insert(make_pair(a1, a2 - 1));
                    whiteSections.insert(make_pair(b1 + 1, b2));
                }
            }
        }

        cout << white << endl;
    }

}
