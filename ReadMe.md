# Lua2Exe
Simple program to compile Lua scripts into executable.

[![Русский Перевод](https://mechanicpetux.lol/stuff/Shield_ru.svg)](https://github.com/MechanicPetux/Lua2Exe/blob/master/ReadMe.ru.md)
## Usage
`l2e [options] [modules...] main_file`

Available options are:
* -o File           Set output file name.
* -c Compiler  Set C compiler. Supported compilers are: "gcc", "clang".
* -s                  Strip debug information from exe.<br>
* -dll                Make exe DLL dependent.<br>
* -a Options    Additional options to pass to C compiler.
* -\[h | ?\]           Display this info.

> [!IMPORTANT]
> * The order of files is important. Main file must be the last.
> * Module names should be the same as in your `require`. That is *My.lua* turns into *My*.
> * As there's no reliable way to determine all dependencies, in order to make a standalone exe, all modules used must be provided at compilation time.


## Features
Currently there's not much, but it has the basics:
* Compilation to standalone exe.
* Compilation to DLL dependent exe.
* Support of different compilers. (Kinda. It wasn't tested)

## Dependicies
To use all features required:
* Lua source code.
* Lua DLL.
* C Compiler.

> [!NOTE]
> I'm not sure about portability. Mostly because of file temporary file handling.