#!/bin/bash
# runtest.sh: Run a single test of editorconfig-core-vimscript.
# This script is CC-BY-SA 3.0.

# Get the directory of this script.  From
# https://stackoverflow.com/a/246128/2877364 by
# https://stackoverflow.com/users/407731 et al.

DIR=
function get_dir()
{
    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
      DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
      SOURCE="$(readlink "$SOURCE")"
      [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
}

get_dir

###

confname='.editorconfig'
globpat=

while getopts 'vf:g:' opt ; do
    case "$opt" in
        (v) echo "EditorConfig VimScript Core Version 0.12.2"
            exit 0
            ;;

        (f) confname="$OPTARG"
            ;;
        # TODO support -b[, -h?]

        # Not in EditorConfig Core
        (g) globpat="$OPTARG"
            ;;

    esac
done

shift $(( $OPTIND - 1 ))

if (( "$#" < 1 )); then
    exit 1
fi

fn="$(mktemp)"      # Output file

vim_args=()

if [[ $globpat ]]; then
    vim_args+=(
        -c "if editorconfig_core#fnmatch#fnmatch('${1//\'/\'\'}','${globpat//\'/\'\'}') | exit | else | cquit | endif"
        -c 'q!'
    )
else
    vim_args+=(
        -c "call editorconfig_core#currbuf_cli('${fn//\'/\'\'}', '${confname//\'/\'\'}')"
        -c 'q!'
        -- "$1"
    )
fi

# Run editorconfig.  Thanks for options to
# http://vim.wikia.com/wiki/Vim_as_a_system_interpreter_for_vimscript .
# Add -V1 to the below for debugging output.
vim -nNes -i NONE -u NONE -U NONE \
    -c "set runtimepath+=$DIR" \
    "${vim_args[@]}" \
    </dev/null
vimstatus="$?"
if [[ $vimstatus -eq 0 ]]; then
    cat "$fn"
fi

rm -f "$fn"

exit "$vimstatus"
