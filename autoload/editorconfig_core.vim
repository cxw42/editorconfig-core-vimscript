" autoload/editorconfig_core.vim: top-level functions for
" editorconfig-core-vimscript.
" Copyright (c) 2018 Chris White.  All rights reserved.

" === CLI =============================================================== {{{1

" For use from the command line.  Output settings for the current buffer to
" the buffer named out_name.  If an optional argument is provided, it is the
" name of the config file to use (default '.editorconfig').
" TODO support multiple files
function! editorconfig_core#currbuf_cli(out_name, ...)
    let l:output = []

    let l:confname = '.editorconfig'
    if a:0 >= 1
        let l:confname = a:1
    endif

    let l:fullname = expand("%:p")

    "let l:output += ['Checking <' . l:fullname .'>']
    "let l:output += ['Confname <' . l:confname .'>']
    let l:options = editorconfig_core#handler#get_configurations(l:fullname, l:confname)
    "let l:output += ['Raw opts: ' . string(l:options)]

    for [ l:key, l:value ] in items(l:options)
        let l:output += [ l:key . '=' . l:value ]
    endfor

    " Write the output file
    call writefile(l:output, a:out_name)
endfunction "editorconfig_core#currbuf_cli

" }}}1
" === Caching =========================================================== {{{1

" Cache for .editorconfig files.  Full path -> settings map.
let s:config_cache = {}

" Cache for settings to be applied.
" Full path of the file being edited -> settings map.
let s:computed_cache = {}

function! editorconfig_core#clear_caches()
    let s:config_cache = {}
    let s:computed_cache = {}
endfunction "editorconfig_core#currbuf_cli

" }}}1

" vi: set fdm=marker:
