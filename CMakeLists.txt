# This file is used for testing only

# To perform the test, run `cmake .` at the root of the project tree followed
# by ctest .

cmake_minimum_required(VERSION 2.6)
set(CMAKE_LEGACY_CYGWIN_WIN32 0)

# Do not check any compiler
project(editorconfig-core-vimscript NONE)

enable_testing()
set(EDITORCONFIG_CMD "${CMAKE_SOURCE_DIR}/editorconfig")
#add_subdirectory(tests)
add_subdirectory(globtests)
