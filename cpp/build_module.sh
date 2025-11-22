#!/bin/bash
set -e

MOD_DIR="/usr/local/lib"
CXX_CMD="clang++ -std=c++23 -stdlib=libc++ -O3"

# build_module <module_name> <source_file> [dependencies...]
build_module() {
    local module_name="$1"
    local source_file="$2"
    local dependencies=("${@:3}")
    
    local pcm_file="$MOD_DIR/${module_name}.pcm"
    local obj_file="$MOD_DIR/${module_name}.o"
    
    echo "Building module: $module_name"
    
    local dep_flags=""
    for dep in "${dependencies[@]}"; do
        dep_flags+=" -fmodule-file=${dep}=$MOD_DIR/${dep}.pcm"
		dep_flags+=" $MOD_DIR/${dep}.o"
    done
    
    # *.cppm -> *.pcm
    $CXX_CMD --precompile $dep_flags -o "$pcm_file" "$source_file"
    # *.pcm  -> *.o
    $CXX_CMD -c $dep_flags -o "$obj_file" "$pcm_file"
    
    echo "Module $module_name built successfully: $pcm_file, $obj_file"
}

mkdir -p "$MOD_DIR"
build_module "$1" "$2" ${@:3}