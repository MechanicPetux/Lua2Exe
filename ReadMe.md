# Lua2Exe
Simple program to compile Lua scripts into executable.

[![Русский Перевод](https://mechanicpetux.lol/stuff/Shield_ru.svg)](ReadMe.ru.md)
## Install
* You need a C compiler in your %PATH%
* Windows: download release, unpack somewhere in your %PATH% and edit the Config.lua to suit your environment.
* Other OS: you will need to compile it from the source, the Make.ps1 is included, so just run it if you have powershell, gcc and Lua.
Or edit it to suit your shell and environment. After compilation, edit the Config.lua to suit your environment.
At last, you need to either move it somewhere Lua can include config from, or pass "-conf path" for each compilation

For installing and usage related question, i've made a short [manual](https://mechanicpetux.lol/lua2exe/manual.html) describing everything in details.

## Usage
`l2e [options] [modules...] main_file`

Available options are:
<table>
	<tr><td>-o File</td><td>Set output file name</td></tr>
	<tr><td>-c Compiler</td><td>Set C Compiler. Supported compilers are: "gcc", "clang", "tcc"</td></tr>
	<tr><td>-conf Path</td><td>Set L2E config path; file has to be accessible for require</td></tr>
	<tr><td>-s</td><td>Strip debug information from exe</td></tr>
	<tr><td>-dll</td><td>Make exe dynamically linked</td></tr>
	<tr><td>-M</td><td>Only merge files into one, do not compile</td></tr>
	<tr><td>-C</td><td>Only compile files to C, do not compile to exe</td></tr>
	<tr><td>-v</td><td>Be verbose (it only prints command for C compiler)</td></tr>
	<tr><td>-np</td><td>Remove Parsing related code, reduce exe size</td></tr>
	<tr><td>-a Options</td><td>Additional options to pass to C compiler</td></tr>
	<tr><td>-[h | ?]</td><td>Display this info</td></tr>
</table>

> [!IMPORTANT]
> * The order of Lua files is important. Main file must be the last.
> * Module names should be the same as in your `require`. That is *My.lua* turns into *My*.
> * As there's no reliable way to determine all dependencies, in order to make a standalone exe, all modules used must be provided at compilation time.

## Features
Main features are:
* Compilation to standalone exe
* Compilation to dynamically linked exe
* Support of both Lua and C dependencies
* Support of different compilers. (Kinda. It wasn't tested and probably will be replaced in next update)

> [!NOTE]
> I'm not sure about portability. Mostly because of temporary file handling.