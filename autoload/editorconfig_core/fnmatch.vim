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

"def translate(pat, nested=False):
"    """Translate a shell PATTERN to a regular expression.
"
"    There is no way to quote meta-characters.
"    """
function! editorconfig_core#fnmatch#translate(pat, ...)
    let l:nested = 0
    if a:0 then
        let l:nested = a:1
    endif

    let l:index = 0
    let l:length = strlen(pat)  " Current index and length of pattern
    let l:brace_level = 0
    let l:in_brackets = False
    let l:result = ''
    let l:is_escaped = False

"    matching_braces = (len(LEFT_BRACE.findall(pat)) ==
"                       len(RIGHT_BRACE.findall(pat)))
    let l:left_braces=[]
    let l:right_braces=[]
    substitute(pat, s:LEFT_BRACE, '\=add(l:left_braces, 1)', 'g')
    substitute(pat, s:RIGHT_BRACE, '\=add(l:right_braces, 1)', 'g')
    " Thanks to http://jeromebelleman.gitlab.io/posts/productivity/vimsub/
    let l:matching_braces = (len(l:left_braces) == len(l:right_braces))

    let l:numeric_groups = []
    while l:index < l:length
        let l:current_char = a:pat[l:index]
        let l:index += 1
"        if current_char == '*':
"            pos = index
"            if pos < length and pat[pos] == '*':
"                result += '.*'
"            else:
"                result += '[^/]*'
"        elif current_char == '?':
"            result += '.'
"        elif current_char == '[':
"            if in_brackets:
"                result += '\\['
"            else:
"                pos = index
"                has_slash = False
"                while pos < length and pat[pos] != ']':
"                    if pat[pos] == '/' and pat[pos-1] != '\\':
"                        has_slash = True
"                        break
"                    pos += 1
"                if has_slash:
"                    result += '\\[' + pat[index:(pos + 1)] + '\\]'
"                    index = pos + 2
"                else:
"                    if index < length and pat[index] in '!^':
"                        index += 1
"                        result += '[^'
"                    else:
"                        result += '['
"                    in_brackets = True
"        elif current_char == '-':
"            if in_brackets:
"                result += current_char
"            else:
"                result += '\\' + current_char
"        elif current_char == ']':
"            result += current_char
"            in_brackets = False
"        elif current_char == '{':
"            pos = index
"            has_comma = False
"            while pos < length and (pat[pos] != '}' or is_escaped):
"                if pat[pos] == ',' and not is_escaped:
"                    has_comma = True
"                    break
"                is_escaped = pat[pos] == '\\' and not is_escaped
"                pos += 1
"            if not has_comma and pos < length:
"                num_range = NUMERIC_RANGE.match(pat[index:pos])
"                if num_range:
"                    numeric_groups.append(map(int, num_range.groups()))
"                    result += "([+-]?\d+)"
"                else:
"                    inner_result, inner_groups = translate(pat[index:pos],
"                                                           nested=True)
"                    result += '\\{%s\\}' % (inner_result,)
"                    numeric_groups += inner_groups
"                index = pos + 1
"            elif matching_braces:
"                result += '(?:'
"                brace_level += 1
"            else:
"                result += '\\{'
"        elif current_char == ',':
"            if brace_level > 0 and not is_escaped:
"                result += '|'
"            else:
"                result += '\\,'
"        elif current_char == '}':
"            if brace_level > 0 and not is_escaped:
"                result += ')'
"                brace_level -= 1
"            else:
"                result += '\\}'
"        elif current_char == '/':
"            if pat[index:(index + 3)] == "**/":
"                result += "(?:/|/.*/)"
"                index += 3
"            else:
"                result += '/'
"        elif current_char != '\\':
"            result += re.escape(current_char)
"        if current_char == '\\':
"            if is_escaped:
"                result += re.escape(current_char)
"            is_escaped = not is_escaped
"        else:
"            is_escaped = False
    endwhile

    if not l:nested
        let l:result += '$'     "'\Z(?ms)'
            " TODO do we need to set MULTILINE and DOTALL?  Vim has \_.
            " instead of DOTALL, and \_^ / \_$ instead of MULTILINE.
    endif
    return [l:result, l:numeric_groups]
endfunction #editorconfig_core#fnmatch#translate

let s:_cache = {}

function! s:cached_translate(pat)
    if not pat in _cache:
        res, num_groups = translate(pat)
        regex = re.compile(res)
        s:_cache[a:pat] = regex, num_groups
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
"        return False
"    pattern_matched = True
"    for (num, (min_num, max_num)) in zip(match.groups(), num_groups):
"        if num[0] == '0' or not (min_num <= int(num) <= max_num):
"            pattern_matched = False
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
