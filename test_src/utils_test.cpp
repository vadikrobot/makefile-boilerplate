#include "utils.h"
#include "catch.hpp"

TEST_CASE("Utils", "Split String")
{
    {
        REQUIRE(split("  select   from kek limit pek ") == std::vector<std::string>{"select", "from", "kek", "limit", "pek"});
        REQUIRE(split(",select,from kek,limit pek", ',') == std::vector<std::string>{"select", "from kek", "limit pek"});
    }
}
