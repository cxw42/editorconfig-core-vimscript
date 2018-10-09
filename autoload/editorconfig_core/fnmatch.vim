" autoload/editorconfig_core/fnmatch.vim: Globbing for
" editorconfig-core-vimscript.  Ported from the Python core's fnmatch.py.
" Copyright (c) 2018 Chris White.  All rights reserved.

" === Regexes =========================================================== {{{1
let s:LEFT_BRACE = '\v%(^|[^\\])\{'
"LEFT_BRACE = re.compile(
"    r"""
"
"    (?: ^ | [^\\] )     # Beginning of string or a character besides "\"
"
"    \{                  # "{"
"
"    """, re.VERBOSE
")

let s:RIGHT_BRACE = '\v%(^|[^\\])\}'
"RIGHT_BRACE = re.compile(
"    r"""
"
"    (?: ^ | [^\\] )     # Beginning of string or a character besides "\"
"
"    \}                  # "}"
"
"    """, re.VERBOSE
")

let s:NUMERIC_RANGE = '\v([+-]?\d+)' . '\.\.' . '([+-]?\d+)'
"NUMERIC_RANGE = re.compile(
"    r"""
"    (               # Capture a number
"        [+-] ?      # Zero or one "+" or "-" characters
"        \d +        # One or more digits
"    )
"
"    \.\.            # ".."
"
"    (               # Capture a number
"        [+-] ?      # Zero or one "+" or "-" characters
"        \d +        # One or more digits
"    )
"    """, re.VERBOSE
")

" }}}1
" === Translating globs to patterns ===================================== {{{1

function! s:re_escape(text)
    return substitute(a:text, '\v([^0-9a-zA-Z_])', '\\\1', 'g')
endfunction

"def translate(pat, nested=0):
"    """Translate a shell PATTERN to a regular expression.
"
"    There is no way to quote meta-characters.
"    """
function! editorconfig_core#fnmatch#translate(pat, ...)
    let l:nested = 0
    if a:0
        let l:nested = a:1
    endif

    let l:index = 0
    let l:length = strlen(a:pat)  " Current index and length of pattern
    let l:brace_level = 0
    let l:in_brackets = 0
    let l:result = '\v'     " very magic
    let l:is_escaped = 0

    let l:left_braces=[]
    let l:right_braces=[]
    call substitute(a:pat, s:LEFT_BRACE, '\=add(l:left_braces, 1)', 'g')
    call substitute(a:pat, s:RIGHT_BRACE, '\=add(l:right_braces, 1)', 'g')
    " Thanks to http://jeromebelleman.gitlab.io/posts/productivity/vimsub/
    let l:matching_braces = (len(l:left_braces) == len(l:right_braces))

    " TODO update the escaping throughout

    let l:numeric_groups = []
    while l:index < l:length
        let l:current_char = a:pat[l:index]
        let l:index += 1
        if l:current_char ==# '*'
            let l:pos = l:index
            if l:pos < l:length && a:pat[l:pos] ==# '*'
                let l:result .= '.*'
            else
                let l:result .= '[^/]*'
            endif
        elseif l:current_char ==# '?'
            let l:result .= '.'
        elseif l:current_char ==# '['
            if l:in_brackets
                let l:result .= '\\['
            else
                let l:pos = l:index
                let l:has_slash = 0
                while l:pos < l:length && a:pat[l:pos] != ']'
                    if a:pat[l:pos] ==# '/' && a:pat[l:pos-1] != '\\'
                        let has_slash = 1
                        break
                    endif
                    let l:pos += 1
                endwhile
                if l:has_slash
                    let l:result .= '\\[' + a:pat[l:index:(l:pos + 1)] + '\\]'
                    let l:index = l:pos + 2
                else
                    if l:index < l:length && a:pat[l:index] in '!^'
                        let l:index += 1
                        let l:result .= '[^'
                    else
                        let l:result .= '['
                    endif
                    let l:in_brackets = 1
                endif
            endif
        elseif l:current_char ==# '-'
            if l:in_brackets
                let l:result .= l:current_char
            else
                let l:result .= '\\' + l:current_char
            endif
        elseif l:current_char ==# ']'
            let l:result .= l:current_char
            let l:in_brackets = 0
        elseif l:current_char ==# '{'
            let l:pos = l:index
            let l:has_comma = 0
            while l:pos < l:length && (a:pat[l:pos] !=# '}' || l:is_escaped)
                if a:pat[l:pos] ==# ',' && ! l:is_escaped
                    let l:has_comma = 1
                    break
                endif
                let l:is_escaped = a:pat[l:pos] ==# '\\' && ! l:is_escaped
                let l:pos += 1
            endwhile
            if ! l:has_comma && l:pos < l:length
                let l:num_range = NUMERIC_RANGE.match(a:pat[l:index:l:pos])
                if l:num_range
                    " TODO
"                    numeric_groups.append(map(int, num_range.groups()))
                    let l:result .= "([+-]?\d+)"
                else
                    let l:inner_xlat = translate(a:pat[l:index : l:pos], 1)
                    let l:inner_result = l:inner_xlat[0]
                    let l:inner_groups = l:inner_xlat[1]
                    let l:result .= '\\{' . l:inner_result . '\\}'
                    let l:numeric_groups += l:inner_groups
                endif
                let l:index = l:pos + 1
            elseif l:matching_braces
                let l:result .= '(?:'
                let l:brace_level += 1
            else
                let l:result .= '\\{'
            endif
        elseif l:current_char ==# ','
            if l:brace_level > 0 && ! l:is_escaped
                let l:result .= '|'
            else
                let l:result .= '\\,'
            endif
        elseif l:current_char ==# '}'
            if l:brace_level > 0 && ! l:is_escaped
                let l:result .= ')'
                let l:brace_level -= 1
            else
                let l:result .= '\\}'
            endif
        elseif l:current_char ==# '/'
            if a:pat[l:index : (l:index + 3)] ==# "**/"
                let l:result .= "(?:/|/.*/)"
                let l:index += 3
            else
                let l:result .= '/'
            endif
        elseif l:current_char != '\\'
            let l:result .= s:re_escape(l:current_char)
        endif
        if l:current_char ==# '\\'
            if l:is_escaped
                let l:result .= s:re_escape(l:current_char)
            endif
            let l:is_escaped = ! l:is_escaped
        else
            let l:is_escaped = 0
        endif
    endwhile

    if ! l:nested
        let l:result .= '$'     "'\Z(?ms)'
            " TODO do we need to set MULTILINE and DOTALL?  Vim has \_.
            " instead of DOTALL, and \_^ / \_$ instead of MULTILINE.
    endif
    return [l:result, l:numeric_groups]
endfunction " #editorconfig_core#fnmatch#translate

let s:_cache = {}

function! s:cached_translate(pat)
    if ! has_key(s:_cache, a:pat)
        "regex = re.compile(res)
        s:_cache[a:pat] = translate(pat)    " we don't compile the regex
    endif
    return s:_cache[a:pat]
endfunction

" }}}1
" === Matching functions ================================================ {{{1

function! editorconfig_core#fnmatch#fnmatch(name, pat)
"def fnmatch(name, pat):
"    """Test whether FILENAME matches PATTERN.
"
"    Patterns are Unix shell style:
"
"    - ``*``             matches everything except path separator
"    - ``**``            matches everything
"    - ``?``             matches any single character
"    - ``[seq]``         matches any character in seq
"    - ``[!seq]``        matches any char not in seq
"    - ``{s1,s2,s3}``    matches any of the strings given (separated by commas)
"
"    An initial period in FILENAME is not special.
"    Both FILENAME and PATTERN are first case-normalized
"    if the operating system requires it.
"    If you don't want this, use fnmatchcase(FILENAME, PATTERN).
"    """
"
    let l:localname = fnamemodify(a:name, ':p')
        " TODO does this normalize case?
"    name = os.path.normpath(name).replace(os.sep, "/")
    return fnmatchcase(l:localname, a:pat)
endfunction

"def fnmatchcase(name, pat):
"    """Test whether FILENAME matches PATTERN, including case.
"
"    This is a version of fnmatch() which doesn't case-normalize
"    its arguments.
"    """
"
"    regex, num_groups = cached_translate(pat)
"    match = regex.match(name)
"    if not match:
"        return 0
"    pattern_matched = 1
"    for (num, (min_num, max_num)) in zip(match.groups(), num_groups):
"        if num[0] == '0' or not (min_num <= int(num) <= max_num):
"            pattern_matched = 0
"            break
"    return pattern_matched

" }}}1
" === Python source ===================================================== {{{1

""""Filename matching with shell patterns.
"
"fnmatch(FILENAME, PATTERN) matches according to the local convention.
"fnmatchcase(FILENAME, PATTERN) always takes case in account.
"
"The functions operate by translating the pattern into a regular
"expression.  They cache the compiled regular expressions for speed.
"
"The function translate(PATTERN) returns a regular expression
"corresponding to PATTERN.  (It does not compile it.)
"
"Based on code from fnmatch.py file distributed with Python 2.6.
"
"Licensed under PSF License (see LICENSE.PSF file).
"
"Changes to original fnmatch module:
"- translate function supports ``*`` and ``**`` similarly to fnmatch C library
""""
"
"import os
"import re
"
"
"__all__ = ["fnmatch", "fnmatchcase", "translate"]


"

" }}}1

" vi: set fdm=marker:
