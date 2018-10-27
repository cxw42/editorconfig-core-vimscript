@echo off
set here=%~dp0
set a1="%1:`=``%"
set a1="%a1:,=`,%"
set a2="%2:`=``%"
set a2="%a2:,=`,%"
set a3="%3:`=``%"
set a3="%a3:,=`,%"
set a4="%4:`=``%"
set a4="%a4:,=`,%"
set a5="%5:`=``%"
set a5="%a5:,=`,%"
set a6="%6:`=``%"
set a6="%a6:,=`,%"
set a7="%7:`=``%"
set a7="%a7:,=`,%"
set a8="%8:`=``%"
set a8="%a8:,=`,%"
set a9="%9:`=``%"
set a9="%a9:,=`,%"

echo 0=%0=
echo 1=%1=
echo 2=%2=
echo 3=%3=
echo 4=%4=
echo 5=%5=
echo 6=%6=
echo 7=%7=
echo 8=%8=
echo 9=%9=
echo "*"=%*
:: %* has the whole command line

for /F "tokens=*" %%a in ("token1 token2 -token3,3 token4") do echo %%a
for /F "tokens=*" %%a in ("%*") do echo "{%%a}"

powershell -executionpolicy bypass -file "%here%\editorconfig.ps1" "%1" "%2" "%3" "%4" "%5" "%6" "%7" "%8" "%9"
