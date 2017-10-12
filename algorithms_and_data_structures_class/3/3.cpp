#include <iostream>
using namespace std;

int M = 1000000000;

int main() {

    long a;
    long long n;
    scanf("%lld", &n);
    long A[n][n];
    long B[n][n];
    long C[n];

    int y;
    for (int i = 1; i <= n; i++) {
      scanf("%ld", &a);
      C[i - 1] = a;
      for (int j = 0; j <= n-i; j++) {
          y = i + j - 1;
          A[j][y] = 0;
          B[j][y] = 0;
      }
    }
    int s;
    for (int i = 0; i < n; i++)
        B[i][i] = 1;
    for (int h = 2; h <= n; h++) {
        for (int x = 0; x <= n - h; x++) {
            s = h + x - 1;
            if (C[x] < C[x + 1])
                A[x][s] = A[x][s] + (A[x + 1][s]) % M;
            A[x][s] = A[x][s] % M;

            if (C[s - 1] < C[s])
                B[x][s] = B[x][s] + (B[x][s - 1]) % M;
            B[x][s] = B[x][s] % M;
            if (C[x] < C[s]) {
                A[x][s] = A[x][s] + (B[x + 1][s]) % M;
                B[x][s] = B[x][s] + (A[x][s - 1]) % M;
            }
            A[x][s] = A[x][s] % M;
            B[x][s] = B[x][s] % M;
        }
    }
    n = (A[0][n - 1] + B[0][n - 1])%M;
    printf("%lld\n", n);
}
