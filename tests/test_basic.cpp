#include "hello.h"

#include <gtest/gtest.h>

TEST(HelloTest, BasicAddition) {
    EXPECT_EQ(hello::add(2, 3), 5);
}
