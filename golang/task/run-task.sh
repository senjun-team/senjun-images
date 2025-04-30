#!/usr/bin/env bash

# parse flags - single letters prefixed with hyphen before each argument
# example: sh run.sh -f task
while getopts f:c:v: flag
do
    case "${flag}" in
        f) file=${OPTARG};;
        v) task_type=${OPTARG};;
        c) color=${OPTARG};;
    esac
done

cd /home/code_runner/task/user-code

# if exists file with user code
if [ $task_type = "code" ]; then
    # prepare project
    f="$(basename -- $file)"
    cp /home/code_runner/task/$f /home/code_runner/task/user-code/main.go

    # we call gofmt to prevent compiler errors:
    # go compiler treats formatting errors as compilation errors!

    # TODO: format go code in online IDE to show user the right way
    timeout 5s gofmt -w main.go

    # build and run user code
    if ! ( timeout 10s go run . ); then
        echo user_solution_error_f936a25e
        exit
    fi
fi

echo user_code_ok_f936a25e

# build and run tests 
f="$(basename -- ${file}_tests)"
cp /home/code_runner/task/$f /home/code_runner/task/user-code/main_test.go

# here we don't call gofmt because we rely on the fact that
# the tests are already formatted
if ! ( timeout 10s go test -v); then
   echo tests_cases_error_f936a25e
   exit
fi

echo user_solution_ok_f936a25e
