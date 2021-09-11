#include <iostream>

#include "utils.h"

int main () {
    for (const auto& s : split("kek pek")) {
        std::cout << s << "\n";
    }
}