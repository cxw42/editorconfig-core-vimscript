" util.vim: part of editorconfig-core-vimscript

" ('a','b')->'a/b'; ('a/','b')->'a/b'.
function! editorconfig_core#util#path_join(a, b)
    " TODO shellescape/shellslash?
    "echom 'Joining <' . a:a . '> and <' . a:b . '>'
    "echom 'Length is ' . strlen(a:a)
    "echom 'Last char is ' . char2nr(a:a[-1])
    if a:a !~# '\v%(\/|\\)$'
        return a:a . '/' . a:b
    else
        return a:a . a:b
    endif
endfunction

" The following function is modified from
" https://github.com/xolox/vim-misc/blob/master/autoload/xolox/misc/os.vim
" Copyright (c) 2015 Peter Odding <peter@peterodding.com>
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.
function! editorconfig_core#util#is_win()
    " Returns 1 (true) when on Microsoft Windows, 0 (false) otherwise.
    return has('win16') || has('win32') || has('win64')
endfunction

function! editorconfig_core#util#strip(s)
    return substitute(a:s, '\v^\s+|\s+$','','g')
endfunction
