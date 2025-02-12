cmake_minimum_required(VERSION 3.30.0 FATAL_ERROR)

set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(STD_MODULE_FILE /usr/local/lib/std.pcm)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -Werror -Wall -O2 -fmodule-file=std=${STD_MODULE_FILE}")

project(cpp_experiments LANGUAGES CXX)

add_executable(cpp_experiments main.cpp)


