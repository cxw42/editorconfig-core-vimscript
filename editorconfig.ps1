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

. .\ecvimlib.ps1

### Main ===============================================================

if($debug) {
    echo "==================================" | D
    Get-Date -format F | D

    echo "Running in       $DIR"                | D
    echo "Vim executable:  $VIM"                | D
    echo "report version?  $report_version"     | D
    echo "set version to:  $set_version"        | D
    echo "config filename: $config_name"        | D
    echo "Filenames:       $files"              | D
    echo "Args:            $args"               | D
}

# NOTE: function Main is an experiment that didn't work.  I wanted to turn
# -version into --version.  However, splatting only fills positional parameters,
# not named switches.  I may be able to do it by splatting hashes or by checking
# the positional parameters.  See
# https://stackoverflow.com/q/38009106/2877364 by
# https://stackoverflow.com/users/3719459/paebbels and
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-6#splatting-command-parameters.

### The main function.  Put here so we can turn -version into --version.
##function Main
##{

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

$fn=[System.IO.Path]::GetTempFileName();    # Vim will write the settings into here.  ~stdout.
$script_output_fn = ''
if($debug) {
    $script_output_fn = [System.IO.Path]::GetTempFileName()
}

$cmd="call editorconfig_core#currbuf_cli({"

# Names
$cmd += "'output':" + (vesc($fn)) + ", "
    # filename to put the settings in
if($debug) {
    $cmd += " 'dump':" + (vesc($script_output_fn)) + ", "
    # where to put debug info
}

# Filenames to get the settings for
$cmd += "'target':["
ForEach ($item in $files) {
    $cmd += (vesc($item)) + ", "
}
$cmd += "],"
    # filename to get the settings for

# Job
$cmd += "}, {"
if($config_name) { $cmd += "'config':" + (vesc($config_name)) + ", " }
    # config name (e.g., .editorconfig)
if($set_version) { $cmd += "'version':" + (vesc($set_version)) + ", " }
    # version number we should behave as
$cmd += "})"

#$cmd =':q!'  # DEBUG
if($debug) { write-warning "Running Vim command ${cmd}" }
$vim_args = @(
    '-c', "set rtp+=$DIR",
    '-c', 'echom &rtp',     #DEBUG
    '-c', 'echo "yay"',     #DEBUG
    '-c', $cmd,
    '-c', 'quit!'   # TODO write a wrapper that will cquit on exception
)

# Run editorconfig.  Thanks for options to
# http://vim.wikia.com/wiki/Vim_as_a_system_interpreter_for_vimscript .
# Add -V1 to the below for debugging output.
# Do not output anything to stdout or stderr,
# since it messes up ctest's interpretation
# of the results.

$basic_args = '-nNes','-i','NONE','-u','NONE','-U','NONE'   #, '-V1'

#echo 'DEBUG message here yay' >> $script_output_fn   #DEBUG

if($debug) { write-warning "Running ${VIM}" }
$vimstatus = run_process $VIM -stdout $debug -stderr $debug `
    -argv ($basic_args+$vim_args)
if($debug) { write-warning "Done running" }

if($vimstatus -eq 0) {
    cat $fn
}

# Debug output cannot be included on stdout or stderr, because
# ctest's regex check looks both of those places.  Therefore, dump to a
# separate debugging file.

if($debug) {
    echo "Current directory:" | D
    (get-item -path '.').FullName | D
    echo "Script directory: $DIR" | D
###     echo Vim args: "${vim_args[@]}" >> "$debug"
###     #od -c <<<"${vim_args[@]}" >> "$debug"
    echo "Vim returned $vimstatus" | D
    echo "Vim messages were: " | D
    cat $script_output_fn | D
    echo "Output was:" | D

    # Modified from https://www.itprotoday.com/powershell/get-hex-dumps-files-powershell
    Get-Content $script_output_fn -Encoding Byte -ReadCount 16 | `
    ForEach-Object {
        $output = ""
        $chars = ''
        foreach ( $byte in $_ ) {
            $output += "{0:X2} " -f $byte
            if( ($byte -ge 32) -and ($byte -le 127) ) {
                $chars += [char]$byte
            } else {
                $chars += '.'
            }
        }
        $output + ' ' + $chars
    } | D

    del -Force $script_output_fn
}

del -Force $fn

exit $vimstatus

##} #Main()
##
##if($args.length -eq 0) {
##    Main
##
##} else {    # Convert --version to -version
##    $myargs = 1..($args.length)
##    for($argidx=0; $argidx -lt $args.length; ++$argidx) {
##        write-warning "Checking $($args[$argidx])"
##        if($args[$argidx] -eq '--version') {
##            write-warning "Updating"
##            $myargs[$argidx] = '-version'
##        } else {
##            $myargs[$argidx] = $args[$argidx]
##        }
##    }
##    write-warning "New args $myargs"
##    Main $myargs
##}

# vi: set ts=4 sts=4 sw=4 et ai:
