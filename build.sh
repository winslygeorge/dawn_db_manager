#!/bin/bash

# build.sh - Script to build the dawn_db module (for development)
# For installation, use: sudo luarocks make dawn_db-1.0-11.rockspec

# --- Configuration ---
MODULE_NAME="dawn_db"
ROCKSPEC="dawn_db-1.0-11.rockspec"
ROCKFILE="${MODULE_NAME}-1.0-11.rock"
LUAJIT_INCLUDE="/usr/include/luajit-2.1"
BUILD_DIR="build"
CMAKE_BUILD_DIR="${BUILD_DIR}/cmake"
SO_TARGET="${MODULE_NAME}.so"

# Prevent recursive execution
if [ -n "$BUILD_SH_RUNNING" ]; then
    echo "Detected recursive call, exiting..."
    exit 0
fi
export BUILD_SH_RUNNING=1

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
    find . -name "*.lua" -type f | while read file; do
        # Exclude files that are not part of the module or are temporary
        if [[ "$file" != "./build.sh" && "$file" != "./test.lua" && "$file" != *".rockspec" ]]; then
            # Remove leading ./ from path
            file="${file#./}"
            out="${BUILD_DIR}/${file}"
            mkdir -p "$(dirname "$out")" || { echo "Error: Failed to create output directory for $out."; exit 1; }
            echo "  Compiling: $file -> $out"
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
    cd - > /dev/null
    echo "✅ CMake configured."
}

# Function to build the native module (.so)
build_native_module() {
    echo "📦 Building native module (.so)..."
    cd "${CMAKE_BUILD_DIR}" || { echo "Error: Failed to change to CMake build directory."; exit 1; }
    make || { echo "Error: Native module build failed."; exit 1; }
    cd - > /dev/null
    cp "${CMAKE_BUILD_DIR}/${SO_TARGET}" . || { echo "Error: Failed to copy native module."; exit 1; }
    echo "✅ Native module built: ${SO_TARGET}"
}

# Function to pack the LuaRocks package
pack_luarock() {
    echo "📦 Building LuaRocks package..."
    compile_luac || exit 1
    luarocks pack "${ROCKSPEC}" || { echo "Error: Failed to pack LuaRock."; exit 1; }
    echo "✅ Rock built: ${ROCKFILE}"
}

# Function to test the module locally (without installing)
test_local() {
    echo "🧪 Testing local module..."
    
    # Ensure native module is built
    if [ ! -f "${SO_TARGET}" ]; then
        echo "Native module not found, building first..."
        run_cmake
        build_native_module
    fi
    
    # Create a simple test file
    cat > test_local.lua << 'EOF'
-- Test for dawn_db module
package.cpath = package.cpath .. ";./?.so"
local dawn_db = require("dawn_db")
print("✅ dawn_db module loaded successfully!")
print("✅ All tests passed!")
EOF
    
    luajit test_local.lua || { echo "Error: Test failed."; exit 1; }
    rm -f test_local.lua
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
    test)
        test_local
        ;;
    all)
        echo "🚀 Starting full build process..."
        clean_build
        compile_luac
        run_cmake
        build_native_module
        pack_luarock
        echo "🎉 Build complete!"
        echo ""
        echo "To install the module, run:"
        echo "  sudo luarocks make ${ROCKSPEC}"
        echo ""
        echo "To test the local build, run:"
        echo "  ./build.sh test"
        ;;
    *)
        echo "Usage: ./build.sh {all|clean|luac|cmake|build|rock|test}"
        echo ""
        echo "Commands:"
        echo "  all    - Clean, compile luac, build native, pack rock"
        echo "  clean  - Remove all build artifacts"
        echo "  luac   - Compile Lua files to bytecode"
        echo "  cmake  - Run CMake configuration"
        echo "  build  - Build the native module"
        echo "  rock   - Create a .rock package"
        echo "  test   - Test the local build without installing"
        echo ""
        echo "For installation, use: sudo luarocks make ${ROCKSPEC}"
        exit 1
        ;;
esac