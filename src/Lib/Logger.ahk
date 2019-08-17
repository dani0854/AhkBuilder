global log_lvl
global InstallDir
RegRead, InstallDir, HKEY_LOCAL_MACHINE\SOFTWARE\DoshikSoft\ASM, InstallDir
InstallDir := "C:\repo\ASM"
IniRead, log_lvl, %InstallDir%\config.ini, Main, log_lvl
add_log(min_log_lvl, msg) {
	if (min_log_lvl <= log_lvl)  {
		FileAppend, [%A_Hour%:%A_Min%:%A_Sec%:%A_MSec%] <%A_ScriptName%> %msg%`n, %InstallDir%\log.txt, CP1200
	}
}