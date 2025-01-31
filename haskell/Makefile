all: new_test old_test

.PHONY: image

new_test: image tests/new_approach/user_task tests/new_approach/user_task_tests
	docker run -it \
		-v ./tests/new_approach/user_task:/home/code_runner/task/user_task \
		-v ./tests/new_approach/user_task_tests:/home/code_runner/task/user_task_tests \
		senjun_haskell bash -c "bash task/run-task.sh -v code -f task/user_task"

old_test: image tests/old_approach/user_task tests/old_approach/user_task_tests
	docker run -it \
		-v ./tests/old_approach/user_task:/home/code_runner/task/user_task \
		-v ./tests/old_approach/user_task_tests:/home/code_runner/task/user_task_tests \
		senjun_haskell bash -c "bash task/run-task.sh -v code -f task/user_task"

image: Dockerfile config.yaml package.yaml task/run-task.sh task/MachineFormatter.hs
	docker build -t senjun_haskell .
