package = "dawn_db"
version = "1.0-1"

source = {
   url = "git+https://github.com/winslygeorge/dawn_db_manager.git",
   branch = "master"
}

description = {
   summary = "DawnDB: Lightweight Lua ORM with C++ performance bridge",
   detailed = [[
      DawnDB is a Lua ORM library with an optional native C++ extension.
      It supports schema migration, query building, and model abstraction.
   ]],
   homepage = "https://github.com/winslygeorge/dawn_db_manager",
   license = "MIT"
}

supported_platforms = { "linux" }

dependencies = {
   "lua >= 5.1"
}

build = {
   type = "make",
   build_target = "all",
   install_target = "install",
   modules = {
      dawn_db = "dawn_db.so"
   }
}
