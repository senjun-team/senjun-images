#!/bin/bash

# parse flags - single letters prefixed with hyphen before each argument
# example: sh run.sh -c never -j 4

color="never"
file=""
task_type="code"

while getopts c:f:v: flag
do
    case "${flag}" in
        c) color=${OPTARG};;
        f) file=${OPTARG};;
        v) task_type=${OPTARG};;
    esac
done

stack_additional_opts="--verbosity warn"
stack_test_additional_opts=""

if [ -n "${color}" ];
then
    stack_additional_opts="${stack_additional_opts} --color ${color}"
    # stack test colored by default
    stack_test_additional_opts="${stack_test_additional_opts} --no-color"
fi

f="$(basename -- $file)"
f_capture="/tmp/capture.txt"

# if grep not find `module Main` in the user code - than it is the new style of tests
new_task_type=0
grep "module Main" -q "${HOME}/task/$f" || new_task_type=1

# TODO it's suspicious that only "code" type of task
# and if it is not "code" user code is ok by default
if [ $task_type = "code" ]; then
    project_dir="${HOME}/user-code"
    build_command="stack build ${stack_additional_opts}"
    # old test approach for tasks is all the Main module and it's output is
    # parsed by python
    if [ ${new_task_type} -eq 0 ]; then
        cp "${HOME}/task/$f" "${project_dir}/app/Main.hs"
        cd ${project_dir}
        # we need to build explicitly to pass additional options, like color
        if ! ( timeout 10s stack run ${stack_additional_opts} | tee $f_capture ); then
            echo user_solution_error_f936a25e
            exit
        fi
        echo user_code_ok_f936a25e
        # run analyze of the output
        timeout 5s python3 "${HOME}/task/${f}_tests" $f_capture
        if [ "$?" -ne 0 ]; then
            echo tests_cases_error_f936a25e
            exit
        fi
        echo user_solution_ok_f936a25e
    # for new approach we use usercode as library which is mouted to the project
    else
        cp "${HOME}/task/$f" "${project_dir}/src/UserCode.hs"
        cp "${HOME}/task/${f}_tests" "${project_dir}/test/Spec.hs"
        # go to /home/code_runner/user_code for stack compiling and running
        cd ${project_dir}
        if ! (timeout 10s ${build_command}); then
            echo user_solution_error_f936a25e
            exit
        fi
        echo user_code_ok_f936a25e
        if ! (timeout 10s stack test ${stack_additional_opts} --progress-bar=none --test-arguments="${stack_test_additional_opts}"); then
            echo tests_cases_error_f936a25e
            exit
        fi
        echo user_solution_ok_f936a25e
    fi
else # TODO REFACTOR
    # run tests
    timeout 10s python3 "/home/code_runner/task/${f}_tests" $f_capture
    if [ "$?" -ne 0 ]; then
        echo tests_cases_error_f936a25e
        exit
    fi

    echo user_solution_ok_f936a25e
fi
