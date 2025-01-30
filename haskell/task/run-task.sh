#!/bin/bash

# parse flags - single letters prefixed with hyphen before each argument
# example: sh run.sh -c never -j 4

while getopts c:f:v: flag
do
    case "${flag}" in
        c) color=${OPTARG};;
        f) file=${OPTARG};; # most of time it is a "wrapper" string
        v) task_type=${OPTARG};;
    esac
done

stack_additional_opts="--verbosity warn"

if [ ! -z "${color}" ];
then
    stack_additional_opts="${stack_additional_opts} --color ${color}"
fi

f="$(basename -- $file)"

f_capture=$(mktemp -t usertask-XXXXXXXX)


# if grep not find `module Main` in the user code - than it is the new style of tests
new_task_type=0
grep "module Main" -q "${HOME}/task/$f" || new_task_type=1

# TODO it's suspicious that only "code" type of task
# and if it is not "code" user code is ok by default
if [ $task_type = "code" ]; then
    project_dir="${HOME}/user-code"
    # we need to build explicitly to pass additional options, like color
    # TODO: maybe we can inject it the stack.yaml?
    build_command="stack build ${stack_additional_opts}"
    # old test approach for tasks is all the Main module and it's output is
    # parsed by python
    if [[ ${new_task_type} -eq 0 ]]; then
        cp "${HOME}/task/$f" "${project_dir}/app/Main.hs"
        # just to the test project to run all that staff
        cd ${project_dir}
        if ! ( timeout 1000s ${build_command} && stack run | tee $f_capture ); then
            echo user_solution_error_f936a25e
            exit
        fi
        echo user_code_ok_f936a25e
        # run analyze of the output
        timeout 10s python3 "${HOME}/task/${f}_tests" $f_capture
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
        if ! (timeout 1000s ${build_command} && stack test --test-arguments="-f machine" | tee $f_capture ); then
            echo user_solution_error_f936a25e
            exit
        fi
        echo user_code_ok_f936a25e
        echo user_solution_ok_f936a25e
    fi
fi
