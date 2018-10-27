' Modified from
' https://stackoverflow.com/a/2470557/2877364 by
' https://stackoverflow.com/users/2441/aphoria

Set args = Wscript.Arguments

idx=1
For Each arg In args
    Wscript.Echo cstr(idx) & ": " & arg
    idx = idx+1
Next
