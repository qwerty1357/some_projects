#include <iostream>
#include <cstdio>

using namespace std;

long long Q[300005][4]; // queries
char C[300005];    // letters
long long p = 97;
const long long M = 1000000009;
long long H[300005];  //hashes
long long P[300005];  // powers
long long first, last;


void fill_powers(long long n) {
  P[0] = 1;
  for (int i = 1; i <= n; i++) {
    P[i] = (P[i - 1] * p) % M;
  }
}

void create_hashes(long long n) {
  H[0] = 0;
  for (int i = 1; i <= n; i++) {
    H[i] = (H[i - 1] + C[i] * P[i]) % M;
  }
}


bool equal(int a1, int b1, int a2, int b2) {
  long long word1 = (H[b1] - H[a1 - 1])% M;

  long long word2 = (H[b2] - H[a2 - 1])% M;

  int l1 = b1 - a1;
  int l2 = b2 - a2;

  if (l1 != l2) {
    return false;
  } else {
    if (a1 <= a2) {
      word1 = (word1 * P[a2 - a1]) % M;
    } else {
      word2 = (P[a1 - a2] * word2) % M;
    }
  }
  if (word1 < 0) {
    word1 += M;
  }

  if (word2 < 0) {
    word2 += M;
  }

  return word2 == word1;
}

void compare(int a1, int b1, int a2, int b2) {
  bool f = false;
  bool s = false;
  long long d;
  if (equal(a1, b1, a2, b2)) {
    printf("=\n");
    return;
  } else {
    first = 0;
    if (b1 - a1 < b2 - a2) {
      last = b1 - a1;
      f = true;
    } else if (b1 - a1 > b2 - a2) {
      last = b2 - a2;
      s = true;
    } else {
      last = b1 - a1;
    }
    d = (first + last) / 2;
    while (first != last) {
      if (equal(a1, a1 + d, a2, a2 + d)) {
        first = d + 1;
      } else {
        last = d;
      }
      d = (first + last) / 2;
    }

    if (C[a1 + last] < C[a2 + last]) {
      printf("<\n");
      return;
    }
    if (C[a1 + last] == C[a2 + last]) {
      if (s)  {
        printf(">\n");
        return;
      }
      if (f) {
        printf("<\n");
        return;
      }
    }
    if (C[a1 + last] > C[a2 + last]) {
      printf(">\n");
      return;
    }
  }
}



int main() {
  long long n, m;
  scanf("%lld\n", &n);
  scanf("%lld\n", &m);
  H[0] = 0;
  P[0] = 1;

  for (int i = 1; i <= n; i++) {
    scanf("%c\n", &C[i]);
  }

  for (int i = 1; i <= m; i++) {
    scanf("%lld\n %lld\n %lld\n %lld\n", &Q[i][0], &Q[i][1], &Q[i][2], &Q[i][3]);
  }

  fill_powers(n);
  create_hashes(n);

  for (int i = 1; i <= m; i++) {
    compare(Q[i][0], Q[i][1], Q[i][2], Q[i][3]);
  }


}
