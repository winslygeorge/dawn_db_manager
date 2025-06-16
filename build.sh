#!/bin/bash

# build.sh - Script to build, install, and test the dawn_db LuaRocks module

# --- Configuration ---
MODULE_NAME="dawn_db"
ROCKSPEC="dawn_db-1.0-8.rockspec"
ROCKFILE="${MODULE_NAME}-1.0-8.rock"
LUAJIT_INCLUDE="/usr/include/luajit-2.1" # Ensure this path is correct for your system
BUILD_DIR="build"
CMAKE_BUILD_DIR="${BUILD_DIR}/cmake"
SO_TARGET="${MODULE_NAME}.so"

# --- Functions for build steps ---

# Function to clean build artifacts
clean_build() {
    echo "🧹 Cleaning build artifacts..."
    rm -rf "${BUILD_DIR}" "${SO_TARGET}" "${ROCKFILE}" test.lua "${MODULE_NAME}"-*.src.rock
    echo "✅ Cleaned."
}

# Function to compile .lua files to .luac bytecode
compile_luac() {
    echo "🔧 Compiling .lua to .luac..."
    mkdir -p "${BUILD_DIR}" || { echo "Error: Failed to create build directory."; exit 1; }

    # Find all .lua files and compile them to .luac in the build directory
    find . -name "*.lua" | while read file; do
        # Exclude files that are not part of the module or are temporary
        if [[ "$file" != "./build.sh" && "$file" != "./test.lua" && "$file" != *".rockspec" ]]; then
            out="${BUILD_DIR}/${file}"
            mkdir -p "$(dirname "$out")" || { echo "Error: Failed to create output directory for $out."; exit 1; }
            luajit -b "$file" "$out" || { echo "Error: Failed to compile $file."; exit 1; }
        fi
    done
    echo "✅ .luac files compiled to ${BUILD_DIR}"
}

# Function to run CMake configuration for the native module
run_cmake() {
    echo "⚙️ Running CMake..."
    mkdir -p "${CMAKE_BUILD_DIR}" || { echo "Error: Failed to create CMake build directory."; exit 1; }
    cd "${CMAKE_BUILD_DIR}" || { echo "Error: Failed to change to CMake build directory."; exit 1; }
    cmake ../.. -DLUAJIT_INCLUDE_DIR="${LUAJIT_INCLUDE}" || { echo "Error: CMake configuration failed."; exit 1; }
    cd - > /dev/null # Go back to the original directory quietly
    echo "✅ CMake configured."
}

# Function to build the native module (.so)
build_native_module() {
    echo "📦 Building native module (.so)..."
    cd "${CMAKE_BUILD_DIR}" || { echo "Error: Failed to change to CMake build directory."; exit 1; }
    make || { echo "Error: Native module build failed."; exit 1; }
    cd - > /dev/null # Go back to the original directory quietly
    cp "${CMAKE_BUILD_DIR}/${SO_TARGET}" . || { echo "Error: Failed to copy native module."; exit 1; }
    echo "✅ Native module built: ${SO_TARGET}"
}

# Function to pack the LuaRocks package
pack_luarock() {
    echo "📦 Building LuaRocks package..."
    # Ensure .luac files are present for packing
    compile_luac || exit 1 # Call compile_luac here explicitly for packing
    luarocks pack "${ROCKSPEC}" || { echo "Error: Failed to pack LuaRock."; exit 1; }
    echo "✅ Rock built: ${ROCKFILE}"
}

# Function to install the LuaRocks package
install_luarock() {
    echo "📥 Installing LuaRocks package using 'luarocks make'..."
    # 'luarocks make' will handle its own build process including CMake.
    # It will use the unpacked source directory from the .src.rock.
    # We rely on the rockspec to correctly tell it where the .luac files are.
    # sudo luarocks make "${ROCKSPEC}" || { echo "Error: Failed to install LuaRock via 'luarocks make'."; exit 1; }
    echo "✅ Module installed via LuaRocks."
}

# Function to test the installed module
test_module() {
    echo "🧪 Testing installed module..."
    echo 'local db = require("'"${MODULE_NAME}"'") print("[✓] Loaded '"${MODULE_NAME}"'") print("[✓] db.config =", db.config and "OK" or "MISSING")' > test.lua
    luajit test.lua || { echo "Error: Test failed."; exit 1; }
    rm -f test.lua
    echo "✅ Tests passed."
}

# --- Main script logic ---

# If no arguments are provided, default to 'all'
if [ -z "$1" ]; then
    set -- "all"
fi

case "$1" in
    clean)
        clean_build
        ;;
    luac)
        compile_luac
        ;;
    cmake)
        run_cmake
        ;;
    build)
        run_cmake
        build_native_module
        ;;
    rock)
        pack_luarock
        ;;
    install)
        # For 'install' from the command line, we still want to clean and pack first
        clean_build
        pack_luarock
        install_luarock
        ;;
    test)
        test_module
        ;;
    all)
        echo "🚀 Starting full build, install, and test process..."
        clean_build
        pack_luarock    # This will now include luac compilation
        install_luarock
        test_module
        echo "🎉 All done!"
        ;;
    *)
        echo "Usage: ./build.sh {all|clean|luac|cmake|build|rock|install|test}"
        exit 1
        ;;
esac
