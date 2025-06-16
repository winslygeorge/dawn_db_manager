cmake_minimum_required(VERSION 3.10)
project(dawn_db CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Ensure LuaJIT headers are found.
# LUAJIT_INCLUDE_DIR is often passed by LuaRocks when build.type is cmake.
# Using CMAKE_SOURCE_DIR to find potentially custom LuaJIT include if not system-wide
# If you are passing LUAJIT_INCLUDE_DIR from luarocks/Makefile, it will override this.
# A common pattern for LuaRocks build.type="cmake" is to use ${LUA_INCLUDE_DIR} or ${LUAJIT_INCDIR}
# provided by LuaRocks itself. For now, we'll keep your explicit path but note the variables.
# You might need to set LUA_INCLUDE_DIR or LUA_LIBRARIES if not already done by LuaRocks's cmake build.
find_package(LuaJIT QUIET) # Try to find LuaJIT's package config
if(LUAJIT_FOUND)
  include_directories(${LUAJIT_INCLUDE_DIR})
  link_directories(${LUAJIT_LIB_DIR})
  set(LUA_LIBRARIES ${LUAJIT_LIBRARIES}) # Alias for linking
else()
  # Fallback if find_package fails, using your hardcoded path
  include_directories(/usr/include/luajit-2.1)
  # You might need to add specific linking for luajit if it's not automatically found
  # by target_link_libraries.
endif()


add_library(dawn_db SHARED dawn_db_wrapper.cpp)

# Link against LuaJIT library
# If LUAJIT_LIBRARIES is set by find_package, use that. Otherwise, use luajit-5.1
if(LUAJIT_FOUND)
  target_link_libraries(dawn_db ${LUAJIT_LIBRARIES})
else()
  target_link_libraries(dawn_db luajit-5.1)
endif()

set_target_properties(dawn_db PROPERTIES PREFIX "")

# REQUIRED for LuaRocks build.type = "cmake"
# This tells CMake where to install the compiled shared library.
# LuaRocks will then pick this up and put it in the final rock tree.
# ${LUA_LIBDIR} is a variable often provided by LuaRocks during its cmake build.
install(TARGETS dawn_db LIBRARY DESTINATION ${LUA_LIBDIR})
