#include <iostream>

using namespace std;

typedef struct field {
    long price;
    long long sum;
    long lastEven;
    long lastOdd;
    long nextEven;
    long nextOdd;
} field;

int main() {
    int prodNumb;
    int dayProdNumb;
    long days;
    scanf("%d\n", &prodNumb);
    field A[prodNumb];
    for (int i = prodNumb - 1; i >= 0; i--) {
        scanf("%ld\n", &A[i].price);
    }
    A[0].sum = A[0].price;
    for (int i = 1; i < prodNumb; i++) {
        A[i].sum = A[i - 1].sum + A[i].price;
    }
    long lastEven = -1;
    long lastOdd = -1;
    for (int i = 0; i < prodNumb; i++) {
        A[i].lastEven = lastEven;
        A[i].lastOdd = lastOdd;
        if (A[i].price%2 == 0) {
            lastEven = A[i].price;
        } else {
            lastOdd = A[i].price;
        }
    }
    long nextEven = -1;
    long nextOdd = -1;
    for (int i = prodNumb - 1; i >= 0; i--) {
        A[i].nextEven = nextEven;
        A[i].nextOdd = nextOdd;
        if (A[i].price%2 == 0)
            nextEven = A[i].price;
        else
            nextOdd = A[i].price;
    }

    long max1, max2;
    scanf("%ld\n", &days);
    for (int i = 0; i < days; i++) {
        scanf("%d\n", &dayProdNumb);
        if (A[dayProdNumb - 1].sum%2 == 1) {
            printf("%lld\n", A[dayProdNumb - 1].sum);
        } else {
            max1 = -1;
            max2 = -1;
            if (A[dayProdNumb - 1].price%2 == 0) {
                if (A[dayProdNumb - 1].nextOdd != -1) {
                    max1 = A[dayProdNumb - 1].price - A[dayProdNumb - 1].nextOdd;
                }
                if ((A[dayProdNumb - 1].lastOdd != -1) && (A[dayProdNumb - 1].nextEven != -1)) {
                    max2 = A[dayProdNumb - 1].lastOdd - A[dayProdNumb - 1].nextEven;
                }
            }
            else {
                if (A[dayProdNumb - 1].nextEven != -1)
                    max1 = A[dayProdNumb - 1].price - A[dayProdNumb - 1].nextEven;
                if ((A[dayProdNumb - 1].lastEven != -1) && (A[dayProdNumb - 1].nextOdd != -1))
                    max2 = A[dayProdNumb - 1].lastEven - A[dayProdNumb - 1].nextOdd;
            }
            if ((max1 == -1) && (max2 == -1))
                printf("-1\n");
            else {
                if (max1 > max2)
                    if (max2 != -1) {
                        printf("%lld\n", A[dayProdNumb - 1].sum - max2);
                    } else {
                        printf("%lld\n", A[dayProdNumb - 1].sum - max1);
                    }
                else {
                    if (max1 != -1) {
                        printf("%lld\n", A[dayProdNumb - 1].sum - max1);
                    }
                    else {
                        printf("%lld\n", A[dayProdNumb - 1].sum - max2);
                    }
                }
            }
        }
    }
}
