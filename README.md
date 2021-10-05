# EditorConfig VimScript Core v0.1

[![Appveyor Badge](https://ci.appveyor.com/api/projects/status/github/cxw42/editorconfig-core-vimscript?svg=true)](https://ci.appveyor.com/project/cxw42/editorconfig-core-vimscript)

The EditorConfig VimScript Core provides the same functionality as the
[EditorConfig C Core](https://github.com/editorconfig/editorconfig-core).

# Usage

**Note:** This is just a core --- it does not integrate with your Vim
workflow yet.  That is coming soon!

 - From the command line: `./editorconfig [opts] <filename>`
 - From Vim: clone or unzip into `~/.vim/bundle/editorconfig-core-vimscript`
   and use Pathogen, or otherwise install using your favorite git repo tool.

The command line program requires a bash shell.  However, it is only used
to run tests.  A bash shell is not required to use this core in Vim.

# EditorConfig Project

EditorConfig makes it easy to maintain the correct coding style when switching
between different text editors and between different projects.  The
EditorConfig project maintains a file format and plugins for various text
editors which allow this file format to be read and used by those editors.  For
information on the file format and supported text editors, see the
[EditorConfig website](http://editorconfig.org).

# License

See LICENSE.BSD file for licensing details.

<!--
========================
EditorConfig VimScript Core
========================

EditorConfig VimScript Core provides the same functionality as the
`EditorConfig C Core <https://github.com/editorconfig/editorconfig-core>`_.
EditorConfig VimScript core can be used as a command line program or as an
importable library.

EditorConfig Project
====================

EditorConfig makes it easy to maintain the correct coding style when switching
between different text editors and between different projects.  The
EditorConfig project maintains a file format and plugins for various text
editors which allow this file format to be read and used by those editors.  For
information on the file format and supported text editors, see the
`EditorConfig website <http://editorconfig.org>`_.

Using as a Library
==================

Basic example use of EditorConfig VimScript Core as a library:

.. code-block:: python

    from editorconfig import get_properties, EditorConfigError

    filename = "/home/zoidberg/humans/anatomy.md"

    try:
        options = get_properties(filename)
    except EditorConfigError:
        print "Error occurred while getting EditorConfig properties"
    else:
        for key, value in options.items():
            print "%s=%s" % (key, value)

For details, please take a look at the `online documentation
<http://pydocs.editorconfig.org>`_.

Running Test Cases
==================

`Cmake <http://www.cmake.org>`_ has to be installed first. Run the test cases
using the following commands::

    cmake .
    ctest .

Use ``-DPYTHON_EXECUTABLE`` to run the tests using an alternative versions of
VimScript (e.g. VimScript 3)::

    cmake -DPYTHON_EXECUTABLE=/usr/bin/python3 .
    ctest .

-->
