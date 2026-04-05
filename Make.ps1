# Script that compiles required binaries with gcc and Lua
# Lua source code should be in "src" folder
# I don't have make, i don't know what it is, and i think i don't need it

# Lua source
cd src
gcc -c -O2 $(dir *.c -Exclude lua.c,luac.c,linit.c)
cd ..

# Other stuff
gcc -c -O2 -I src Main.c linit.c ldonp.c lstatenp.c



# Stuff required for any program
ar rcs libmain.a Main.o linit.o

# No parse lib
ar rcs libnoparse.a ldonp.o lstatenp.o

# Lua.a for static linking
ar rcs libLua.a src\*.o

# Lua.dll for dynamic linking
gcc -shared -s -o libLuadll.dll $(dir src\*.o)

# l2e compiler
lua Lua2Exe.lua ArgParser MakeC Stuff Lua2Exe.lua -o l2e.exe -s -dll

del src\*.o, Main.o, linit.o, ldonp.o, lstatenp.o

md l2e
move l2e.exe, libmain.a, libnoparse.a, libLua.a, libLuadll.dll l2e
# At the end you should get: l2e.exe, libmain.a, libnoparse.a, libLua.a, libLuadll.dll