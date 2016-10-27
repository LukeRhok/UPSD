@ECHO OFF
set cmd= 
:Loop
IF "%~1"=="" GOTO Continue

set cmd=%cmd% '%1' 

SHIFT
GOTO Loop
:Continue

rem echo %cmd%
powershell.exe -command "&'%~dp0ps2exe.ps1' '%~dp0..\AddRemoveSoftware.ps1' '%~dp0..\AddRemoveSoftware.exe' -noconsole -verbose"