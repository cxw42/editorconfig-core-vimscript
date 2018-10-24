# editorconfig.ps1: Editorconfig Vimscript core CLI, PowerShell version
# Copyright (c) 2018 Chris White.  CC-BY-SA 3.0.
# Thanks to https://cecs.wright.edu/~pmateti/Courses/233/Labs/Scripting/bashVsPowerShellTable.html
# by Gallagher and Mateti.

#Requires -Version 3

param (
    [alias("v", "version")][switch]$report_version = $false,  # report version
    [alias("b")][string]$set_version = '',  # set version
    [alias("f")][string]$config_name = '.editorconfig', # config filename
    [parameter(Position=0,ValueFromRemainingArguments=$true)][string[]]$files
        # Position=0 => start at the first positional argument - see
        # https://docs.microsoft.com/en-us/previous-versions/technet-magazine/jj554301(v=msdn.10)
)

# Get the directory of this script.  From
# https://stackoverflow.com/a/5466355/2877364 by
# https://stackoverflow.com/users/23283/jaredpar

$DIR = $PSScriptRoot

$debug=$env:EDITORCONFIG_DEBUG  # Debug filename

if($debug -and ($debug -notmatch '^/')) {
    # Relative to this script unless it starts with a slash.  This is because
    # cwd is usually not $DIR when testing.
    $debug="${DIR}/${debug}"
}

# Append a string to $debug in UTF-8 rather than the default UTF-16
filter D {
    if($debug) {
        echo $_ | Out-File -FilePath $debug -Encoding utf8 -Append
    }
}

if($debug) {
    echo "==================================" | D
    Get-Date -format F | D

    echo "Running in       $DIR"                | D
    echo "report version?  $report_version"     | D
    echo "set version to:  $set_version"        | D
    echo "config filename: $config_name"        | D
    echo "Filenames:       $files"              | D
}

if($report_version) {
    echo "EditorConfig VimScript Core Version 0.12.2"
    exit
}

if($files.count -lt 1) {
    exit
}

if($files[0] -eq '-') {
    echo "Reading filenames from stdin not yet supported" # TODO
    exit 1
}

### fn="$(mktemp)"      # Vim will write the settings into here.  ~stdout.
### script_output_fn="${debug:+$(mktemp)}"  # Vim's :messages.  ~stderr.

### cmd="call editorconfig_core#currbuf_cli({"

### # Names
### cmd+="'output':'${fn//\'/\'\'}', "
###     # filename to put the settings in
### [[ $debug ]] && cmd+=" 'dump':'${script_output_fn//\'/\'\'}', "
###     # where to put debug info

### # Filenames to get the settings for
### cmd+="'target':["
### for f in "$@" ; do
###     cmd+="'${f//\'/\'\'}', "
### done
### cmd+="],"
###     # filename to get the settings for

### # Job
### cmd+="}, {"
### [[ $config_name ]] && cmd+="'config':'${config_name//\'/\'\'}', "
###     # config name (e.g., .editorconfig)
### [[ $set_version ]] && cmd+="'version':'${set_version//\'/\'\'}', "
###     # version number we should behave as
### cmd+="})"

### vim_args=(
###     -c "set runtimepath+=$DIR"
###     -c "$cmd"
### )

# Run editorconfig.  Thanks for options to
# http://vim.wikia.com/wiki/Vim_as_a_system_interpreter_for_vimscript .
# Add -V1 to the below for debugging output.
# Do not output anything to stdout or stderr,
# since it messes up ctest's interpretation
# of the results.

### vim -nNes -i NONE -u NONE -U NONE \
###     "${vim_args[@]}" \
###     </dev/null &>> "${debug:-/dev/null}"
### vimstatus="$?"
### if [[ $vimstatus -eq 0 ]]; then
###     cat "$fn"
### fi

# Debug output cannot be included on stdout or stderr, because
# ctest's regex check looks both of those places.  Therefore, dump to a
# separate debugging file.

### if [[ $debug ]]
### then
###     echo "Current directory: $(pwd)" >> "$debug"
###     echo "Script directory: $DIR" >> "$debug"
###     echo Vim args: "${vim_args[@]}" >> "$debug"
###     #od -c <<<"${vim_args[@]}" >> "$debug"
###     echo "Vim returned $vimstatus" >> "$debug"
###     echo "Vim messages were: " >> "$debug"
###     cat "$script_output_fn" >> "$debug"
###     echo "Output was:" >> "$debug"
###     od -c "$fn" >> "$debug"
###
###     rm -f "$script_output_fn"
### fi

### rm -f "$fn"

### exit "$vimstatus"
