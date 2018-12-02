" plugin/editorconfig_core.vim: Initial plugin loader for
" editorconfig-core-vimscript.
" Copyright (c) 2018 Chris White.  All rights reserved.

" check whether this script is already loaded
if exists("g:loaded_editorconfig_core_vimscript")
    finish
endif
let g:loaded_editorconfig_core_vimscript = 1

let s:saved_cpo = &cpo
set cpo&vim

" variables {{{1
if !exists('g:editorconfig_core_vimscript_debug')
    let g:editorconfig_core_vimscript_debug = 0
endif
" }}}1

if g:editorconfig_core_vimscript_debug
    echom 'editorconfig-core-vimscript plugin loaded'
endif

" === Copyright notices ================================================= {{{2
" Copyright (c) 2011-2018 Christopher White
"
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
"
" 1. Redistributions of source code must retain the above copyright notice,
"    this list of conditions and the following disclaimer.
" 2. Redistributions in binary form must reproduce the above copyright notice,
"    this list of conditions and the following disclaimer in the documentation
"    and/or other materials provided with the distribution.
"
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
" IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
" ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
" LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
" CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
" SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
" INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
" CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
" ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
" POSSIBILITY OF SUCH DAMAGE.
" }}}2

let &cpo = s:saved_cpo
unlet! s:saved_cpo

" vi: set fdm=marker fdl=1:
