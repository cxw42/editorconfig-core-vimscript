@echo off
:: editorconfig.bat
set here=%~dp0

:: echo 0=%0=
:: echo 1=%1=
:: echo 2=%2=
:: echo 3=%3=
:: echo 4=%4=
:: echo 5=%5=
:: echo 6=%6=
:: echo 7=%7=
:: echo 8=%8=
:: echo 9=%9=
:: echo "*=%*="
:: :: %* has the whole command line
::
:: set star=%*
:: set quoted=%star:"=`"%
:: echo "+=%quoted%=+"

cscript //Nologo "%here%editorconfig1.vbs" %*
:: echo Passed to a subprocess:
:: call "%here%echoargs.bat" %quoted%
::
:: echo Powershell:
:: powershell -executionpolicy bypass -file "%here%pstest.ps1" "%quoted%"
