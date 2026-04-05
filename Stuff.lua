--[[
	Different functions that doesn't fit anywhere else
]]

local Stuff = {}

local b = {
	{"-o File", "Set output file name"},
	{"-c Compiler", "Set C compiler. Supported compilers are: \"gcc\", \"clang\""},
	{"-conf Path", "Set L2E config path; file has to be accessible for require"},
	{"-s", "Strip debug information"},
	{"-dll", "Make exe dynamically linked"},
	{"-M", "Only merge files into one, do not compile"},
	{"-C", "Only compile files to C, do not compile to exe"},
	{"-v", "Be verbose (it only prints command for C compiler)"},
	{"-np", "Remove parsing related C code"},
	{"-a Options", "Additional options to pass to C compiler"},
	{"-[h | ?]", "Display this info"}
}

local function ConcatOptions()
	local LONGEST = 14
	local Result = {}
	for _, O in ipairs(b) do
		local Spacing = string.rep(' ', LONGEST - #O[1])
		table.insert(Result, "    " .. O[1] .. Spacing .. O[2])
	end
	return table.concat(Result, '\n')
end

function Stuff.PrintHelp()
	print([[
Compiles Lua scripts into executable

Usage: l2e [options] [modules...] main_file

Options:
]].. ConcatOptions() ..[[


Notes:
    Options work with both '-option' and '/option'
    In order to make a standalone exe, all modules used must
      be provided at compilation time]]
	)
	os.exit(true)
end

-- Can open file with selected mode?
local function canfile(fname, mode)
	local file = io.open(fname, mode)
	if file then file:close() return true end
	return false
end

-- More portable(?) function to generate temp file name
function os.tmppath()
	local Name = os.tmpname()
	if canfile(Name, "w") then return Name end -- Can write, already in the /tmp (unix i guess)

	local Path = (os.getenv("TEMP") or os.getenv("TMP") or ".") .. Name -- Put file into %TEMP% if exist, to current dir otherwise
	if canfile(Path, "w") then return Path end -- Can write with appended dir (windows)
	error("Cannot open temporary file, tmpname() result: " .. Name) -- Still cannot write for whatever reason
end

Stuff.Compilers = {
	["gcc"] = {
		["Strip"] = "-s"
	},
	["clang"] = {
		["Strip"] = "-g0"
	},
	["tcc"] = {
		["Strip"] = "-s"
	}
}

return Stuff