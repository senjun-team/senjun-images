FROM silkeh/clang:20
LABEL ru.senjun.image.authors="Shipilov Dmitry"

RUN apt-get update \
    && apt install -y unzip libgtest-dev \
    && apt install -y ninja-build \
    && apt-get purge -y cmake

ARG CMAKE_VERSION=3.31.2

RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
    -q -O /tmp/cmake-install.sh \
    && chmod u+x /tmp/cmake-install.sh \
    && mkdir /usr/bin/cmake \
    && /tmp/cmake-install.sh --skip-license --prefix=/usr/bin/cmake \
    && rm /tmp/cmake-install.sh

ENV PATH="/usr/bin/cmake/bin:${PATH}"

# make precompiled module for std
RUN clang \
      -std=c++23 \
      -O3 \
      -nostdinc++ \
      -isystem /usr/lib/llvm-20/include/c++/v1/ \
      -Wno-reserved-module-identifier \
      -Wno-reserved-user-defined-literal \
      --precompile \
      -o /usr/local/lib/std.pcm \
      /usr/lib/llvm-20/share/libc++/v1/std.cppm

WORKDIR /home/code_runner

RUN mkdir -p /third_party/google/ && cd /third_party/google/ \
    && wget https://github.com/google/benchmark/archive/refs/tags/v1.9.4.zip \
    -q -O benchmark.zip \
    && unzip benchmark.zip \
    && rm benchmark.zip && cd /home/code_runner/

# Directory for task launching
RUN mkdir /home/code_runner/task 

# ut.hpp: https://github.com/boost-ext/ut?tab=readme-ov-file
COPY task/run-task.sh task/CMakeLists.txt task/ut.cppm task/test_helpers.cppm /home/code_runner/task/

# Directory for playground
RUN mkdir /home/code_runner/playground 
COPY playground/run-playground.sh /home/code_runner/playground

# Directory for practice
RUN mkdir /home/code_runner/practice 
COPY practice/run-practice.sh task/ut.cppm task/test_helpers.cppm /home/code_runner/practice/

# Change access write for code_runner home directory to root recursively
RUN useradd -ms /bin/bash code_runner \
    && chown -R code_runner:code_runner /home/code_runner \
    && chmod -R 1750 /home/code_runner

USER code_runner

ENTRYPOINT ["bash"]
