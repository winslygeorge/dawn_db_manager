-- dawn_db-1.0-1.rockspec
package = "dawn_db"
version = "1.0-1"
source = {
  url = "https://github.com/winslygeorge/dawn_db_manager.git", -- IMPORTANT: Replace with your actual Git repository URL
  tag = "v1.0", -- Or the appropriate Git tag/commit for this version
  branch = "master" -- Added as per your input. Note: 'tag' and 'branch' used together can be redundant if the tag is on that branch.
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
  type = "cmake",

  -- Specify variables to pass to CMake. LuaRocks provides LUAJIT_INCDIR if it's configured for LuaJIT.
  variables = {
    LUAJIT_INCLUDE_DIR = "$(LUAJIT_INCDIR)"
  },

  -- The 'install' block specifies what files to copy to the LuaRocks installation tree
  -- after the build (which includes your Makefile's 'luac' and 'build' targets).
  install = {
    -- Native library (the .so file)
    -- This tells LuaRocks to take 'dawn_db.so' from the rock's root directory
    -- (where your Makefile copies it) and install it as 'dawn_db.so' in the 'lib' path.
    lib = {
      ["dawn_db.so"] = "dawn_db.so"
    },
    -- Lua files (pre-compiled bytecode .luac files)
    -- The keys are the module names as they will be 'require'd (e.g., require("dawn_db.orm.config"))
    -- The values are the paths *relative to the rock's unpacked source directory*.
    -- Your Makefile's 'luac' target puts these in the 'build/' directory.
    lua = {
      ["dawn_db.orm.config"] = "build/orm/config.luac",
      ["dawn_db.orm.connection_manager"] = "build/orm/connection_manager.luac",
      ["dawn_db.orm.DawnModelRoute"] = "build/orm/DawnModelRoute.luac",
      ["dawn_db.orm.init"] = "build/orm/init.luac",
      ["dawn_db.orm.model_route"] = "build/orm/model_route.luac",
      ["dawn_db.orm.model"] = "build/orm/model.luac",
      ["dawn_db.orm.query_builder"] = "build/orm/query_builder.luac",
      ["dawn_db.orm.result_mapper"] = "build/orm/result_mapper.luac",
      ["dawn_db.orm.schema_manager"] = "build/orm/schema_manager.luac",
      -- Top-level files (if any in your root, also compiled to build/)
      ["dawn_db.async_postgres"] = "build/async_postgres.luac",
      ["dawn_db.dawn_db"] = "build/dawn_db.luac",
      ["dawn_db.init_models"] = "build/init_models.luac",
      ["dawn_db.pg_ffi"] = "build/pg_ffi.luac",
      ["dawn_db.postgres"] = "build/postgres.luac",
      ["dawn_db.prac"] = "build/prac.luac",
      ["dawn_db.TestUserModel"] = "build/TestUserModel.luac",
      ["dawn_db.UserModel"] = "build/UserModel.luac",
    }
  }
}
