#Include <ScriptParser>
#Include <IconChanger>
#Include <Directives>
#Include <VersionRes>
#Include <UtilLib>

AhkCompile(ByRef AhkFile, ExeFile := "", ByRef CustomIcon := "", BinFile := "", UseMPRESS := "", UseCompression := "", ResourceFile = "", UsePassword := "AutoHotkey", fileCP="")
{
	global ExeFileTmp
	if (AhkFile = "") {
		Util_Error("Error: Source file not specified.")
	}
	SplitPath,AhkFile,, AhkFile_Dir,, AhkFile_NameNoExt
	
	if (ExeFile = "") {
		ExeFile := AhkFile_Dir "\" AhkFile_NameNoExt ".exe"
	}
	else {
		ExeFile := Util_GetFullPath(ExeFile)
	}
	
	ExeFileTmp := ExeFile
	
	try {
		FileCopy, %BinFile%, %ExeFile%, 1
		if ErrorLevel {
			Throw ErrorLevel
		}
	} catch e {
		Util_Error("Error: Unable to copy AutoHotkeySC binary file to destination.",, e)
	}
	
	if ResourceFile 
	{
		resourceCompiled := Util_TempFile(,".res")
		try
		{
			RunWait, "%resourceHackerDir%" -open "%ResourceFile%" -save "%resourceCompiled%" -action compile,, Hide
			
		}
		catch e
		{
			Util_Error("Error: Couldn't compile resource file - " . ResourceFile,, e)
		}
		try 
		{
			RunWait, "%resourceHackerDir%" -open "%ExeFileTmp%" -save "%ExeFileTmp%" -action addoverwrite -resource "%resourceCompiled%",, Hide
		}
		catch e
		{
			Util_Error("Error: Couldn't add resource file - " . ResourceFile,, e)
		}
		try 
		{
			FileDelete, %resourceCompiled%
		}
		catch e
		{
			Util_Error("Error: Couldn't delete temp file - " . resourceCompiled, 0, e)
		}
	}
	
	BundleAhkScript(ExeFile, AhkFile, CustomIcon, UseCompression, UsePassword)
	
	if UseMPRESS 
	{
		Util_Status("Compressing final executable...")
		try 
		{
			RunWait, "%MPRESS%" -q -x "%ExeFileTmp%",, Hide
		} 
		catch e
		{
			Util_Error("Error: Couldn't compress - " . ExeFile,, e)
		}
	}
	
}

BundleAhkScript(ExeFile, AhkFile, IcoFile := "", UseCompression := 0, UsePassword := "", fileCP="")
{
	if fileCP {
		fileCP := A_FileEncoding
	}
	
	try {
		FileEncoding, %fileCP%
	} catch e {
		Util_Error("Error: Invalid codepage parameter """ fileCP """ was given.",, e)
	}
	
	SplitPath,AhkFile,, ScriptDir
	ExtraFiles := []
	,Directives := PreprocessScript(ScriptBody, AhkFile, ExtraFiles)
	,ScriptBody := Trim(ScriptBody,"`n")
	,VarSetCapacity(BinScriptBody, BinScriptBody_Len:=StrPut(ScriptBody, "UTF-8"))
	,StrPut(ScriptBody, &BinScriptBody, "UTF-8")
	
	Util_Status("")
	If UseCompression {
		VarSetCapacity(buf,bufsz:=65536,00),totalsz:=0,VarSetCapacity(buf1,65536)
		Loop, Parse,ScriptBody,`n,`r
		{
			len:=StrPutVar(A_LoopField,data,"UTF-8")
			,sz:=ZipRawMemory(&data, len, zip, UsePassword)
			,DllCall("crypt32\CryptBinaryToStringA","PTR", &zip,"UInt", sz,"UInt", 0x1|0x40000000,"UInt", 0,"UIntP", cryptedsz)
			,tosavesz:=cryptedsz
			,DllCall("crypt32\CryptBinaryToStringA","PTR", &zip,"UInt", sz,"UInt", 0x1|0x40000000,"PTR", &buf1,"UIntP", cryptedsz)
			,NumPut(10,&buf1,cryptedsz)
			if (totalsz+tosavesz>bufsz)
				VarSetCapacity(buf,bufsz*=2)
			RtlMoveMemory((&buf) + totalsz,&buf1,tosavesz)
			,totalsz+=tosavesz
		}
		NumPut(0,&buf,totalsz-1,"UShort")
		If !BinScriptBody_Len := ZipRawMemory(&buf,totalsz,BinScriptBody,UsePassword)
			Util_Error("Error: Could not compress the source file.")
	}
	
	module := BeginUpdateResource(ExeFile)
	if (!module) {
		Util_Error("Error: Error opening the destination file.")
	}
	
	tempWD := new CTempWD(ScriptDir)
	dirState := ProcessDirectives(ExeFile, module, Directives, IcoFile, UseCompression, UsePassword)
	IcoFile := dirState.IcoFile
	
	if outPreproc := dirState.OutPreproc
	{
		f := FileOpen(outPreproc, "w", "UTF-8-RAW")
		f.RawWrite(BinScriptBody, BinScriptBody_Len)
		f := ""
	}
	
	Util_Status("Adding: Master Script")
	if !DllCall("UpdateResource", "ptr", module, "ptr", 10, "str", "E4847ED08866458F8DD35F94B37001C0", "ushort", 0x409, "ptr", &BinScriptBody, "uint", BinScriptBody_Len, "uint") {
		goto _FailEnd
	}
		
	for each,file in ExtraFiles
	{
		Util_Status("Adding: " file)
		StringUpper, resname, file
		
		If !FileExist(file)
			goto _FailEnd2
		If UseCompression{
			FileRead, tempdata, *c %file%
			FileGetSize, tempsize, %file%
			If !filesize := ZipRawMemory(&tempdata, tempsize, filedata)
				Util_Error("Error: Could not compress the file to: " file)
		} else {
			FileRead, filedata, *c %file%
			FileGetSize, filesize, %file%
		}
		
		if !DllCall("UpdateResource", "ptr", module, "ptr", 10, "str", resname, "ushort", 0x409, "ptr", &filedata, "uint", filesize, "uint") {
			goto _FailEnd2
		}
	}
	VarSetCapacity(filedata, 0)
	
	gosub _EndUpdateResource
	
	if dirState.ConsoleApp
	{
		Util_Status("Marking executable as a console application...")
		if !SetExeSubsystem(ExeFile, 3)
			Util_Error("Could not change executable subsystem!")
	}
	
	for each,cmd in dirState.PostExec
	{
		Util_Status("PostExec: " cmd)
		RunWait, % cmd,, UseErrorLevel
		if (ErrorLevel != 0)
			Util_Error("Command failed with RC=" ErrorLevel ":`n" cmd)
	}
	
	
	return
	
_FailEnd:
	gosub _EndUpdateResource
	Util_Error("Error adding script file:`n`n" AhkFile)
	
_FailEnd2:
	gosub _EndUpdateResource
	Util_Error("Error adding FileInstall file:`n`n" file)
	
_EndUpdateResource:
	if !EndUpdateResource(module)
		Util_Error("Error: Error opening the destination file.")
	return
}

class CTempWD
{
	__New(newWD)
	{
		this.oldWD := A_WorkingDir
		SetWorkingDir % newWD
	}
	__Delete()
	{
		SetWorkingDir % this.oldWD
	}
}