# ecunit2.ps1: Editorconfig Vimscript unit-test runner
# Part of editorconfig-core-vimscript.
# Copyright (c) 2018 Chris White.  CC-BY-SA 3.0.
# Thanks to https://cecs.wright.edu/~pmateti/Courses/233/Labs/Scripting/bashVsPowerShellTable.html
# by Gallagher and Mateti.

#Requires -Version 3

. "$PSScriptRoot\ecvimlib.ps1"

### Argument processing ================================================

$argv = @(de64_args($args))

# Defaults
$globpat = ''
$files=@()
$extra_info = ''

# Hand-parse - pretend we're sort of like getopt.
$idx = 0
while($idx -lt $argv.count) {
    $a = $argv[$idx]
    if($debug) {
        echo "$idx - $a" | D
    }

    switch -CaseSensitive -Regex ($a) {
        '^-g$' {
            if($idx -eq ($argv.count-1)) {
                throw '-g <glob pattern>: no pattern provided'
            } else {
                ++$idx
                $globpat = $argv[$idx]
            }
        } #-g

        '^-x$' {
            if($idx -eq ($argv.count-1)) {
                throw '-x <extra info>: no info provided'
            } else {
                ++$idx
                $extra_info = $argv[$idx]
            }
        } #-g
        '^--$' {    # End of options, so capture the rest as filenames
            ++$idx;
            while($idx -lt $argv.count) {
                $files += $argv[$idx]
                ++$idx
            }
        }

        default { $files += $a }
    }

    ++$idx
} # end foreach argument

### Main ===============================================================

if($debug) {
    if($extra_info -ne '') {
        echo "--- $extra_info --- "             | D
    }
    echo "Running in       $DIR"                | D
    echo "Vim executable:  $VIM"                | D
    echo "glob pattern:    $globpat"            | D
    echo "Filenames:       $files"              | D
    echo "Args:            $args"               | D
    echo "Decoded args:    $argv"               | D
}

if($files.count -lt 2) {
    exit
}

if($files[0] -eq '-') {
    throw "Reading filenames from stdin not yet supported"
}

$fn=[System.IO.Path]::GetTempFileName();    # Vim will write the settings into here.  ~stdout.

#$script_output_fn = ''
#if($debug) {
#    $script_output_fn = [System.IO.Path]::GetTempFileName()
#}

if(!$globpat) {
    throw "At the moment, I can only do -g"
}

# Permit throwing in setup commands
$cmd = ''
if($env:ECUNIT_EXTRA) {
    $cmd += $env:ECUNIT_EXTRA + ' | '
}

#$cmd += "let g:editorconfig_core_vimscript_debug=1 | "
$cmd += 'if editorconfig_core#fnmatch#fnmatch('
$cmd += (vesc($files[0] + '/' + $files[1]))
$cmd += ', ' + (vesc($files[0] + '/'))
$cmd += ', ' + (vesc($globpat))
$cmd += ') | quit! | else | cquit! | endif'

if($debug) { echo "Running Vim command ${cmd}" | D }
$vim_args = @(
    '-c', "set rtp+=$DIR",
    '-c', $cmd
)

# Run editorconfig.  Thanks for options to
# http://vim.wikia.com/wiki/Vim_as_a_system_interpreter_for_vimscript .
# Add -V1 to the below for debugging output.
# Do not output anything to stdout or stderr,
# since it messes up ctest's interpretation
# of the results if regex tests are used.

$basic_args = '-nNes','-i','NONE','-u','NONE','-U','NONE'   # , '-V1'

#echo 'DEBUG message here yay' >> $script_output_fn   #DEBUG

if($debug) { echo "Running vim ${VIM}" | D }
$vimstatus = run_process $VIM -stdout $debug -stderr $debug `
    -argv ($basic_args+$vim_args)
if($debug) { echo "Done running vim" | D }

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
###    echo "Vim messages were: " | D
###    cat $script_output_fn | D
###    echo "Output was:" | D
###
###    # Modified from https://www.itprotoday.com/powershell/get-hex-dumps-files-powershell
###    Get-Content $script_output_fn -Encoding Byte -ReadCount 16 | `
###    ForEach-Object {
###        $output = ""
###        $chars = ''
###        foreach ( $byte in $_ ) {
###            $output += "{0:X2} " -f $byte
###            if( ($byte -ge 32) -and ($byte -le 127) ) {
###                $chars += [char]$byte
###            } else {
###                $chars += '.'
###            }
###        }
###        $output + ' ' + $chars
###    } | D
###
###    del -Force $script_output_fn

} #endif $debug

del -Force $fn

exit $vimstatus

# vi: set ts=4 sts=4 sw=4 et ai:
