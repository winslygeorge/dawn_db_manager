# Config
MODULE_NAME = dawn_db
ROCKSPEC = dawn_db-1.0-1.rockspec
ROCKFILE = $(MODULE_NAME)-1.0-1.rock
LUAJIT_INCLUDE = /usr/include/luajit-2.1
BUILD_DIR = build
CMAKE_BUILD_DIR = $(BUILD_DIR)/cmake
SO_TARGET = $(MODULE_NAME).so

.PHONY: all luac cmake build rock install test clean

all: luac cmake build rock install test

luac:
	@echo "🔧 Compiling .lua to .luac..."
	@mkdir -p $(BUILD_DIR)
	@find . -name "*.lua" | while read file; do \
		out="$(BUILD_DIR)/$${file}c"; \
		mkdir -p "$$(dirname $$out)"; \
		luajit -b "$$file" "$$out"; \
	done
	@echo "✅ .luac files compiled to $(BUILD_DIR)"

cmake:
	@echo "⚙️ Running CMake..."
	@mkdir -p $(CMAKE_BUILD_DIR)
	@cd $(CMAKE_BUILD_DIR) && cmake ../.. -DLUAJIT_INCLUDE_DIR=$(LUAJIT_INCLUDE)

build:
	@echo "📦 Building native module (.so)..."
	@cd $(CMAKE_BUILD_DIR) && make
	@cp $(CMAKE_BUILD_DIR)/$(SO_TARGET) .

rock:
	@echo "📦 Building LuaRocks package..."
	@luarocks pack $(ROCKSPEC)
	@echo "✅ Rock built: $(ROCKFILE)"

install:
	@echo "📥 Installing LuaRocks package using 'luarocks make'..."
	# Explicitly tell luarocks make to use luajit as the interpreter
	@luarocks make $(ROCKSPEC)


test:
	@echo "🧪 Testing installed module..."
	@echo 'local db = require("$(MODULE_NAME)") print("[✓] Loaded $(MODULE_NAME)") print("[✓] db.config =", db.config and "OK" or "MISSING")' > test.lua
	@luajit test.lua
	@rm -f test.lua

clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR) *.so *.rock
