#!/usr/bin/env bash

# parse flags - single letters prefixed with hyphen before each argument
# example: sh run.sh -f task
while getopts f:v:c: flag
do
    case "${flag}" in
        f) file=${OPTARG};;
        v) task_type=${OPTARG};;
        c) color=${OPTARG};;
    esac
done

# go to the task dir
cd /home/code_runner/task

# if exists file with user code
if [ $task_type = "code" ]; then
   touch main.cpp
   cp $file main.cpp
fi

cp ${file}_tests tests.cpp

# configure project
if ! ( timeout 10s cmake -Wno-dev -Bbuild -GNinja > /tmp/configure.txt ); then
   cat /tmp/configure.txt
   echo user_solution_error_f936a25e
   exit
fi

if [ ! -z "$color" ];
then
   SET_COLOR=$(tput setaf 2) # Set text color to green
   RESET_ALL=$(tput sgr0)  # Reset all
   CLICOLOR_FORCE_VAL=1
else
   SET_COLOR=""
   RESET_ALL=""
   CLICOLOR_FORCE_VAL=0
fi


# build cpp project
# --quiet option is for ninja to suppress build steps output
if ! ( CLICOLOR_FORCE=$CLICOLOR_FORCE_VAL timeout 30s cmake --build build/ -- -j4   --quiet > /tmp/compile.txt ); then
   cat /tmp/compile.txt
   echo user_solution_error_f936a25e
   exit
fi

if [ $task_type = "code" ]; then
   if ! ( timeout 4s ./build/main ); then
      echo user_solution_error_f936a25e
      exit
   fi

   if [ -s /tmp/compile.txt ]; then
      echo ""
      echo "${SET_COLOR}Compiler warnings:${RESET_ALL}"
      cat /tmp/compile.txt
      echo ""
   fi
fi

echo user_code_ok_f936a25e

if [ $task_type = "code" ]; then
   if ! ( timeout 4s ./build/tests ); then
      echo tests_cases_error_f936a25e
      exit
   fi
else # check task "what will this code output?"
   if ! ( timeout 4s ./build/tests 1> /dev/null 2> /tmp/message.txt ); then
      cat /tmp/message.txt
      echo tests_cases_error_f936a25e
      exit
   fi
fi


echo user_solution_ok_f936a25e