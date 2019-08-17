#NoEnv
#Include <Compiler>
#Include <ScriptParser>
#Include <IconChanger>
#Include <AHKType>
#Include <GetExeMachine>
#Include <UtilLib>

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
		AhkFile := val
	} 
	else if (param = "-out")
	{
		ExeFile := val
	}
	else if (param = "-icon")
	{
		CustomIcon := val
	}
	else if (param = "-bin")
	{
		BinFile := val
	}
	else if (param = "-mpress")
	{
		if (val != 0 and val != 1) {
			badArgs()
		}
		UseMPRESS := val
	}
	else if (param = "-resource")
	{
		ResourceFile := val
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

AhkCompile(AhkFile, ExeFile, CustomIcon, BinFile, UseMPRESS, ResourceFile, fileCP)


badArgs() {
	Util_Error("Bad args")
}