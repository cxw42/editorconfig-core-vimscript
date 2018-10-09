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

while getopts 'f:' opt ; do
    case "$opt" in
        (f) confname="$OPTARG"
            ;;
        # TODO support -b
    esac
done

shift $(( $OPTIND - 1 ))

if (( "$#" < 1 )); then
    exit 1
fi

fn="$(mktemp)"      # Output file

# Run editorconfig.  Thanks for options to
# http://vim.wikia.com/wiki/Vim_as_a_system_interpreter_for_vimscript .
# Add -V1 to the below for debugging output.
vim -nNes -i NONE -u NONE -U NONE \
    -c "set runtimepath+=$DIR" \
    -c "call editorconfig_core#currbuf_cli('${fn//\'/\'\'}', '${confname//\'/\'\'}')" \
    -c 'q!' \
    -- "$1" </dev/null
cat "$fn"
rm -f "$fn"

