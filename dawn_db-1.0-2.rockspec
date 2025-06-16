-- dawn_db-1.0-2.rockspec
package = "dawn_db"
version = "1.0-2"
source = {
  -- For local packing with 'luarocks pack', use the current directory.
  dir = ".",
  -- However, for the rockspec to be valid for distribution (when installed by others),
  -- source.url and optionally tag/branch are mandatory.
  url = "git+https://github.com/winslygeorge/dawn_db_manager.git",
  branch = "master"
}
description = {
  summary = "A database manager for Lua, with a native PostgreSQL binding.",
  detailed = [[
    dawn_db is a Lua library for managing database connections and operations,
    featuring an ORM, query builder, and native PostgreSQL support via LuaJIT FFI.
  ]],
  homepage = "https://github.com/winslygeorge/dawn_db_manager", -- Replace with your project's homepage
  license = "MIT"
}
dependencies = {
  -- State basic Lua compatibility. LuaJIT is usually compatible with Lua 5.1 bytecode.
  -- Do NOT list "luajit" here, as it's the interpreter, not a package to be installed by LuaRocks.
  "lua >= 5.1",
  -- Add any other LuaRocks dependencies your library truly needs (e.g., 'lfs', 'lua-cjson', 'luasocket')
}

build = {
  -- Use "cmake" as the build type since you're using CMake for your native module.
  type = "make",

  -- Specify variables to pass to CMake. LuaRocks provides LUAJIT_INCDIR if it's configured for LuaJIT.
  variables = {
    LUAJIT_INCLUDE_DIR = "$(LUAJIT_INCDIR)"
  },

  -- The 'install' block specifies what files to copy to the LuaRocks installation tree
  -- after the build (which includes your Makefile's 'luac' and 'build' targets).
  install = {
    -- Native library (the .so file)
    -- This tells LuaRocks to take 'so' from the rock's root directory
    -- (where your Makefile copies it) and install it as 'so' in the 'lib' path.

    -- Lua files (pre-compiled bytecode .lua files)
    -- The keys are the module names as they will be 'require'd (e.g., require("orm.config"))
    -- The values are the paths *relative to the rock's unpacked source directory*.
    -- Your Makefile's 'luac' target puts these in the 'build/' directory.
    lua = {
      ["orm.config"] = "build/orm/config.lua",
      ["orm.connection_manager"] = "build/orm/connection_manager.lua",
      ["orm.DawnModelRoute"] = "build/orm/DawnModelRoute.lua",
      ["orm.init"] = "build/orm/init.lua",
      ["orm.model_route"] = "build/orm/model_route.lua",
      ["orm.model"] = "build/orm/model.lua",
      ["orm.query_builder"] = "build/orm/query_builder.lua",
      ["orm.result_mapper"] = "build/orm/result_mapper.lua",
      ["orm.schema_manager"] = "build/orm/schema_manager.lua",
      -- Top-level files (if any in your root, also compiled to build/)
      ["async_postgres"] = "build/async_postgres.lua",
      ["dawn_db"] = "dawn_db.so",
      ["init_models"] = "build/init_models.lua",
      ["pg_ffi"] = "build/pg_ffi.lua",
      ["postgres"] = "build/postgres.lua",
      ["prac"] = "build/prac.lua",
      ["TestUserModel"] = "build/TestUserModel.lua",
      ["UserModel"] = "build/UserModel.lua",
    }
  }
}
