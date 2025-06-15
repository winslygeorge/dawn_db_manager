cmake_minimum_required(VERSION 3.10)
project(dawn_db CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Adjust this path if LuaJIT is not in default path
include_directories(/usr/include/luajit-2.1)

add_library(dawn_db SHARED dawn_db_wrapper.cpp)

target_link_libraries(dawn_db luajit-5.1)
set_target_properties(dawn_db PROPERTIES PREFIX "")
