#include <iostream>

using namespace std;

const long long RANGE = 40002;
long long T[RANGE];

const long long MLD = 1000000000;

int main() {
    long long var, a, b, k, val, n, res, result = 0;
    cin >> n;
    cin >> k;

    int Inw[k + 1][n];
    long long data[n];

    for (long long i = 2; i < k + 1; i++)
        for (long long j = 0; j < n; j++)
            Inw[i][j] = 0;
    for (long long i = 0; i < n; i++)
        Inw[1][i] = 1;
    for (long long i = 0; i < n; i++)
        cin >> data[i];

    for (long long i = 2; i < k + 1; i++) {
        for (long long j = 0; j <= RANGE; j++)
            T[j] = 0;
        for (long long j = 0; j < n; j++) {
            b = n + data[j];
            var = b - 1;
            T[var] = T[var] + Inw[i - 1][j];
            while (var != 1) {
                var = var / 2;
                val = var * 2;
                T[var] = T[val] + T[val + 1];
            }
            a = b;
            b = 2 * n;
            res = T[a];
            if (a != b)
                res = res + T[b];
            result = a / 2;
            var = b / 2;
            while (result != var) {
                if (!(a % 2))
                    res = res + T[a + 1];
                if (b % 2)
                    res = res + T[b - 1];
                a = result;
                b = var;
                result = result / 2;
                var = var / 2;
            }
            Inw[i][j] = res % MLD;
        }
    }
    result = 0;
    for (long long i = 2; i < n; i++)
        result = result + Inw[k][i];

        printf("%lld\n", result % MLD);
}
