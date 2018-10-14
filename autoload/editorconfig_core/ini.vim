" autoload/editorconfig_core/ini.vim: Config-file parser for
" editorconfig-core-vimscript.  Modifed from the Python core's ini.py.
" Copyright (c) 2018 Chris White.  All rights reserved.

" === Regexes =========================================================== {{{1
" Regular expressions for parsing section headers and options.
" Allow ``]`` and escaped ``;`` and ``#`` characters in section headers
let s:SECTCRE = '\v\s*\[(%([^\\#;]|\\\#|\\\;)+)\]'
"    SECTCRE = re.compile(
"        r"""

"        \s *                                # Optional whitespace
"        \[                                  # Opening square brace

"        (?P<header>                         # One or more characters excluding
"            ( [^\#;] | \\\# | \\; ) +       # unescaped # and ; characters
"        )

"        \]                                  # Closing square brace

"        """, re.VERBOSE
"    )

" Regular expression for parsing option name/values.
" Allow any amount of whitespaces, followed by separator
" (either ``:`` or ``=``), followed by any amount of whitespace and then
" any characters to eol
let s:OPTCRE = '\v\s*([^:=\s][^:=]*)\s*([:=])\s*(.*)$'
"    OPTCRE = re.compile(
"        r"""

"        \s *                                # Optional whitespace
"        (?P<option>                         # One or more characters excluding
"            [^:=\s]                         # : a = characters (and first
"            [^:=] *                         # must not be whitespace)
"        )
"        \s *                                # Optional whitespace
"        (?P<vi>
"            [:=]                            # Single = or : character
"        )
"        \s *                                # Optional whitespace
"        (?P<value>
"            . *                             # One or more characters
"        )
"        $

"        """, re.VERBOSE
"    )

" }}}1
" === Python source ===================================================== {{{1
""""EditorConfig file parser

"Based on code from ConfigParser.py file distributed with Python 2.6.

"Licensed under PSF License (see LICENSE.PSF file).

"Changes to original ConfigParser:

"- Special characters can be used in section names
"- Octothorpe can be used for comments (not just at beginning of line)
"- Only track INI options in sections that match target filename
"- Stop parsing files with when ``root = true`` is found

""""

"import posixpath
"import re
"from codecs import open
"from collections import OrderedDict
"from os import sep
"from os.path import dirname, normpath

"from editorconfig.compat import u
"from editorconfig.exceptions import ParsingError
"from editorconfig.fnmatch import fnmatch


"__all__ = ["ParsingError", "EditorConfigParser"]


"class EditorConfigParser(object):

"    """Parser for EditorConfig-style configuration files

"    Based on RawConfigParser from ConfigParser.py in Python 2.6.
"    """


"    def __init__(self, filename):
"        self.filename = filename
"        self.options = OrderedDict()
"        self.root_file = False
" }}}1

function! s:matches_filename(target_filename, glob)
"    """Return True if section glob matches target_filename"""
"    config_dirname = normpath(dirname(config_filename)).replace(sep, '/')
    let l:glob = substitute(a:glob, '\v\\\#', '#', 'g')
    glob = glob.replace("\\;", ";")
    if '/' in glob
"        if glob.find('/') == 0:
"            glob = glob[1:]
"        glob = posixpath.join(config_dirname, glob)
    else
"        glob = posixpath.join('**/', glob)
    endif
    return editorconfig_core#fnmatch#fnmatch(self.filename, glob)
endfunction

" Read \p config_filename and return the options applicable to
" \p target_filename.
function! editorconfig_core#ini#read_ini_file(config_filename, target_filename)
    let l:oldenc = &encoding

    try     " so &encoding will always be reset
        let &encoding = 'utf-8'     " so readfile() will strip BOM
        let l:lines = readfile(a:config_filename)
        let result = s:parse(a:config_filename, a:target_filename, l:lines)
    catch
        let &encoding = l:oldenc
        throw v:exception   " rethrow
    endtry

    let &encoding = l:oldenc
    return result
endfunction

function! s:parse(config_filename, target_filename, lines)
"    """Parse a sectioned setup file.

"    The sections in setup file contains a title line at the top,
"    indicated by a name in square brackets (`[]'), plus key/value
"    options lines, indicated by `name: value' format lines.
"    Continuations are represented by an embedded newline then
"    leading whitespace.  Blank lines, lines beginning with a '#',
"    and just about everything else are ignored.
"    """

    let l:in_section = 0
    let l:matching_section = 0
    let l:optname = ''
    let l:lineno = 0
    let l:e = []    " Errors, if any

    let l:retval = {}   " Options applicable to this

    while 1
        if l:lineno == len(a:lines)
            break
        endif

        let l:line = a:lines[l:lineno]
        let l:lineno = l:lineno + 1

        " comment or blank line?
        if substitute(l:line, '\v^\s+|\s$','','g') ==# ''
            continue
        endif
        if l:line =~# '\v^[#;]'
            continue
        endif

        " a section header or option header?
        " is it a section header?
        let l:mo = matchlist(l:line, s:SECTCRE)
        if len(l:mo):
            let l:sectname = l:mo[1]
            let l:in_section = 1
            let l:matching_section = s:matches_filename(a:target_filename, l:sectname)
            " So sections can't start with a continuation line
            let l:optname = ''
        " an option line?
        else
            let l:mo = matchlist(l:line, s:OPTCRE)
            if len(l:mo)
                let l:optname = mo[1]
                let l:optval = mo[3]
                if l:optval =~# '\v[;#]'
                    " ';' and '#' are comment delimiters only if
                    " preceded by a spacing character
                    let l:m = matchlist(l:optval, '\v(.{-}) [;#]')
                    if len(l:m)
                        let l:optval = l:m[1]
                    endif
                endif
                let l:optval = substitute(l:optval, '\v^\s+|\s+$', '', 'g')
                " allow empty values
                if l:optval ==? '""'
                    let l:optval = ''
                endif
                let l:optname = self.optionxform(l:optname)
                if !l:in_section && optname ==? 'root':
                    let self.root_file = (optval ==? 'true') " XXX
                endif
                if l:matching_section
                    let self.options[l:optname] = l:optval  " XXX
                endif
            else
                " a non-fatal parsing error occurred.  set up the
                " exception but keep going. the exception will be
                " raised at the end of the file and will contain a
                " list of all bogus lines
                add(e, "Parse error in '" . a:config_filename . "' at line " .
                    \ a:lineno . ": '" . l:line . "'")
            endif
        endif
    endwhile

    " if any parsing errors occurred, raise an exception
    if len(l:e)
        throw string(l:e)
    endif
endfunction!

function! s:optionxform(optionstr)
    let l:result = substitute(a:optionstr, '\v\s+$', '', 'g')   " rstrip
    return tolower(l:result)
endfunction


" vi: set fdm=marker:
