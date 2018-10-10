#
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
    set(EDITORCONFIG_CMD "editorconfig" CACHE STRING "editorconfig command (with -g <pattern> support.")
    enable_testing()
endif()

# The most common test function
function(new_glob_test name pattern src_file)
    add_test(${name} ${EDITORCONFIG_CMD} -g ${pattern}
        "${CMAKE_CURRENT_SOURCE_DIR}/${src_file}")
endfunction()
function(fails name)
    set_tests_properties(${name} PROPERTIES WILL_FAIL TRUE)
endfunction()

###########################################################

# Tests for *

# matches a single characters
new_glob_test(g_star_single "a*e.c" ace.c)
new_glob_test(g_star_single_f "a*e.c" blech.c)
fails(g_star_single_f)

# matches zero characters
new_glob_test(g_star_zero "a*e.c" ae.c)

# matches multiple characters
new_glob_test(g_star_multiple "a*e.c" abcde.c)

# does not match path separator
new_glob_test(g_star_over_slash "a*e.c" a/e.c)
fails(g_star_over_slash)

# star after a slash
new_glob_test(g_star_after_slash "Bar/*" Bar/foo.txt)
new_glob_test(g_star_after_slash_f "Bar*" Bar/foo.txt)
fails(g_star_after_slash_f)

# Tests for ?

# matches a single character
new_glob_test(g_question_single "som?.c" some.c)

# does not match zero characters
new_glob_test(g_question_zero "som?.c" som.c)
fails(g_question_zero)

# does not match multiple characters
new_glob_test(g_question_multiple "som?.c" something.c)
fails(g_question_multiple)

# Tests for [ and ]

## close bracket inside
new_glob_test(g_brackets_close_inside "[\\\\]ab].g" ].g)

## close bracket outside
new_glob_test(g_brackets_close_outside "[ab]].g" b].g)

## negative close bracket inside
new_glob_test(g_brackets_nclose_inside "[!\\\\]ab].g" c.g)

## negative close bracket outside
new_glob_test(g_brackets_nclose_outside "[!ab]].g" c].g)

## character choice
new_glob_test(g_brackets_choice "[ab].a" a.a)

## character choice 2
new_glob_test(g_brackets_choice2 "[ab].a" c.a)
fails(g_brackets_choice2)

## negative character choice
new_glob_test(g_brackets_nchoice "[!ab].b" c.b)

## negative character choice 2
new_glob_test(g_brackets_nchoice2 "[!ab].b" a.b)
fails(g_brackets_nchoice2)

## character range
new_glob_test(g_brackets_range "[d-g].c" f.c)

## character range 2
new_glob_test(g_brackets_range2 "[d-g].c" h.c)
fails(g_brackets_range2)

## negative character range
new_glob_test(g_brackets_nrange "[!d-g].d" h.d)

## negative character range 2
new_glob_test(g_brackets_nrange2 "[!d-g].d" f.d)
fails(g_brackets_nrange2)

## range and choice
new_glob_test(g_brackets_range_and_choice "[abd-g].e" e.e)

## character choice with a dash
new_glob_test(g_brackets_choice_with_dash "[-ab].f" -.f)

## slash inside brackets - the bracket and slash are literal, not a
## glob expression.
new_glob_test(g_brackets_slash_inside1 "ab[e/]cd.i" ab/cd.i)
fails(g_brackets_slash_inside1)

new_glob_test(g_brackets_slash_inside2 "ab[e/]cd.i" abecd.i)
fails(g_brackets_slash_inside2)

new_glob_test(g_brackets_slash_inside3 "ab[e/]cd.i" "ab[e/]cd.i")

#The Python core doesn't yet handle this case, and neither do we.
#new_glob_test(g_brackets_slash_inside4 "ab[/c" "ab[/c")

## Tests for { and }

## word choice
new_glob_test(g_braces_word_choice1 "*.{py,js,html}" test.py)
new_glob_test(g_braces_word_choice2 "*.{py,js,html}" test.js)
new_glob_test(g_braces_word_choice3 "*.{py,js,html}" test.html)
new_glob_test(g_braces_word_choice4 "*.{py,js,html}" test.pyc)
fails(g_braces_word_choice4)

## single choice
new_glob_test(g_braces_single_choice "{single}.b" "{single}.b")
new_glob_test(g_braces_single_choice_negative "{single}.b" .b)
fails(g_braces_single_choice_negative)

## empty choice
new_glob_test(g_braces_empty_choice "{}.c" {}.c)
new_glob_test(g_braces_empty_choice_negative "{}.c" .c)
fails(g_braces_empty_choice_negative)

## choice with empty word
new_glob_test(g_braces_empty_word1 a{b,c,}.d a.d)
new_glob_test(g_braces_empty_word2 a{b,c,}.d ab.d)
new_glob_test(g_braces_empty_word3 a{b,c,}.d ac.d)
new_glob_test(g_braces_empty_word4 a{b,c,}.d a,.d)
fails(g_braces_empty_word4)

## choice with empty words
new_glob_test(g_braces_empty_words1 a{,b,,c,}.e a.e)
new_glob_test(g_braces_empty_words2 a{,b,,c,}.e ab.e)
new_glob_test(g_braces_empty_words3 a{,b,,c,}.e ac.e)
new_glob_test(g_braces_empty_words4 a{,b,,c,}.e a,.e)
fails(g_braces_empty_words4)

## no closing brace
#new_glob_test(g_braces_no_closing braces.in {.f)
#new_glob_test(g_braces_no_closing_negative braces.in .f)
#
## nested braces
#new_glob_test(g_braces_nested1 braces.in word,this}.g)
#new_glob_test(g_braces_nested2 braces.in {also,this}.g)
#new_glob_test(g_braces_nested3 braces.in word.g)
#new_glob_test(g_braces_nested4 braces.in {also}.g)
#new_glob_test(g_braces_nested5 braces.in this.g)
#
## closing inside beginning
#new_glob_test(g_braces_closing_in_beginning braces.in {},b}.h)
#
## missing closing braces
#new_glob_test(g_braces_unmatched1 braces.in {{,b,c{d}.i)
#new_glob_test(g_braces_unmatched2 braces.in {.i)
#new_glob_test(g_braces_unmatched3 braces.in b.i)
#new_glob_test(g_braces_unmatched4 braces.in c{d.i)
#new_glob_test(g_braces_unmatched5 braces.in .i)
#
## escaped comma
#new_glob_test(g_braces_escaped_comma1 braces.in a,b.txt)
#new_glob_test(g_braces_escaped_comma2 braces.in a.txt)
#new_glob_test(g_braces_escaped_comma3 braces.in cd.txt)
#
## escaped closing brace
#new_glob_test(g_braces_escaped_brace1 braces.in e.txt)
#new_glob_test(g_braces_escaped_brace2 braces.in }.txt)
#new_glob_test(g_braces_escaped_brace3 braces.in f.txt)
#
## escaped backslash
#new_glob_test(g_braces_escaped_backslash1 braces.in g.txt)
#if(NOT WIN32) # this case is impossible on Windows.
#    new_glob_test(g_braces_escaped_backslash2 braces.in \\\\.txt)
#endif()
#new_glob_test(g_braces_escaped_backslash3 braces.in i.txt)
#
## patterns nested in braces
#new_glob_test(g_braces_patterns_nested1 braces.in some.j)
#new_glob_test(g_braces_patterns_nested2 braces.in abe.j)
#new_glob_test(g_braces_patterns_nested3 braces.in abf.j)
#new_glob_test(g_braces_patterns_nested4 braces.in abg.j)
#new_glob_test(g_braces_patterns_nested5 braces.in ace.j)
#new_glob_test(g_braces_patterns_nested6 braces.in acf.j)
#new_glob_test(g_braces_patterns_nested7 braces.in acg.j)
#new_glob_test(g_braces_patterns_nested8 braces.in abce.j)
#new_glob_test(g_braces_patterns_nested9 braces.in abcf.j)
#new_glob_test(g_braces_patterns_nested10 braces.in abcg.j)
#new_glob_test(g_braces_patterns_nested11 braces.in ae.j)
#new_glob_test(g_braces_patterns_nested12 braces.in .j)
#
## numeric brace range
#new_glob_test(g_braces_numeric_range1 braces.in 1)
#new_glob_test(g_braces_numeric_range2 braces.in 3)
#new_glob_test(g_braces_numeric_range3 braces.in 15)
#new_glob_test(g_braces_numeric_range4 braces.in 60)
#new_glob_test(g_braces_numeric_range5 braces.in 5a)
#new_glob_test(g_braces_numeric_range6 braces.in 120)
#new_glob_test(g_braces_numeric_range7 braces.in 121)
#new_glob_test(g_braces_numeric_range8 braces.in 060)
#
## alphabetical brace range: letters should not be considered for ranges
#new_glob_test(g_braces_alpha_range1 braces.in {aardvark..antelope})
#new_glob_test(g_braces_alpha_range2 braces.in a)
#new_glob_test(g_braces_alpha_range3 braces.in aardvark)
#new_glob_test(g_braces_alpha_range4 braces.in agreement)
#new_glob_test(g_braces_alpha_range5 braces.in antelope)
#new_glob_test(g_braces_alpha_range6 braces.in antimatter)
#
#
## Tests for **
#
## test EditorConfig files with UTF-8 characters larger than 127
#new_glob_test(g_utf_8_char utf8char.in "中文.txt")
#
## matches over path separator
#new_glob_test(g_star_star_over_separator1 star_star.in a/z.c)
#new_glob_test(g_star_star_over_separator2 star_star.in amnz.c)
#new_glob_test(g_star_star_over_separator3 star_star.in am/nz.c)
#new_glob_test(g_star_star_over_separator4 star_star.in a/mnz.c)
#new_glob_test(g_star_star_over_separator5 star_star.in amn/z.c)
#new_glob_test(g_star_star_over_separator6 star_star.in a/mn/z.c)
#
#new_glob_test(g_star_star_over_separator7 star_star.in b/z.c)
#new_glob_test(g_star_star_over_separator8 star_star.in b/mnz.c)
#new_glob_test(g_star_star_over_separator9 star_star.in b/mn/z.c)
#new_glob_test(g_star_star_over_separator10 star_star.in bmnz.c)
#new_glob_test(g_star_star_over_separator11 star_star.in bm/nz.c)
#new_glob_test(g_star_star_over_separator12 star_star.in bmn/z.c)
#
#new_glob_test(g_star_star_over_separator13 star_star.in c/z.c)
#new_glob_test(g_star_star_over_separator14 star_star.in cmn/z.c)
#new_glob_test(g_star_star_over_separator15 star_star.in c/mn/z.c)
#new_glob_test(g_star_star_over_separator16 star_star.in cmnz.c)
#new_glob_test(g_star_star_over_separator17 star_star.in cm/nz.c)
#new_glob_test(g_star_star_over_separator18 star_star.in c/mnz.c)
#
#new_glob_test(g_star_star_over_separator19 star_star.in d/z.c)
#new_glob_test(g_star_star_over_separator20 star_star.in d/mn/z.c)
#new_glob_test(g_star_star_over_separator21 star_star.in dmnz.c)
#new_glob_test(g_star_star_over_separator22 star_star.in dm/nz.c)
#new_glob_test(g_star_star_over_separator23 star_star.in d/mnz.c)
#new_glob_test(g_star_star_over_separator24 star_star.in dmn/z.c)
