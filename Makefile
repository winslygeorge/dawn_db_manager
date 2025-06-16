# Config
MODULE_NAME = dawn_db
ROCKSPEC = dawn_db-1.0-2.rockspec
ROCKFILE = $(MODULE_NAME)-1.0-2.rock
# Assuming luajit-2.1 include path for CMake. Ensure this is correct for your system.
LUAJIT_INCLUDE = /usr/include/luajit-2.1
BUILD_DIR = build
CMAKE_BUILD_DIR = $(BUILD_DIR)/cmake
SO_TARGET = $(MODULE_NAME).so

.PHONY: all luac cmake build rock install test clean

# Default target: Builds, packs, installs the rock, and then runs tests.
# The 'install' target now uses 'luarocks make', which should orchestrate the full build.
all: rock install test

# Manual compilation of .lua to .luac.
# While 'luarocks make' can handle this if configured in the rockspec, this target is kept
# for explicit manual compilation during development.
luac:
	@echo "🔧 Compiling .lua to .luac..."
	@mkdir -p $(BUILD_DIR)
	@find . -name "*.lua" | while read file; do \
		out="$(BUILD_DIR)/$${file}"; \
		mkdir -p "$$(dirname $$out)"; \
		luajit -b "$$file" "$$out"; \
	done
	@echo "✅ .luac files compiled to $(BUILD_DIR)"

# Manual CMake configuration for the native C module.
# This target is for independent CMake setup if not fully handled by 'luarocks make'.
cmake:
	@echo "⚙️ Running CMake..."
	@mkdir -p $(CMAKE_BUILD_DIR)
	@cd $(CMAKE_BUILD_DIR) && cmake ../.. -DLUAJIT_INCLUDE_DIR=$(LUAJIT_INCLUDE)

# Manual build of the native module (.so).
# This target is for independent compilation of the shared library.
build:
	@echo "📦 Building native module (.so)..."
	@cd $(CMAKE_BUILD_DIR) && make
	@# Copying the .so to the root for direct access; 'luarocks make' handles final placement.
	@cp $(CMAKE_BUILD_DIR)/$(SO_TARGET) .

# Build the LuaRocks package (.rock file) for distribution.
rock:
	@echo "📦 Building LuaRocks package..."
	@luarocks pack $(ROCKSPEC)
	@echo "✅ Rock built: $(ROCKFILE)"

# Install the LuaRocks package using 'luarocks make'.
# This is the most "LuaRocks friendly" way to install, as it reads the rockspec
# and handles all compilation and placement according to its definitions.
install: clean luac # Added 'luac' as a prerequisite
	@echo "📥 Installing LuaRocks package using 'luarocks make'..."
	@luarocks make $(ROCKSPEC)
	@echo "✅ Module installed via LuaRocks."

# Test the installed module.
test:
	@echo "🧪 Testing installed module..."
	@echo 'local db = require("$(MODULE_NAME)") print("[✓] Loaded $(MODULE_NAME)") print("[✓] db.config =", db.config and "OK" or "MISSING")' > test.lua
	@luajit test.lua
	@rm -f test.lua

# Clean all build artifacts.
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR) *.so *.rock test.lua
	@echo "✅ Cleaned."
