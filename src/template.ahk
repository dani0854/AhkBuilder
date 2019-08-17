if !A_Args.Length() {
	ExitApp
}
ahk_compile_path := A_Args[1]

#Include %A_WorkingDir%\build.ahkb

FileAppend, Done, *

AhkCompile(AhkFile, ExeFile := "", CustomIcon := "", BinFile := "", UseMPRESS := "", ResourceFile := "", fileCP := "") 
{
	global ahk_compile_path
	if !AhkFile
	{
		FileAppend, Error: No AhkFile specified, *
		ExitApp
	}
	AhkFile := " -in """ . AhkFile . """"
	if ExeFile 
	{
		ExeFile := " -out """ . ExeFile . """"
	}
	if CustomIcon 
	{
		CustomIcon := " -icon """ . CustomIcon . """"
	}
	if BinFile 
	{
		BinFile := " -bin """ . BinFile . """"
	}
	if UseMPRESS 
	{
		UseMPRESS := " -mpress """ . UseMPRESS . """"
	}
	if ResourceFile 
	{
		ResourceFile := " -resource """ . ResourceFile . """"
	}
	if fileCP 
	{
		fileCP := " -cp """ . fileCP . """"
	}
	RunWait, "%ahk_compile_path%"%AhkFile%%ExeFile%%CustomIcon%%BinFile%%UseMPRESS%%ResourceFile%%fileCP% ,,Hide
}