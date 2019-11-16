#Include %A_ScriptDir%
#Include Compiler.ahk
global MPRESS
global resourceHackerDir

if !A_Args.Length() {
	MsgBox, Only CLI mode available.
	ExitApp
}

if Mod(A_Args.Length(), 2)  {
	badArgs()
}

Loop % A_Args.Length() / 2
{
	param := A_Args[2 * A_Index - 1]
	val := A_Args[2 * A_Index]
	if (param = "-in") 
	{
		AhkFile := getParamFullDir(val)
	} 
	else if (param = "-out")
	{
		ExeFile := getParamFullDir(val)
	}
	else if (param = "-icon")
	{
		CustomIcon := getParamFullDir(val)
	}
	else if (param = "-bin")
	{
		BinFile := getParamFullDir(val)
	}
	else if (param = "-mpress")
	{
		if (val != 0 and val != 1) {
			badArgs()
		}
		UseMPRESS := val
	}
	else if (param = "-comp")
	{
		if (val != 0 and val != 1) {
			badArgs()
		}
		UseCompression := val
	}
	else if (param = "-resource")
	{
		ResourceFile := getParamFullDir(val)
	}
	else if (param = "-pass")
	{
		UsePassword := val
	}
	else if (param = "-cp")
	{
		fileCP := val
	}
	else 
	{
		badArgs()
	}
}

if !BinFile
{
	IniRead, BinFile, %A_ScriptDir%\config.ini, SRC, binDir
	if (!FileExist(BinFile) and BinFile != "ERROR") 
	{
		Util_Error("Error: The selected AutoHotkeySC binary does not exist.", 1, BinFile)
	} 
	else if (BinFile = "ERROR" and FileExist(A_ScriptDir . "\bin\AutoHotkeySC.bin")) 
	{
		BinFile := A_ScriptDir . "\bin\AutoHotkeySC.bin"
	} 
	else if (BinFile = "ERROR" and FileExist(RegExReplace(A_AhkPath,"[^\\]+\\?$") . "Compiler\AutoHotkeySC.bin")) 
	{
		BinFile := RegExReplace(A_AhkPath,"[^\\]+\\?$") . "Compiler\AutoHotkeySC.bin"
	} 
	else 
	{
		Util_Error("Error: Couldn't find AutoHotkeySC binary.")
	}	
}

if ResourceFile 
{
	if !FileExist(ResourceFile)
	{
		Util_Error("Error: The selected resource file does not exist.", 1, ResourceFile)
	}
	IniRead, resourceHackerDir, %A_ScriptDir%\config.ini, SRC, resourceHackerDir
	if (!FileExist(resourceHackerDir) and resourceHackerDir != "ERROR") 
	{
		Util_Error("Error: The selected Resource Hacker executable does not exist.", 1, resourceHackerDir)
	}
	else if (resourceHackerDir = "ERROR")
	{
		resourceHackerDir := "ResourceHacker"
	}
}


if UseMPRESS 
{
	IniRead, MPRESS, %A_ScriptDir%\config.ini, SRC, MPRESSDir
	if (!FileExist(MPRESS) and MPRESS != "ERROR") 
	{
		Util_Error("Error: The selected MPRESS executable does not exist.", 1, MPRESS)
	} 
	else if (MPRESS = "ERROR" and FileExist(A_ScriptDir . "\mpress.exe")) 
	{
		MPRESS := A_ScriptDir . "\mpress.exe"
	} 
	else if (MPRESS = "ERROR" and FileExist(RegExReplace(A_AhkPath,"[^\\]+\\?$") . "Compiler\mpress.exe")) 
	{
		MPRESS := RegExReplace(A_AhkPath,"[^\\]+\\?$") . "Compiler\mpress.exe"
	} 
	else
	{
		Util_Error("Error: Couldn't find MPRESS executable.")
	}
}

AhkCompile(AhkFile, ExeFile, CustomIcon, BinFile, UseMPRESS, UseCompression, ResourceFile, UsePassword, fileCP)

getParamFullDir(dir) {
	if A_WorkingDir {
		dir := A_WorkingDir . "\" . StrReplace(dir, "/", "\")
	}
	return dir
}

badArgs() {
	Util_Error("Bad args")
}