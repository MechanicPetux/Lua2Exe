local Stuff = {}

---@param v any?
---@param message string
---@return any ...
-- Reimplement assert cuz i don't like that pesky traceback
function assert(v, message, ...)
	if not message then message = "assertion failed!" end
	if not v then print(message) os.exit(false) end
	return v, message, ...
end

function Stuff.PrintHelp()
	print([[
Compiles Lua scripts into executable

Usage: l2e [options] [modules...] main_file

Options:
    -o File     Set output file name.
    -c Compiler Set C compiler. Supported compilers are: "gcc", "clang".
    -s          Strip debug information from exe.
    -dll        Make exe DLL dependent.
    -a Options  Additional options to pass to C compiler.
    -[h | ?]    Display this info.

Notes:
    Options work with both '-option' and '/option'
    In order to make a standalone exe, all modules used must
      be provided at compilation time]])
end

Stuff.Compilers = {
	["gcc"] = {
		["LangSpec"] = "-x c",
		["Strip"] = "-s"
	},
	["clang"] = {
		["LangSpec"] = "-x c",
		["Strip"] = "-g0"
	}
}

return Stuff