# localtests/abcd/glob/CMakeLists.txt: tests with parent directories including
# the letters a, b, c, and d.
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

# Copied from tests/CMakeLists.txt and tweaked to add -x
function(new_ec_test name ec_file src_file regex)
    add_test(${name} ${EDITORCONFIG_CMD} -f ${ec_file} -x "${name}"
        "${CMAKE_CURRENT_SOURCE_DIR}/${src_file}")
    set_tests_properties(${name} PROPERTIES PASS_REGULAR_EXPRESSION "${regex}")
endfunction()

###########################################################

# Test ** - matches over path separator
new_ec_test(ga_star_star_over_separator1 star_star.in a/z.c "^key1=value1[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator2 star_star.in amnz.c "^key1=value1[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator3 star_star.in am/nz.c "^key1=value1[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator4 star_star.in a/mnz.c "^key1=value1[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator5 star_star.in amn/z.c "^key1=value1[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator6 star_star.in a/mn/z.c "^key1=value1[ \t\n\r]*$")

new_ec_test(ga_star_star_over_separator7 star_star.in b/z.c "^key2=value2[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator8 star_star.in b/mnz.c "^key2=value2[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator9 star_star.in b/mn/z.c "^key2=value2[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator10 star_star.in bmnz.c "^[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator11 star_star.in bm/nz.c "^[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator12 star_star.in bmn/z.c "^[ \t\n\r]*$")

new_ec_test(ga_star_star_over_separator13 star_star.in c/z.c "^key3=value3[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator14 star_star.in cmn/z.c "^key3=value3[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator15 star_star.in c/mn/z.c "^key3=value3[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator16 star_star.in cmnz.c "^[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator17 star_star.in cm/nz.c "^[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator18 star_star.in c/mnz.c "^[ \t\n\r]*$")

new_ec_test(ga_star_star_over_separator19 star_star.in d/z.c "^key4=value4[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator20 star_star.in d/mn/z.c "^key4=value4[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator21 star_star.in dmnz.c "^[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator22 star_star.in dm/nz.c "^[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator23 star_star.in d/mnz.c "^[ \t\n\r]*$")
new_ec_test(ga_star_star_over_separator24 star_star.in dmn/z.c "^[ \t\n\r]*$")
