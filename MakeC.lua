--[[
	Creation of C file, which includes libraries and program itself
]]

local MakeC = {}

---@param ByteCode string
---@return string
local function ByteCodeToArray(ByteCode)
	local Array = {string.byte(ByteCode, 1, -1)}
	return table.concat(Array, ',')
end

local function insert(t, ...)
	for _, v in ipairs({...}) do
		table.insert(t, v)
	end
end

-- Returns name wtihout extension (all before last dot)
local function BaseName(Name)
	return Name:match("^(.+)%..-") or Name
end

function MakeC.Make(ByteCode, Objects)
	local t = {}
	local Libs = {
		{"LUA_GNAME", "base"},
		{"LUA_LOADLIBNAME", "package"},
		{"LUA_COLIBNAME", "coroutine"},
		{"LUA_TABLIBNAME", "table"},
		{"LUA_IOLIBNAME", "io"},
		{"LUA_OSLIBNAME", "os"},
		{"LUA_STRLIBNAME", "string"},
		{"LUA_MATHLIBNAME", "math"},
		{"LUA_UTF8LIBNAME", "utf8"},
		{"LUA_DBLIBNAME", "debug"}
	}


	for _, v in ipairs(Objects) do
		local Name = BaseName(v)
		insert(Libs, {'"'..Name..'"', Name})
	end

	insert(t, [[
#include <stddef.h>
#include "lualib.h"
#include "lauxlib.h"
]])

	-- Declare open functions
	for _, v in ipairs(Libs) do
		insert(t, "int luaopen_" .. v[2] .. "(lua_State *L);")
	end

	insert(t, "const luaL_Reg loadedlibs[] = {")

	-- Shove declared functions into the array
	for _, v in ipairs(Libs) do
		insert(t, "\t{" .. v[1] .. ", luaopen_" .. v[2] .. "},")
	end

	insert(t, [[
	{NULL, NULL}
};

// The program's ByteCode
const unsigned char prog[] = {]] .. ByteCodeToArray(ByteCode) .. [[};
const size_t prog_size = sizeof(prog);]])

	return table.concat(t, '\n')
end

return MakeC