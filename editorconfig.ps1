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

$VIM = "C:\Program Files (x86)\Vim\vim74\vim.exe"   # TODO don't hardcode

# Run a process with the given arguments.  TODO accept arguments.
function run_process()
{
    param(
        [Parameter(Mandatory=$true, Position=0)][string]$run,
        [string[]]$argv,
        [string]$extrapath,
        [string]$stdout,        # Redirect stdout to this file
        [string]$stderr         # Redirect stderr to this file
    )

    $si = new-object Diagnostics.ProcessStartInfo
    if($extrapath) {
        $si.EnvironmentVariables['path']+=";${extrapath}"
    }
    $si.FileName=$run
    $si.Arguments=$argv;
    $si.UseShellExecute=$false
    # DEBUG  $si.RedirectStandardInput=$true
    $si.RedirectStandardOutput=!!$stdout;
    $si.RedirectStandardError=!!$stderr;

    $p = [Diagnostics.Process]::Start($si)
    # DEBUG $p.StandardInput.Close()        # < /dev/null

    $p.WaitForExit()
    $retval = $p.ExitCode

    if($stdout) {
        $p.StandardOutput.ReadToEnd() | `
            Out-File -FilePath $stdout -Encoding utf8 -Append
    }

    if($stderr) {
        $p.StandardError.ReadToEnd() | `
            Out-File -FilePath $stderr -Encoding utf8 -Append
    }

    $p.Close()

    return $retval
}

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

# Escape a string for Vim
function vesc($str) {
    return "'" + ($str -replace "'","''") + "'"
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

$cmd =':q!'  # DEBUG
echo $cmd
$vim_args = @(
    '-c', "set runtimepath += $DIR",
    #'-c', 'echom &rtp',    # doesn't show up in the output
    #'-c', 'echo "yay"',    # ditto
    '-c', $cmd
)

# Run editorconfig.  Thanks for options to
# http://vim.wikia.com/wiki/Vim_as_a_system_interpreter_for_vimscript .
# Add -V1 to the below for debugging output.
# Do not output anything to stdout or stderr,
# since it messes up ctest's interpretation
# of the results.

$basic_args='-nNes','-i','NONE','-u','NONE','-U','NONE'

echo "Running ${VIM}"
$vimstatus = run_process $VIM -argv ($basic_args+$vim_args) `
    -stdout $debug -stderr $debug
echo "Done running"

if($vimstatus -eq 0) {
    cat $debug
}

# Debug output cannot be included on stdout or stderr, because
# ctest's regex check looks both of those places.  Therefore, dump to a
# separate debugging file.

if($debug) {
    echo "Current directory" | D
    (get-item -path '.').FullName | D
    echo "Script directory: $DIR" | D
###     echo Vim args: "${vim_args[@]}" >> "$debug"
###     #od -c <<<"${vim_args[@]}" >> "$debug"
    echo "Vim returned $vimstatus" | D
    echo "Vim messages were: " | D
    cat $script_output_fn | D
    echo "Output was:" | D

    # Thanks to https://www.itprotoday.com/powershell/get-hex-dumps-files-powershell
    Get-Content "C:\Windows\notepad.exe" -Encoding Byte ` -ReadCount 16 | ForEach-Object {
        $output = ""
        foreach ( $byte in $_ ) {
            $output += "{0:X2} " -f $byte
        }
    } | D

    del -Force $script_output_fn
}

del -Force $fn

### exit "$vimstatus"
# vi: set ts=4 sts=4 sw=4 et ai:
