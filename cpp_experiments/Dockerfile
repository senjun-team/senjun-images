FROM silkeh/clang:20

RUN apt-get update \
    && apt install -y ninja-build \
    xxd strace \
    vim nano emacs neovim \
    && apt-get purge -y cmake

ARG CMAKE_VERSION=3.31.2

RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
    -q -O /tmp/cmake-install.sh \
    && chmod u+x /tmp/cmake-install.sh \
    && mkdir /usr/bin/cmake \
    && /tmp/cmake-install.sh --skip-license --prefix=/usr/bin/cmake \
    && rm /tmp/cmake-install.sh

ENV PATH="/usr/bin/cmake/bin:${PATH}"

RUN useradd -ms /bin/bash code_runner && chown -R code_runner:code_runner /usr/local/lib/
USER code_runner
WORKDIR /home/code_runner

ENTRYPOINT ["bash"]
