# cmake 3.31.6 and clang 20.1.8
FROM ubuntu:26.04

# Set environment variables to avoid interactive prompts and set locale
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Updatе packages and install base system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    clang \
    clang-tools \
    libc++-dev \
    libgtest-dev \
    ninja-build \
    cmake \
    wget \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create symlink for clang-scan-deps (used for C++ module dependency scanning)
RUN ln -s /usr/lib/llvm*/bin/clang-scan-deps clang-scan-deps

# Create user for security
RUN useradd --create-home --shell /bin/bash code_runner \
    && mkdir -p /home/code_runner/{task,practice,playground} \
    && chown -R code_runner:code_runner /home/code_runner \
    && chmod -R 1750 /home/code_runner

# Download and extract Google Benchmark library
RUN mkdir -p /third_party/google/ \
    && wget -q -O /tmp/benchmark.zip https://github.com/google/benchmark/archive/refs/tags/v1.9.4.zip \
    && unzip /tmp/benchmark.zip -d /third_party/google/ \
    && rm /tmp/benchmark.zip

# Build precompiled C++ modules
COPY build_module.sh task/ut.cppm task/test_helpers.cppm ./
RUN chmod +x ./build_module.sh  \
    && ./build_module.sh std /usr/lib/llvm*/share/libc++/v1/std.cppm \
    && ./build_module.sh boost.ut ut.cppm std \
    && ./build_module.sh TestHelpers test_helpers.cppm std

# Copy workspace directories
COPY --chown=code_runner:code_runner task/ /home/code_runner/task/
COPY --chown=code_runner:code_runner playground/ /home/code_runner/playground/
COPY --chown=code_runner:code_runner practice/ /home/code_runner/practice/

# Switch to non-privileged user
USER code_runner
WORKDIR /home/code_runner
RUN chown -R code_runner:code_runner /home/code_runner/playground/project/

ENTRYPOINT ["/bin/bash"]
