local MakeC = {}

---@param ByteCode string
---@return string
local function ByteCodeToArray(ByteCode)
	local Array = {string.byte(ByteCode, 1, -1)}
	return table.concat(Array, ',')
end

local function MakeArrayString(ByteCode)
	return [[
// The program's ByteCode
const unsigned char prog[] = {]] .. ByteCodeToArray(ByteCode) .. [[};

]]
end

local function WriteString(FileName, String)
	local CFile, ErrorMessage = io.open(FileName, "w")
	if not CFile then
		print(ErrorMessage)
		os.remove(FileName)
		return false
	end

	local Success, ErrorMessage = CFile:write(String)
	if not Success then
		print(ErrorMessage)
		CFile:close()
		os.remove(FileName)
		return false
	end
	CFile:close()

	return true
end

local HeadersStandAlone = [[
#include <lapi.c>
#include <lcode.c>
#include <lctype.c>
#include <ldebug.c>
#include <ldo.c>
#include <ldump.c>
#include <lfunc.c>
#include <lgc.c>
#include <llex.c>
#include <lmem.c>
#include <lobject.c>
#include <lopcodes.c>
#include <lparser.c>
#include <lstate.c>
#include <lstring.c>
#include <ltable.c>
#include <ltm.c>
#include <lundump.c>
#include <lvm.c>
#include <lzio.c>

#include <lauxlib.c>
#include <lbaselib.c>
#ifdef LUA_COMPAT_BITLIB
	#include <lbitlib.c>
#endif
#include <lcorolib.c>
#include <ldblib.c>
#include <liolib.c>
#include <lmathlib.c>
#include <loadlib.c>
#include <loslib.c>
#include <lstrlib.c>
#include <ltablib.c>
#include <lutf8lib.c>
#include <linit.c>

]]

local HeadersDLLDependent = [[
#include <stdlib.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

]]

local Part1 = [[
#define PROGNAME "Program"

/*
** Prints an error message, adding the program name in front of it
** (if present)
*/
static void l_message(const char *pname, const char *msg) {
	if (pname) lua_writestringerror("%s: ", pname);
	lua_writestringerror("%s\n", msg);
}

/*
** Check whether 'status' is not OK and, if so, prints the error
** message on the top of the stack.
*/
static int report(lua_State *L, int status) {
	if (status != LUA_OK) {
		const char *msg = lua_tostring(L, -1);
		if (msg == NULL) msg = "(error message not a string)";
		l_message(NULL, msg);
		lua_pop(L, 1);  /* remove message */
	}
	return status;
}

/*
** Message handler used to run all chunks
*/
static int msghandler(lua_State *L) {
	const char *msg = lua_tostring(L, 1);
	if (msg == NULL) {  /* is error object not a string? */
		if (luaL_callmeta(L, 1, "__tostring") &&  /* does it have a metamethod */
				lua_type(L, -1) == LUA_TSTRING)  /* that produces a string? */
			return 1;  /* that is the message */
		else msg = lua_pushfstring(L, "(error object is a %s value)", luaL_typename(L, 1));
	}
	luaL_traceback(L, L, msg, 1);  /* append a standard traceback */
	return 1;  /* return the traceback */
}

/*
** Create the 'arg' table, which stores all arguments from the
** command line ('argv'). It has the same index-value pairs as argv.
** (If there is no program's name, 'script' is 0, so
** table sizes are zero.)
*/
static void createargtable(lua_State *L, const char **argv, const int argc) {
	const int script = argc > 0;
	const int narg = argc - script;  /* number of positive indices */
	lua_createtable(L, narg, script);
	for (int i = 0; i < argc; i++) {
		lua_pushstring(L, argv[i]);
		lua_rawseti(L, -2, i);
	}
	lua_setglobal(L, "arg");
}

]]

local Part2 = [[
int main(const int argc, const char **argv) {
	lua_State *L = luaL_newstate();
	if (L == NULL) {
		l_message(PROGNAME, "cannot create state: not enough memory");
		return EXIT_FAILURE;
	}
	luaL_checkversion(L);  /* check that interpreter has correct version */
	lua_gc(L, LUA_GCSTOP);  /* stop GC while building state */
	luaL_openlibs(L);  /* open standard libraries */
	createargtable(L, argv, argc);  /* create table 'arg' */
	lua_gc(L, LUA_GCRESTART);  /* start GC... */
	lua_gc(L, LUA_GCGEN, 0, 0);  /* ...in generational mode */

	lua_pushcfunction(L, msghandler);  // push message handler
	const int e = lua_gettop(L);
	int status = luaL_loadbufferx(L, prog, sizeof(prog), "@FUCK" PROGNAME, "b");
	if (status == LUA_OK) status = lua_pcall(L, 0, 0, e);
	lua_remove(L, e);  // remove message handler from the stack
	report(L, status);

	lua_close(L);
	return (status == LUA_OK) ? EXIT_SUCCESS : EXIT_FAILURE;
}]]

function MakeC.MakeStandAlone(ByteCode, FileName)
	local CFileContents = HeadersStandAlone .. Part1 .. MakeArrayString(ByteCode) .. Part2
	return WriteString(FileName, CFileContents)
end

function MakeC.MakeDLLDependent(ByteCode, FileName)
	local CFileContents = HeadersDLLDependent .. Part1 .. MakeArrayString(ByteCode) .. Part2
	return WriteString(FileName, CFileContents)
end

return MakeC