# localtests/CMakeLists.txt
# Copyright (c) 2018 Christopher White
# Copyright (c) 2011-2014 EditorConfig Team
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

# Don't check any language compiler. This project is for EditorConfig Core
# testing only.
project(editorconfig-core-test NONE)

# Only when we are using editorconfig-core-test independently should we check
# cmake version, set EDITORCONFIG_CMD as cache string, and enable_testing()
# here.
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
    cmake_minimum_required(VERSION 2.6)
    set(unit-test EDITORCONFIG_UNIT_TEST_CMD "editorconfig" CACHE STRING "editorconfig unit-test command (with -g <pattern> support.")
    enable_testing()
endif()

# The most common test function.  NOTE: the pattern and source file must be
# doubly-escaped.  This is because cmake interprets one level of escaping while
# generating the input for ctest, and then ctest interprets the results.
# For example, in g_brackets_close_inside (below), the string "\\\\" is
# rendered by cmake as "\\" in the CTestTestfile.cmake file that cmake outputs.
# The ctest executable then sees "\\" as a single escaped backslash.
#
# This would probably be easier if we could use CMake 3.0+ bracket arguments
# (https://cmake.org/cmake/help/v3.4/manual/cmake-language.7.html#bracket-argument),
# but I don't want to require a higher CMake version than the rest of the project.

function(new_glob_test name pattern src_file)
    add_test(${name} "${EDITORCONFIG_UNIT_TEST_CMD}" -g "${pattern}"
        -x "${name}" --
        "${CMAKE_CURRENT_SOURCE_DIR}" "${src_file}")
endfunction()

# Mark a test as one that fails, i.e., the filename doesn't match the glob.
function(fails name)
    set_tests_properties(${name} PROPERTIES WILL_FAIL TRUE)
endfunction()

if(EDITORCONFIG_UNIT_TEST_CMD)
    add_subdirectory(glob)
    add_subdirectory(abcd)
endif()
