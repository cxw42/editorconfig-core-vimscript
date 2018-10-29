#Requires -Version 3

echo "PID =  $PID"
echo "Args = $args"

# Both of these work
Get-CimInstance Win32_Process -Filter "processid = '$PID'" | select CommandLine | Format-List
Get-WmiObject Win32_Process -Filter "processid = '$PID'" | Select-Object CommandLine | Format-List

# This does what I want
$cmdline = (Get-CimInstance Win32_Process -Filter "processid = '$PID'" |
	select CommandLine).CommandLine

echo ">>$cmdline<<"

# Strip off the EXE path to get just the args
$exe_path = (Get-WmiObject Win32_Process -Filter "processid = '$PID'").ExecutablePath

$re_exe = [Regex]::Escape($exe_path)
    # Thanks to https://stackoverflow.com/a/23651909/2877364 by
    # https://stackoverflow.com/users/73070/joey for the tip
$justargs = $cmdline -replace "^(""$re_exe""|$re_exe)\s*",''
echo ">>$justargs<<"

