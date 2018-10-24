# This file is used for testing only

# To perform the test, run `cmake .` at the root of the project tree followed
# by ctest .

cmake_minimum_required(VERSION 2.6)
set(CMAKE_LEGACY_CYGWIN_WIN32 0)

# Do not check any compiler
project(editorconfig-core-vimscript NONE)

enable_testing()
if((NOT WIN32) OR CYGWIN)
    set(EDITORCONFIG_CMD "${CMAKE_SOURCE_DIR}/editorconfig")
    set(EDITORCONFIG_UNIT_TEST_CMD "${CMAKE_SOURCE_DIR}/ecunit")
else()
    # Somehow the extra \\ get changed to / in the CTestTestfiles,
    # so I am using an extra BAT file to invoke powershell.
    #set(EDITORCONFIG_CMD "powershell -executionpolicy bypass -file \\\"${CMAKE_SOURCE_DIR}\\editorconfig.ps1\\\"")
    set(EDITORCONFIG_CMD "${CMAKE_SOURCE_DIR}/editorconfig.bat")
endif()

add_subdirectory(unittests)
add_subdirectory(tests)

configure_file(CTestCustom.cmake ${CMAKE_CURRENT_BINARY_DIR} COPYONLY)
