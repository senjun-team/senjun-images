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
cp /home/code_runner/practice/ut.hpp /home/code_runner/practice/$f

# configure project
if ! ( timeout 10s cmake -Bbuild -Wno-dev -GNinja > /tmp/configure.txt ); then
   echo "Configure error"
   cat /tmp/configure.txt
   echo user_solution_error_f936a25e
   exit
fi

# build cpp project
if ! ( timeout 20s cmake --build build/ -- -j4  > /tmp/build.txt ); then
   echo "Build error"
   cat /tmp/build.txt
   echo user_solution_error_f936a25e
   exit
fi


if [ ${run+x} ]; then
  # run cpp project
  # TODO which name for project should use here?
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
