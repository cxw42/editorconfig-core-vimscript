# pstest.ps1

#Requires -Version 3

$MyInvocation
echo ("Line: " + $MyInvocation.Line)

$a = $MyInvocation.UnboundArguments
echo ("Unbound: " + $a)

for($idx = 0; $idx -lt $a.count; ++$idx) {
    echo "${idx}: >>$($a[$idx])<<"
}
