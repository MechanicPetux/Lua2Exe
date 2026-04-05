local ArgParser = {}

local Stuff = require("Stuff")

-- I don't like these globals, change later
OutFileName = "Out.exe"
Compiler = nil
Strip = false
StandAlone = true
Extra = ""
Only = "Exe"
NoParse = false
Verbose = false
ConfigPath = "Config"

---@param OptionName string
---@param i number
---@return string
local function GetArgForOption(OptionName, i)
	local Arg = arg[i]:sub(#OptionName + 1)
	if Arg == "" then
		i = i + 1
		Arg = assert(arg[i], string.format("Option '%s' requires an argument", OptionName))
	end
	return Arg, i
end

-- Returns everything after last dot (and dot itself) or name without dot
local function FileExt(FileName)
	return FileName:match("%..*$") or FileName
end

local function printf(format, ...)
	io.stdout:write(string.format(format, ...))
end

function ArgParser.Parse()
	local i = 1 -- Need to do 'while' because 'for' is not incrementing when option requires arg
	local b = {i = 1}

	local InputFiles = {}
	local InputObjects = {}
	while i <= #arg do
		local v = arg[i]
		local FirstChar = v:sub(1, 1)
		if FirstChar ~= '-' and FirstChar ~= '/' then
			local Ext = FileExt(v)
			if Ext == ".lua" then
				table.insert(InputFiles, v)
			elseif Ext == ".o" then
				table.insert(InputObjects, v)
			else
				table.insert(InputFiles, v)
			end
		else
			local Long = v:sub(2)
			local Short = v:sub(2, 2)
				if Short == "o" then OutFileName, i = GetArgForOption(v, i)
			elseif Long == "conf"then ConfigPath, i = GetArgForOption(v, i)
			elseif Short == "c" then Compiler, i =    GetArgForOption(v, i)
			elseif Long == "s"   then Strip = true
			elseif Long == "dll" then StandAlone = false
			elseif Long == "M"   then Only = "Merge"
			elseif Long == "C"   then Only = "C"
			elseif Long == "v"   then Verbose = true
			elseif Long == "np"  then NoParse = true
			elseif Short == "a" then Extra, i = GetArgForOption(v, i)
			elseif Long == "?" or Long == "h" then
				Stuff.PrintHelp()
			else
				printf("Unrecognized option \"%s\"\n", v)
			end
		end

		i = i + 1
	end

	return InputFiles, InputObjects
end

return ArgParser