# cmake 3.31.6 and clang 21.1.2
FROM ubuntu:26.04

# Set environment variables to avoid interactive prompts and set locale
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Updatе packages and install base system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git \
    clang-21 clang-tools-21 libc++-21-dev \
    cmake ninja-build \
    libgtest-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create symlink for clang-scan-deps (used for C++ module dependency scanning)
# and create symlink for modern clang
RUN ln -s /usr/lib/llvm*/bin/clang-scan-deps /usr/bin/clang-scan-deps && \
    ln -s /usr/bin/clang++* /usr/bin/clang++

# Download and extract libraries
RUN git clone --branch v1.9.4 --depth 1 \
    https://github.com/google/benchmark.git /third_party/google/benchmark && \
    git clone --branch v2.3.1 --depth 1 \
    https://github.com/boost-ext/ut.git /third_party/boost/ut

# Build precompiled C++ modules
COPY build_module.sh task/test_helpers.cppm ./
RUN chmod +x ./build_module.sh  \
    && ./build_module.sh std /usr/lib/llvm*/share/libc++/v1/std.cppm \
    && ./build_module.sh std.compat /usr/lib/llvm*/share/libc++/v1/std.compat.cppm std \
    && ./build_module.sh boost.ut /third_party/boost/ut/include/boost/ut.cppm std \
    && ./build_module.sh TestHelpers test_helpers.cppm std

# Copy workspace directories
COPY task/ /home/code_runner/task/
COPY playground/ /home/code_runner/playground/
COPY practice/ /home/code_runner/practice/

# Create user for security
RUN useradd --create-home --shell /bin/bash code_runner \
    && chown -R code_runner:code_runner /home/code_runner \
    && chmod -R 750 /home/code_runner \

# Switch to non-privileged user
USER code_runner
WORKDIR /home/code_runner

ENTRYPOINT ["/bin/bash"]
