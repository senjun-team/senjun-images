#!/usr/bin/env bash
set -e

# main goes here

# column after option means required argument
while getopts f:p:o:rt opt
do
    case "${opt}" in
        f) project=${OPTARG}
          ;;
        o) user_options="${OPTARG}"
          ;;
        p) main_path=${OPTARG}
          ;;
        r) run=${OPTARG}
          ;;
        t) test=${OPTARG}
          ;;
        \?) echo "Invalid option" >&2
          exit
          ;;
    esac
done

f="$(basename -- $project)"

cd /home/code_runner/practice/$f 
cp /home/code_runner/practice/ut.cppm /home/code_runner/practice/$f

# configure project
if ! ( timeout 30s cmake -Bbuild -Wno-dev -GNinja > /tmp/configure.txt ); then
   echo "Configure error"
   cat /tmp/configure.txt
   echo user_solution_error_f936a25e
   exit
fi

SET_COLOR=$(tput setaf 2) # Set text color to green
RESET_ALL=$(tput sgr0)  # Reset all

# --quiet option is for ninja to suppress build steps output
if ! ( CLICOLOR_FORCE=1 timeout 40s cmake --build build/ -- -j4 --quiet > /tmp/compile.txt ); then
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

if [ ${run+x} ]; then
  # run cpp project
  echo "${SET_COLOR}Console output:${RESET_ALL}"
  if ! ( timeout 5s ./build/main $user_options); then
    echo "Code execution timeout"
    echo user_solution_error_f936a25e
    exit
  fi

  echo user_code_ok_f936a25e
  echo user_solution_ok_f936a25e
  exit
fi

# e.g: sh run.sh -f dir_name -t
if [ ${test+x} ]; then
  echo user_code_ok_f936a25e
  echo "${SET_COLOR}Tests output:${RESET_ALL}"
  if ! ( timeout 5s ./build/tests ); then
   echo "Tests execution timeout"
   echo tests_cases_error_f936a25e
   exit
  fi

  echo user_solution_ok_f936a25e
  exit
fi

# Never goes here
echo "Never should go here!"
