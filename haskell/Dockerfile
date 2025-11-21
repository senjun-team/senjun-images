FROM haskell:9.12

RUN apt-get -y update \
    && apt-get -y install python3

WORKDIR /home/code_runner

# Directory for task launching
RUN mkdir /home/code_runner/task
RUN mkdir -p /home/code_runner/.config/cabal
COPY config /home/code_runner/.config/cabal/config

COPY task/run-task.sh /home/code_runner/task

COPY user-code /home/code_runner/user-code

# Directory for task launching
RUN mkdir /home/code_runner/playground 
COPY playground/run-playground.sh /home/code_runner/playground

# Change access write for code_runner home directory to root recursively
RUN useradd -ms /bin/bash -u 1000 code_runner \
    && chown -R code_runner:code_runner /home/code_runner \
    && chmod -R 1750 /home/code_runner 

USER code_runner

RUN cd /home/code_runner/user-code && cabal update 
RUN cd /home/code_runner/user-code && cabal build test

ENTRYPOINT ["bash"]
