AhkCompile(ByRef AhkFile, ExeFile="", ByRef CustomIcon="", BinFile := 0, UseMPRESS := 0, ResourceFile := 0, fileCP="")
{
	global ExeFileTmp
	AhkFile := Util_GetFullPath(AhkFile)
	if AhkFile =
		Util_Error("Error: Source file not specified.")
	SplitPath, AhkFile,, AhkFile_Dir,, AhkFile_NameNoExt
	
	if ExeFile =
		ExeFile = %AhkFile_Dir%\%AhkFile_NameNoExt%.exe
	else
		ExeFile := Util_GetFullPath(ExeFile)
	
	;ExeFileTmp := ExeFile
	ExeFileTmp := Util_TempFile()
	
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
	
	try FileCopy, %BinFile%, %ExeFileTmp%, 1
	catch
		Util_Error("Error: Unable to copy AutoHotkeySC binary file to destination.")
	
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
		resourceCompiled := Util_TempFile(,".res")
		try
		{
			RunWait, "%resourceHackerDir%" -open "%ResourceFile%" -save "%resourceCompiled%" -action compile,, Hide
		}
		catch 
		{
			Util_Error("Error: Couldn't compile resource file - " . ResourceFile)
		}
		try 
		{
			RunWait, "%resourceHackerDir%" -open "%ExeFileTmp%" -save "%ExeFileTmp%" -action addoverwrite -resource "%resourceCompiled%",, Hide
		}
		catch 
		{
			Util_Error("Error: Couldn't add resource file - " . ResourceFile)
		}
		FileDelete, %resourceCompiled%
	}
	
	BinType := AHKType(ExeFileTmp)
	DerefIncludeVars.A_AhkVersion := BinType.Version
	DerefIncludeVars.A_PtrSize := BinType.PtrSize
	DerefIncludeVars.A_IsUnicode := BinType.IsUnicode
	
	BundleAhkScript(ExeFileTmp, AhkFile, CustomIcon, fileCP)
	
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
		Util_Status("Compressing final executable...")
		try 
		{
			RunWait, "%MPRESS%" -q -x "%ExeFileTmp%",, Hide
		} 
		catch 
		{
			Util_Error("Error: Couldn't compress - " . ExeFile)
		}
	}
	
	; the final step...
	try FileCopy, %ExeFileTmp%, %ExeFile%, 1
	catch
		Util_Error("Error: Could not copy final compiled binary file to destination.")

	Util_Status("")
}

BundleAhkScript(ExeFile, AhkFile, IcoFile="", fileCP="")
{
	; weird bug prevention, for non working default param 'fileCP'
	if fileCP is space
		fileCP := A_FileEncoding
	
	try FileEncoding, %fileCP%
	catch e
		Util_Error("Error: Invalid codepage parameter """ fileCP """ was given.")
	
	SplitPath, AhkFile,, ScriptDir
	
	ExtraFiles := []
	PreprocessScript(ScriptBody, AhkFile, ExtraFiles)
	;FileDelete, %ExeFile%.ahk
	;FileAppend, % ScriptBody, %ExeFile%.ahk
	VarSetCapacity(BinScriptBody, BinScriptBody_Len := StrPut(ScriptBody, "UTF-8") - 1)
	StrPut(ScriptBody, &BinScriptBody, "UTF-8")

	module := DllCall("BeginUpdateResource", "str", ExeFile, "uint", 0, "ptr")
	if !module
		Util_Error("Error: Error opening the destination file.")
	
	if IcoFile
	{
		Util_Status("Changing the main icon...")
		if !ReplaceAhkIcon(module, IcoFile, ExeFile)
		{
			; Error was already displayed
			gosub _EndUpdateResource
			Util_Error("Error changing icon: Unable to read icon or icon was of the wrong format.")
		}
	}
	
	Util_Status("Compressing and adding: Master Script")
	if !DllCall("UpdateResource", "ptr", module, "ptr", 10, "str", IcoFile ? ">AHK WITH ICON<" : ">AUTOHOTKEY SCRIPT<"
	          , "ushort", 0x409, "ptr", &BinScriptBody, "uint", BinScriptBody_Len, "uint")
		goto _FailEnd
	
	oldWD := A_WorkingDir
	SetWorkingDir, %ScriptDir%
	for each,file in ExtraFiles
	{
		Util_Status("Compressing and adding: " file)
		StringUpper, resname, file
		
		IfNotExist, %file%
			goto _FailEnd2
		
		; This "old-school" method of reading binary files is way faster than using file objects.
		FileGetSize, filesize, %file%
		VarSetCapacity(filedata, filesize)
		FileRead, filedata, *c %file%
		if !DllCall("UpdateResource", "ptr", module, "ptr", 10, "str", resname
				  , "ushort", 0x409, "ptr", &filedata, "uint", filesize, "uint")
			goto _FailEnd2
		VarSetCapacity(filedata, 0)
	}
	SetWorkingDir, %oldWD%
	
	gosub _EndUpdateResource
	return
	
_FailEnd:
	gosub _EndUpdateResource
	Util_Error("Error adding script file:`n`n" AhkFile)
	
_FailEnd2:
	gosub _EndUpdateResource
	Util_Error("Error adding FileInstall file:`n`n" file)
	
_EndUpdateResource:
	if !DllCall("EndUpdateResource", "ptr", module, "uint", 0)
		Util_Error("Error: Error opening the destination file.")
	return
}