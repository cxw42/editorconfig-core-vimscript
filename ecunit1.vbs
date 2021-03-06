' ecunit1.vbs: run by ecunit.bat; runs ecunit2.ps1.
' Part of editorconfig-core-vimscript.
' Copyright (c) 2018 Chris White.  CC-BY-SA 3.0+.
' Modified from
' https://stackoverflow.com/a/2470557/2877364 by
' https://stackoverflow.com/users/2441/aphoria

' Thanks to https://www.geekshangout.com/vbs-script-to-get-the-location-of-the-current-script/
currentScriptPath = Replace(WScript.ScriptFullName, WScript.ScriptName, "")

' Load our common library.  Thanks to https://stackoverflow.com/a/316169/2877364
With CreateObject("Scripting.FileSystemObject")
   executeGlobal .openTextFile(currentScriptPath & "ecvbslib.vbs").readAll()
End With

' === MAIN ==================================================================

' Encode the arguments to avoid quoting issues
b64args = MakeY64Args(Wscript.Arguments)

ps1name = QuoteForShell(currentScriptPath & "ecunit2.ps1")
'Wscript.Echo "Script is in " & ps1name

if True then
    retval = RunCommandAndEcho( "powershell.exe" & _
        " -executionpolicy bypass -file " & ps1name & " " & join(b64args) _
    )
        ' add -noexit to leave window open so you can see error messages

    WScript.Quit retval
end if

' vi: set ts=4 sts=4 sw=4 et ai:
