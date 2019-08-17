#NoEnv
#Include <UtilLib>

DEBUG := 1

if !A_Args.Length() {
	MsgBox, Only CLI mode available.
	ExitApp
}

if (!A_Args.Length() > 1) {
	Util_Error("To many parameters")
}
if (A_Args[1] != "build")
{
	Util_Error("Only build parameter supported")
}
if !FileExist(A_ScriptDir . "\config.ini")
{
	Util_Info("Couldn't find config.`nCreating config.")
	try 
	{
		FileInstall, config.ini, %A_ScriptDir%\config.ini
	} 
	catch
	{
		Util_Error("Couldn't create config.")
	}
}

if !FileExist(A_WorkingDir . "\build.ahkb")
{
	Util_Error("Couldn't find build.ahkb")
}
template := Util_TempFile(, ".ahk")
FileInstall, template.ahk, %template%
RunWait, %template% "%A_ScriptDir%\ahk_compile.exe"
FileDelete, %template%