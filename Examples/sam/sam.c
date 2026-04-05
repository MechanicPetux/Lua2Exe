/*
	Lua C library example.
*/

#include <stdio.h>
#include "lua.h"
#include "lauxlib.h"

#if defined(_WIN32)
const char *OS = "windows";
#elif defined(__linux__)
const char *OS = "linux";
#elif defined(__APPLE__)
const char *OS = "apple";
#else
const char *OS = "other";
#endif

static int sam_huh(lua_State *L) {
	(void)L; // unused
	puts("wuh");
	return 0; // number of Lua return values
}

static int sam_os(lua_State *L) {
	lua_pushstring(L, OS);
	return 1; // number of Lua return values
}

// function table
static const luaL_Reg sam_funcs[] = {
	{"huh", sam_huh},
	{"os", sam_os},
	{NULL, NULL}
};

// library entry point
int luaopen_sam(lua_State *L) {
	luaL_newlib(L, sam_funcs);
	return 1;
}