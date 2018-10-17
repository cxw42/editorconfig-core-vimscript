" autoload/editorconfig_core.vim: top-level functions for
" editorconfig-core-vimscript.
" Copyright (c) 2018 Chris White.  All rights reserved.

" === CLI =============================================================== {{{1

" For use from the command line.  Output settings for in_name to
" the buffer named out_name.  If an optional argument is provided, it is the
" name of the config file to use (default '.editorconfig').
" TODO support multiple files
"
" filename (if any)
" @param names  {Dictionary}    The names of the files to use for this run
" @param job    {Dictionary}    What to do - same format as the input of
"                               editorconfig_core#handler#get_configurations
function! editorconfig_core#currbuf_cli(names, job) " out_name, in_name, ...
    let l:output = []

    if has_key(a:names, 'dump')
        execute 'redir! > ' . fnameescape(a:names.dump)
        echom 'Names: ' . string(a:names)
        echom 'Job: ' . string(a:job)
    endif

    let l:options = editorconfig_core#handler#get_configurations(a:job)

    if has_key(a:names, 'dump')
        echom 'Result: ' . string(l:options)
    endif

    for [ l:key, l:value ] in items(l:options)
        let l:output += [ l:key . '=' . l:value ]
    endfor

    " Write the output file
    call writefile(l:output, a:names.output)
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
