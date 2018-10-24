@echo off
set here=%~dp0
powershell -executionpolicy bypass -file "%here%\editorconfig.ps1" %1 %2 %3 %4 %5 %6 %7 %8 %9
