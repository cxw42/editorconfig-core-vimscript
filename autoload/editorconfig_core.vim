" For use from the command line.  Output settings for buffer 1 to
" the buffer named out_name.
function! editorconfig_core#currbuf_cli(out_name)
    buffer 1
    let l:fullname = expand("%:p")

    " Open the output file
    execute "edit! " . a:out_name
    0put =l:fullname    " Full path to the input file goes on the first line
                        " of the output file
    w!
endfunction
