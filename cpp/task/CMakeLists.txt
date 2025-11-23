cmake_minimum_required(VERSION 3.30)
project(code_runner LANGUAGES CXX)

# Настройки окружения
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
# Для цветного вывода логов
set(CMAKE_COLOR_DIAGNOSTICS ON)

# Глобальные настройки компилятора
link_libraries(-lc++)
add_compile_options(
    -stdlib=libc++
    -Werror
    -Wall
    -Wno-unused-variable
    -Wno-logical-op-parentheses
    -O3
)

# Подключение модулей
include(precompiled_modules.cmake)

# Сборка main при наличии
if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/main.cpp")
    add_executable(main main.cpp)
    target_link_libraries(main PUBLIC std_module)
endif()

# Запуск тестов
add_executable(tests tests.cpp)
target_link_libraries(tests PUBLIC test_modules)
