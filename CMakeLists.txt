# This file is used for testing only

# To perform the test, run `cmake .` at the root of the project tree followed
# by ctest .

cmake_minimum_required(VERSION 3.1)
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
    set(EDITORCONFIG_CMD "${CMAKE_SOURCE_DIR}/vbstest.bat")
endif()

function(new_ec_test name ec_file src_file regex)
    add_test(${name} ${EDITORCONFIG_CMD} -f ${ec_file}
        "${CMAKE_CURRENT_SOURCE_DIR}/${src_file}")
    set_tests_properties(${name} PROPERTIES PASS_REGULAR_EXPRESSION "${regex}")
endfunction()

# DEBUG vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

# This works:
#add_test(quux "C:/Users/chrisw/proj-local/editorconfig-core-vimscript/editorconfig.bat" "-f" "braces.in" "\"C:/Users/chrisw/proj-local/editorconfig-core-vimscript/tests/glob/a,.d\"")

# This doesn't work - without the extra quotes, the filename gets split at
# the comma.
new_ec_test(braces_empty_word4 braces.in "tests/glob/a,.d" "^[ \t\n\r]*$")

# Test
#add_test(quux "C:/Users/chrisw/proj-local/editorconfig-core-vimscript/pstest.bat" "-f" "braces.in" "${CMAKE_CURRENT_SOURCE_DIR}/tests/glob/a,.d")

# DEBUG ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#add_subdirectory(unittests)
#add_subdirectory(tests)

configure_file(CTestCustom.cmake ${CMAKE_CURRENT_BINARY_DIR} COPYONLY)
