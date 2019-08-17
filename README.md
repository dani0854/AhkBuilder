# AHKBuilder v0.1.0
Autohotkey project builder

It's a very raw version of AHK Builder. Still in development. So may contain a lot of bugs and lack of functionality.

To compile it uses `ahk_compile` a modified version of [Ahk2Exe](https://github.com/AutoHotkey/Ahk2Exe)

## TODO 
* Add proper error handling

# Install
* Download everything from /build directory to some folder on PC.
* Add to Path system variable downloaded /build directory
* Done

# Requirements
* [AutoHotkeySC.bin](https://www.autohotkey.com/)
* [Optional] [MPRESS](http://www.matcode.com/mpress.htm)
* [Optional] [Resource Hacker](http://www.angusj.com/resourcehacker/)

# `build.ahkb`
A script that builds the project. Should be in root dir of the project.

## Functions
	AhkCompile(AhkFile, ExeFile := "", CustomIcon := "", BinFile := "", UseMPRESS := "", ResourceFile := "", fileCP := "")
* `AhkFile` - `.ahk` script path to be compiled
	Must be specified.
*  `ExeFile` - `.exe` file after compilation path
	If not specified it will be the same as script path, but `.exe` extension
* `CustomIcon` - Icon path
	If not specified will be default icon
* `BinFile` - AutoHotkeySC.bin path
	If not specified compiler will first search if the path specified in config.ini of AhkBuilder, then it will search in /bin directory of AhkBuilder, last it will look in Autohotkey directory /Compiler
* `UseMPRESS` - 1 use MPRESS, 0 don't use MPRESS. Default 0.
* `ResourceFile` - Path to resource file `.rc` to be added. For example, change default version. Requires Resource Hacker. `ResourceHacker.exe` full path must be specified in config.ini at the root of AhkBuilder
* `fileCP` - File encoding

## Example
Example of `build.ahkb`

	AhkCompile("src/script1.ahk", "build/executable1.exe", "src/Resources/asm.ico",, 1, "src/Resources/Version.rc") 
	AhkCompile("src/script2.ahk", "build/executable2.exe", "src/Resources/asm.ico",, 1, "src/Resources/Version.rc") 

# Commands
## `ahkb`
Parameters
* `build` only available parameter for now

Cmd or bash into a project folder which contains `build.ahkb` and run `ahkb build` in order to build a project

## `ahk_compile`
Parameters
* `-in <path>` - `.ahk` script path to be compiled
	Must be specified.
*  `-out <path>` - `.exe` file after compilation path
	If not specified it will be the same as sript path, but `.exe` extension
* `-icon <path>` - Icon path
	If not specified will be default icon
* `-bin <path>` - AutoHotkeySC.bin path
	If not specified compiler will first search if the path specified in config.ini of AhkBuilder, then it will search in /bin directory of AhkBuilder, last it will look in Autohotkey directory /Compiler
* `-mpress <0 or 1>` - 1 use MPRESS, 0 don't use MPRESS. Default 0.
* `-resource <path>` - Path to resource file `.rc` to be added. For example, change default version. Requires Resource Hacker. `ResourceHacker.exe` full path must be specified in config.ini at the root of AhkBuilder
* `-cp <encoding>` - File encoding