Util_Status(txt)
{
	if (txt != "") {
		FileAppend, <%A_Hour%:%A_Min%:%A_Sec%:%A_MSec%> [STATUS] %txt%`n, *
	}
}

Util_Error(txt, doexit=1, extra="")
{
	global Error_ForceExit, ExeFileTmp
	
	if ExeFileTmp && FileExist(ExeFileTmp)
	{
		FileDelete, %ExeFileTmp%
		ExeFileTmp =
	}
	
	if extra
		txt .= "`n`tSpecifically: " extra
	
	FileAppend, <%A_Hour%:%A_Min%:%A_Sec%:%A_MSec%> [ERROR] %txt%`n, *
	
	if doexit
		if !Error_ForceExit
			Exit, % Util_ErrorCode(txt)
		else
			ExitApp, % Util_ErrorCode(txt)
}

Util_ErrorCode(x)
{
	if InStr(x,"Syntax")
		if InStr(x,"FileInstall")
			return 0x12
		else
			return 0x11

	if InStr(x,"AutoHotkeySC")
		if InStr(x,"copy")
			return 0x41
		else
			return 0x34

	if InStr(x,"file")	
		if InStr(x,"open")
			if InStr(x,"cannot")
				return 0x32
			else
				return 0x31
		else if InStr(x,"adding")
			if InStr(x,"FileInstall")
				return 0x44
			else
				return 0x43
		else if InStr(x,"cannot")
			if InStr(x,"drop")
				return 0x51
			else
				return 0x52
		else if InStr(x,"final")
			return 0x45
		else
			return 0x33


	if InStr(x,"Supported")
		if InStr(x,"De")
			if InStr(x,"#")
				if InStr(x,"ref")
					return 0x21
				else
					return 0x22
			else
				return 0x23
		else
			return 0x24

	if InStr(x,"build used")
		if InStr(x,"Legacy")
			return 0x26
		else
			return 0x25

	if InStr(x,"icon")
		return 0x42
	
	if InStr(x,"codepage")
		return 0x53
	
	return 0x1 ;unknown error
}

Util_Info(txt)
{
	FileAppend, <%A_Hour%:%A_Min%:%A_Sec%:%A_MSec%> [INFO] %txt%`n, *
}

Util_TempFile(d:="", ext := ".tmp")
{
	if ( !StrLen(d) || !FileExist(d) )
		d:=A_Temp
	Loop
		tempName := d "\~temp" A_TickCount . ext
	until !FileExist(tempName)
	return tempName
}

Util_GetFullPath(path)
{
	VarSetCapacity(fullpath, 260 * (!!A_IsUnicode + 1))
	if DllCall("GetFullPathName", "str", path, "uint", 260, "str", fullpath, "ptr", 0, "uint")
		return fullpath
	else
		return ""
}
