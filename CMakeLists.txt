cmake_minimum_required(VERSION 3.20)

project(hello LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_library(hello_core STATIC src/hello.cpp)
target_include_directories(hello_core PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/src")

add_executable(hello src/main.cpp)
target_link_libraries(hello PRIVATE hello_core)

install(TARGETS hello RUNTIME DESTINATION bin)

include(FetchContent)

set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
set(BUILD_GMOCK OFF CACHE BOOL "" FORCE)

FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.17.0.zip
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_MakeAvailable(googletest)

enable_testing()

add_executable(hello_tests tests/test_basic.cpp)
target_link_libraries(hello_tests PRIVATE hello_core GTest::gtest_main)

include(GoogleTest)
gtest_discover_tests(hello_tests)
