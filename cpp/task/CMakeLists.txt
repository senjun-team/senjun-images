cmake_minimum_required(VERSION 3.30.0 FATAL_ERROR)

project(task LANGUAGES CXX)

set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(STD_MODULE_FILE /usr/local/lib/std.pcm)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -Werror -Wall -Wno-unused-variable -Wno-logical-op-parentheses -O2 -fmodule-file=std=${STD_MODULE_FILE}")


IF (EXISTS "/home/code_runner/task/main.cpp")
    add_executable(main main.cpp)
ENDIF()

add_executable(tests)

target_sources(tests
    PUBLIC
    tests.cpp
)

target_sources(tests
    PUBLIC
    FILE_SET senjun_modules TYPE CXX_MODULES FILES
    ut.cppm
    test_helpers.cppm
)