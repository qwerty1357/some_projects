#include <iostream>
#include <string>
#include <stdio.h>

int main() {
    std::string paper = "";
    std::cin>>paper;
    int x = 0;
    int difference = 0;
    int d = paper.size(); char color; int colorIndex = 0; int i = 0;
    if (d <= 1) {
        std::cout << d << "\n";
        return 0;
    }
    else {
        color = paper[0];
        colorIndex = 0;
        if (paper[0] == '*') {
            while ((i < d) && (paper[i] == '*'))
                i++;
            if (i == d) {
                std::cout << "1\n";
                return 0;
            }
            else {
                color = paper[i];
                colorIndex = i;
            }
        }
        difference = d;
        if (i < d) {
            while (i < d) {
                if (paper[i] != color) {
                    if (paper[i] != '*') {
                        if (difference > i - colorIndex) {
                            difference = i - colorIndex;
                        }
                        colorIndex = i;
                        color = paper[i];
                    }
                }
                else
                    colorIndex = i;
                i++;
            }
        }
        else {
            d = 0;
            difference = 0;
        }
    }
    x = d - difference + 1;
    printf("%d\n", x);
    i = 0;
    return 0;
}
