@echo off
:: ecunit.bat: first-level invoker for editorconfig-core-vimscript unit tests
:: Copyright (c) 2018 Chris White.  CC-BY-SA 3.0+.
set here=%~dp0
cscript //Nologo "%here%ecunit1.vbs" %*
