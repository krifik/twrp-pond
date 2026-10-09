Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & WshShell.CurrentDirectory & "\start_background.ps1""", 0, False
Set WshShell = Nothing
