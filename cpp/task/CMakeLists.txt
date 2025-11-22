cmake_minimum_required(VERSION 3.30)
project(code_runner LANGUAGES CXX)

# Настройки окружения
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
# Для цветного вывода логов
set(CMAKE_COLOR_DIAGNOSTICS ON)
# Путь к precompiled модулям включая *.pcm и *.o
set(MOD_DIR "/usr/local/lib")

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

# Поиск модуля std
find_file(STD_MODULE_FILE std.pcm PATHS ${MOD_DIR} REQUIRED)
# и сборка main при наличии
find_file(MAIN_CPP_FILE main.cpp PATHS "/home/code_runner/task" NO_DEFAULT_PATH)
if (${MAIN_CPP_FILE})
    add_executable(main ${MAIN_CPP_FILE} ${MOD_DIR}/std.o)
    target_compile_options(main PUBLIC
        -fmodule-file=std=${STD_MODULE_FILE}
    )
endif()

# Поиск модулей для тестов
find_file(UT_MODULE_FILE boost.ut.pcm PATHS ${MOD_DIR} REQUIRED)
find_file(TH_MODULE_FILE TestHelpers.pcm PATHS ${MOD_DIR} REQUIRED)
# и запуск тестов
add_executable(tests tests.cpp ${MOD_DIR}/std.o ${MOD_DIR}/boost.ut.o ${MOD_DIR}/TestHelpers.o)
target_compile_options(tests PUBLIC
    -fmodule-file=std=${STD_MODULE_FILE}
	-fmodule-file=boost.ut=${UT_MODULE_FILE}
    -fmodule-file=TestHelpers=${TH_MODULE_FILE}
)
