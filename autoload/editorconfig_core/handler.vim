" autoload/editorconfig_core/handler.vim: Main worker for
" editorconfig-core-vimscript.
" Copyright (c) 2018 Chris White.  All rights reserved.

" Return full filepath for filename in each directory in and above path.
" Input path must be an absolute path.
" TODO shellslash/shellescape?
function! s:get_filenames(path, config_filename)
    let l:path = a:path
    let l:path_list = []
    while 1
        call add(l:path_list, editorconfig_core#util#path_join(l:path, a:config_filename))
        let l:newpath = fnamemodify(l:path, ':h')
        if l:path ==? l:newpath || !strlen(l:path)
            break
        endif
        let l:path = l:newpath
    endwhile
    return l:path_list
endfunction

" === Python source ===================================================== {{{1

"class EditorConfigHandler(object):

"    """
"    Allows locating and parsing of EditorConfig files for given filename

"    In addition to the constructor a single public method is provided,
"    ``get_configurations`` which returns the EditorConfig options for
"    the ``filepath`` specified to the constructor.

"    """

"    def __init__(self, filepath, conf_filename='.editorconfig',
"                 version=VERSION):
"        """Create EditorConfigHandler for matching given filepath"""
"        self.filepath = filepath
"        self.conf_filename = conf_filename
"        self.version = version
"        self.options = None

" Find EditorConfig files and return all options matching target_filename.
" Throws on failure.
"    def get_configurations(self):
function! editorconfig_core#handler#get_configurations(target_filename, config_filename)
    " TODO? support VERSION checks?

"    Special exceptions that may be raised by this function include:
"    - ``VersionError``: self.version is invalid EditorConfig version
"    - ``PathError``: self.filepath is not a valid absolute filepath
"    - ``ParsingError``: improperly formatted EditorConfig file found

    if !s:check_assertions(a:config_filename, a:target_filename)
        throw "Assertions failed"
    endif

    let l:fullpath = fnamemodify(a:target_filename,':p')
    let l:path = fnamemodify(l:fullpath, ':h')
    let l:filename = fnamemodify(l:fullpath, ':t')
    let l:conf_files = s:get_filenames(l:path, a:config_filename)

    let l:retval = {}

    " Attempt to find and parse every EditorConfig file in filetree
    for l:filename in l:conf_files
        echom 'Trying ' . l:filename
        let l:parsed = editorconfig_core#ini#read_ini_file(l:filename, a:target_filename)
        if !has_key(l:parsed, 'options')
            continue
        endif

        " Merge new EditorConfig file's options into current options
        let l:old_options = l:retval
        let l:retval = l:parsed.options
        call extend(l:retval, l:old_options, 'force')

        " Stop parsing if parsed file has a ``root = true`` option
        if l:parsed.root
            break
        endif
    endfor

    call s:preprocess_values(l:retval)
    return l:retval
endfunction

function! s:check_assertions(config_filename, target_filename)
    return 1
" TODO
"    """Raise error if filepath or version have invalid values"""

"    # Raise ``PathError`` if filepath isn't an absolute path
"    if not os.path.isabs(self.filepath):
"        raise PathError("Input file must be a full path name.")

"    # Raise ``VersionError`` if version specified is greater than current
"    if self.version is not None and self.version[:3] > VERSION[:3]:
"        raise VersionError("Required version is greater than the current version.")
endfunction

" Preprocess option values for consumption by plugins.  Modifies its argument
" in place.
function! s:preprocess_values(options)

"    opts = self.options

"    # Lowercase option value for certain options
"    for name in ["end_of_line", "indent_style", "indent_size",
"                 "insert_final_newline", "trim_trailing_whitespace",
"                 "charset"]:
"        if name in opts:
"            opts[name] = opts[name].lower()

"    # Set indent_size to "tab" if indent_size is unspecified and
"    # indent_style is set to "tab".
"    if (opts.get("indent_style") == "tab" and
"            not "indent_size" in opts and self.version >= (0, 10, 0)):
"        opts["indent_size"] = "tab"

"    # Set tab_width to indent_size if indent_size is specified and
"    # tab_width is unspecified
"    if ("indent_size" in opts and "tab_width" not in opts and
"            opts["indent_size"] != "tab"):
"        opts["tab_width"] = opts["indent_size"]

"    # Set indent_size to tab_width if indent_size is "tab"
"    if ("indent_size" in opts and "tab_width" in opts and
"            opts["indent_size"] == "tab"):
"        opts["indent_size"] = opts["tab_width"]
endfunction

" }}}1

" === Copyright notices ================================================= {{{2
""""EditorConfig file handler

"Provides ``EditorConfigHandler`` class for locating and parsing
"EditorConfig files relevant to a given filepath.

"Licensed under Simplified BSD License (see LICENSE.BSD file).

""""
" }}}2
" vi: set fdm=marker fdl=1:
