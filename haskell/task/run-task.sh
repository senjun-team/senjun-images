#!/bin/bash

# parse flags - single letters prefixed with hyphen before each argument
# example: sh run.sh -c never -j 4
while getopts c:f:v: flag
do
    case "${flag}" in
        c) color=${OPTARG};;
        f) file=${OPTARG};;
        v) task_type=${OPTARG};;
    esac
done

cabal_additional_opts=""

# disable color for output for build systems that cannot accept it
if [ ! -z "$color" ];
then
    cabal_additional_opts="${cabal_additional_opts} -fdiagnostics-color=${color}"
fi

f="$(basename -- $file)"

f_capture="/tmp/capture.txt"
rm $f_capture > /dev/null 2>&1

# TODO it's suspicious that only "code" type of task
# and if it is not "code" user code is ok by default

# if exists file with user code
# run user code
if [ $task_type = "code" ]; then
    cp /home/code_runner/task/$f /home/code_runner/user-code/app/Main.hs

    # go to /home/code_runner/user_code for cabal compiling and running
    cd /home/code_runner/user-code

    if ! ( timeout 10s cabal build $cabal_additional_opts --ghc-options '-fno-warn-missing-export-lists -Wno-type-defaults' && cabal exec user-code-exe  | tee $f_capture ); then
        echo user_solution_error_f936a25e
        exit
    fi
fi
echo user_code_ok_f936a25e

# run tests
timeout 10s python3 "/home/code_runner/task/${f}_tests" $f_capture
if [ "$?" -ne 0 ]; then
    echo tests_cases_error_f936a25e
    exit
fi

echo user_solution_ok_f936a25e
