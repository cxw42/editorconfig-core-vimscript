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
    add_test(${name} "${EDITORCONFIG_CMD}" -g "${pattern}"
        "${CMAKE_CURRENT_SOURCE_DIR}/${src_file}")
endfunction()

# Mark a test as one that fails, i.e., the filename doesn't match the glob.
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
new_glob_test(g_brackets_slash_inside4 "ab[/c" "ab[/c")

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
new_glob_test(g_braces_no_closing "{.f" {.f)
new_glob_test(g_braces_no_closing_negative "{.f" .f)
fails(g_braces_no_closing_negative)

## nested braces
new_glob_test(g_braces_nested1 "{word,{also},this}.g" word,this}.g)
fails(g_braces_nested1)
new_glob_test(g_braces_nested2 "{word,{also},this}.g" {also,this}.g)
fails(g_braces_nested2)
new_glob_test(g_braces_nested3 "{word,{also},this}.g" word.g)
new_glob_test(g_braces_nested4 "{word,{also},this}.g" {also}.g)
new_glob_test(g_braces_nested5 "{word,{also},this}.g" this.g)

## closing inside beginning
new_glob_test(g_braces_closing_in_beginning "{},b}.h" {},b}.h)

## missing closing braces
new_glob_test(g_braces_unmatched1 "{{,b,c{d}.i" {{,b,c{d}.i)
new_glob_test(g_braces_unmatched2 "{{,b,c{d}.i" {.i)
fails(g_braces_unmatched2)
new_glob_test(g_braces_unmatched3 "{{,b,c{d}.i" b.i)
fails(g_braces_unmatched3)
new_glob_test(g_braces_unmatched4 "{{,b,c{d}.i" c{d.i)
fails(g_braces_unmatched4)
new_glob_test(g_braces_unmatched5 "{{,b,c{d}.i" .i)
fails(g_braces_unmatched5)

## escaped comma
new_glob_test(g_braces_escaped_comma1 "{a\\\\,b,cd}.txt" a,b.txt)
new_glob_test(g_braces_escaped_comma2 "{a\\\\,b,cd}.txt" a.txt)
fails(g_braces_escaped_comma2)
new_glob_test(g_braces_escaped_comma3 "{a\\\\,b,cd}.txt" cd.txt)

## escaped closing brace
new_glob_test(g_braces_escaped_brace1 "{e,\\\\},f}.txt" e.txt)
new_glob_test(g_braces_escaped_brace2 "{e,\\\\},f}.txt" }.txt)
new_glob_test(g_braces_escaped_brace3 "{e,\\\\},f}.txt" f.txt)

## escaped backslash - 8 backslashes are reduced to 2 by cmake+ctest
new_glob_test(g_braces_escaped_backslash1 "{g,\\\\\\\\,i}.txt" g.txt)
if(NOT WIN32) # this case is impossible on Windows.
    new_glob_test(g_braces_escaped_backslash2 "{g,\\\\\\\\,i}.txt" "\\\\.txt")
endif()
new_glob_test(g_braces_escaped_backslash3 "{g,\\\\\\\\,i}.txt" i.txt)

## patterns nested in braces
new_glob_test(g_braces_patterns_nested1 "{some,a{*c,b}[ef]}.j" some.j)
new_glob_test(g_braces_patterns_nested2 "{some,a{*c,b}[ef]}.j" abe.j)
new_glob_test(g_braces_patterns_nested3 "{some,a{*c,b}[ef]}.j" abf.j)
new_glob_test(g_braces_patterns_nested4 "{some,a{*c,b}[ef]}.j" abg.j)
fails(g_braces_patterns_nested4)
new_glob_test(g_braces_patterns_nested5 "{some,a{*c,b}[ef]}.j" ace.j)
new_glob_test(g_braces_patterns_nested6 "{some,a{*c,b}[ef]}.j" acf.j)
new_glob_test(g_braces_patterns_nested7 "{some,a{*c,b}[ef]}.j" acg.j)
fails(g_braces_patterns_nested7)
new_glob_test(g_braces_patterns_nested8 "{some,a{*c,b}[ef]}.j" abce.j)
new_glob_test(g_braces_patterns_nested9 "{some,a{*c,b}[ef]}.j" abcf.j)
new_glob_test(g_braces_patterns_nested10 "{some,a{*c,b}[ef]}.j" abcg.j)
fails(g_braces_patterns_nested10)
new_glob_test(g_braces_patterns_nested11 "{some,a{*c,b}[ef]}.j" ae.j)
fails(g_braces_patterns_nested11)
new_glob_test(g_braces_patterns_nested12 "{some,a{*c,b}[ef]}.j" .j)
fails(g_braces_patterns_nested12)

## numeric brace range
new_glob_test(g_braces_numeric_range1 "{3..120}" 1)
fails(g_braces_numeric_range1)
new_glob_test(g_braces_numeric_range2 "{3..120}" 3)
new_glob_test(g_braces_numeric_range3 "{3..120}" 15)
new_glob_test(g_braces_numeric_range4 "{3..120}" 60)
new_glob_test(g_braces_numeric_range5 "{3..120}" 5a)
fails(g_braces_numeric_range5)
new_glob_test(g_braces_numeric_range6 "{3..120}" 120)
new_glob_test(g_braces_numeric_range7 "{3..120}" 121)
fails(g_braces_numeric_range7)

new_glob_test(g_braces_numeric_range8 "{3..120}" 060)
fails(g_braces_numeric_range8)

## alphabetical brace range: letters should not be considered for ranges
new_glob_test(g_braces_alpha_range1 "{aardvark..antelope}" {aardvark..antelope})
new_glob_test(g_braces_alpha_range2 "{aardvark..antelope}" a)
fails(g_braces_alpha_range2)
new_glob_test(g_braces_alpha_range3 "{aardvark..antelope}" aardvark)
fails(g_braces_alpha_range3)
new_glob_test(g_braces_alpha_range4 "{aardvark..antelope}" agreement)
fails(g_braces_alpha_range4)
new_glob_test(g_braces_alpha_range5 "{aardvark..antelope}" antelope)
fails(g_braces_alpha_range5)
new_glob_test(g_braces_alpha_range6 "{aardvark..antelope}" antimatter)
fails(g_braces_alpha_range6)


## test EditorConfig files with UTF-8 characters larger than 127
new_glob_test(g_utf_8_char "中文.txt" "中文.txt")

## Tests for ** - matches over path separator
new_glob_test(g_star_star_over_separator1 "a**z.c" a/z.c)
new_glob_test(g_star_star_over_separator2 "a**z.c" amnz.c)
new_glob_test(g_star_star_over_separator3 "a**z.c" am/nz.c)
new_glob_test(g_star_star_over_separator4 "a**z.c" a/mnz.c)
new_glob_test(g_star_star_over_separator5 "a**z.c" amn/z.c)
new_glob_test(g_star_star_over_separator6 "a**z.c" a/mn/z.c)

new_glob_test(g_star_star_over_separator7 "b/**z.c" b/z.c)
new_glob_test(g_star_star_over_separator8 "b/**z.c" b/mnz.c)
new_glob_test(g_star_star_over_separator9 "b/**z.c" b/mn/z.c)
new_glob_test(g_star_star_over_separator10 "b/**z.c" bmnz.c)
fails(g_star_star_over_separator10)
new_glob_test(g_star_star_over_separator11 "b/**z.c" bm/nz.c)
fails(g_star_star_over_separator11)
new_glob_test(g_star_star_over_separator12 "b/**z.c" bmn/z.c)
fails(g_star_star_over_separator12)

new_glob_test(g_star_star_over_separator13 "c**/z.c" c/z.c)
new_glob_test(g_star_star_over_separator14 "c**/z.c" cmn/z.c)
new_glob_test(g_star_star_over_separator15 "c**/z.c" c/mn/z.c)
new_glob_test(g_star_star_over_separator16 "c**/z.c" cmnz.c)
fails(g_star_star_over_separator16)
new_glob_test(g_star_star_over_separator17 "c**/z.c" cm/nz.c)
fails(g_star_star_over_separator17)
new_glob_test(g_star_star_over_separator18 "c**/z.c" c/mnz.c)
fails(g_star_star_over_separator18)

new_glob_test(g_star_star_over_separator19 "d/**/z.c" d/z.c)
new_glob_test(g_star_star_over_separator20 "d/**/z.c" d/mn/z.c)
new_glob_test(g_star_star_over_separator21 "d/**/z.c" dmnz.c)
fails(g_star_star_over_separator21)
new_glob_test(g_star_star_over_separator22 "d/**/z.c" dm/nz.c)
fails(g_star_star_over_separator22)
new_glob_test(g_star_star_over_separator23 "d/**/z.c" d/mnz.c)
fails(g_star_star_over_separator23)
new_glob_test(g_star_star_over_separator24 "d/**/z.c" dmn/z.c)
fails(g_star_star_over_separator24)
