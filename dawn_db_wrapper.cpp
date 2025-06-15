extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

int luaopen_dawn_db(lua_State* L) {
    const char* path = "/usr/local/share/lua/5.1/dawn_db.luac"; // Adjust as needed

    if (luaL_loadfile(L, path) != LUA_OK) {
        return luaL_error(L, "Failed to load dawn_db.luac: %s", lua_tostring(L, -1));
    }

    if (lua_pcall(L, 0, 1, 0) != LUA_OK) {
        return luaL_error(L, "Error running dawn_db.luac: %s", lua_tostring(L, -1));
    }

    // stack now contains return value from dawn_db.luac -> a table
    return 1;
}
