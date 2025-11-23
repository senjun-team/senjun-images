#!/usr/bin/env bash

# parse flags - single letters prefixed with hyphen before each argument
# example: sh run.sh -f project_dir
while getopts f: flag
do
    case "${flag}" in
        f) project=${OPTARG};;
    esac
done

f="$(basename -- $project)"

mkdir -p /home/code_runner/playground/$f
cd /home/code_runner/playground/$f

# configure project
if ! ( timeout 5s cmake -Bbuild -Wno-dev -GNinja > /tmp/configure.txt ); then
   cat /tmp/configure.txt
   echo user_solution_error_f936a25e
   exit
fi

SET_COLOR=$(tput setaf 2) # Set text color to green
RESET_ALL=$(tput sgr0)  # Reset all

# build cpp project
# --quiet option is for ninja to suppress build steps output
if ! ( CLICOLOR_FORCE=1 timeout 10s cmake --build build/ -- -j4 --quiet > /tmp/compile.txt ); then
   echo "${SET_COLOR}Compiler errors:${RESET_ALL}"
   cat /tmp/compile.txt
   echo user_solution_error_f936a25e
   exit
fi

if [ -s /tmp/compile.txt ]; then
   echo "${SET_COLOR}Compiler warnings:${RESET_ALL}"
   cat /tmp/compile.txt
   echo ""
fi

echo "${SET_COLOR}Console output:${RESET_ALL}"

# run cpp project
if ! ( timeout 5s ./build/cpp_experiments ); then
   echo user_solution_error_f936a25e
   exit
fi

echo user_solution_ok_f936a25e
