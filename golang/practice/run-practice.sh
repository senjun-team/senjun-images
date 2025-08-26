#!/usr/bin/env bash

# parse flags - single letters prefixed with hyphen before each argument
# example: sh run.sh -f task
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

# prepare project
f="$(basename -- $project)"
cd /home/code_runner/practice/$f/cmd 

# we call gofmt to prevent compiler errors:
# go compiler treats formatting errors as compilation errors!

# TODO: format go code in online IDE to show user the right way
# timeout 5s gofmt -s -w .

if [ ${run+x} ]; then
  # run cpp project
  # TODO which name for project should use here?

  if ! ( timeout 10s go run . ); then
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
  if ! ( timeout 10s go test . ); then
   echo "Tests execution timeout"
   echo tests_cases_error_f936a25e
   exit
  fi

  echo user_solution_ok_f936a25e
  exit
fi

# Never goes here
echo "Never should go here!"