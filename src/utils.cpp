#include "utils.h"

std::vector<std::string> split(const std::string& str, char space) {
    std::vector<std::string> result;
    auto is_space = [&space](const char& c) { return c == space; };

    auto begin = str.cbegin();
    while (begin != str.cend()) {
        begin = std::find_if_not(begin, str.cend(), is_space);
        auto it = std::find_if(begin, str.cend(), is_space);
        if (begin != str.cend()) {
            result.push_back(std::string(begin, it));
        }
        begin = it;
    }
    return result;
}
