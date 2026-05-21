' function used by build.bat for copying bytes from the source Contra US NES rom
' file to the various binary files for use when assembling.

Set fso=CreateObject("Scripting.FileSystemObject")

' check if output exists and is the same size
If fso.FileExists(WScript.Arguments(2)) Then
    Set outFile = fso.GetFile(WScript.Arguments(2))
    If outFile.Size = CLng(WScript.Arguments(1)) Then
        WScript.Quit
    End If
End If

Wscript.Echo "    Writing file " + WScript.Arguments(2) + "."

' read bytes from source Contra US NES rom
Set inFile=fso.OpenTextFile("baserom.nes")
inFile.Skip(WScript.Arguments(0))
buf=inFile.Read(WScript.Arguments(1))
inFile.Close

Set outFile = fso.CreateTextFile(WScript.Arguments(2))
outFile.Write buf
outFile.Close