# EditorConfig VimScript Core

EditorConfig VimScript Core provides the same functionality as the
[EditorConfig C Core](https://github.com/editorconfig/editorconfig-core>).

# Usage

 - From the command line: `./editorconfig [opts] <filename>`
 - From Vim: clone or unzip into `~/.vim/bundle/editorconfig-core-vimscript`
   and use Pathogen, or otherwise install using your favorite git repo tool.

The command line program requires a bash shell.  However, it is only used
to run tests.  A bash shell is not required to use this core in Vim.

*Caution:* Before you install this, make sure you *uninstall* the
editorconfig-vim-plugin.  That plugin uses the Python core.  This core
is fully integrated into Vim and does not require a separate plugin.

# EditorConfig Project

EditorConfig makes it easy to maintain the correct coding style when switching
between different text editors and between different projects.  The
EditorConfig project maintains a file format and plugins for various text
editors which allow this file format to be read and used by those editors.  For
information on the file format and supported text editors, see the
[EditorConfig website](http://editorconfig.org>).

# License

See LICENSE.BSD file for licensing details.
