local Stuff = require("Stuff")
local MakeC = require("MakeC")
local ArgParser = require("ArgParser")

local function OpenFile(Name, Mode)
	return assert(io.open(Name, Mode))
end

local function WriteString(FileName, String)
	local File, ErrorMessage = io.open(FileName, "w")
	if not File then
		print(ErrorMessage)
		return false
	end

	local Success, ErrorMessage = File:write(String)
	if not Success then
		print(ErrorMessage)
		File:close()
		return false
	end
	File:close()

	return true
end

-- Main string with all modules packed into
-- package.preload and main file after
local Lines = {}
---@param Line string
local function AppendLine(Line)
	table.insert(Lines, Line)
end

---@param Name string
local function LoadModule(Name)
	local Path = assert(package.searchpath(Name, package.path)) -- package.path searches only for Lua scripts
	local File = OpenFile(Path, "r")
	AppendLine("package.preload[\"" .. Name .. "\"] = function()")
	AppendLine(File:read("a"))
	AppendLine("end")
	File:close()
end

local InputFiles, InputObjects = ArgParser.Parse()
local Config = require(ConfigPath)
Compiler = Compiler or Config.Compiler

-- Is compiler supported?
if not Stuff.Compilers[Compiler] then error(string.format("Compiler \"%s\" is not supported", Compiler)) end
-- Is there at least one input file?
if not InputFiles[1] then Stuff.PrintHelp() end

local LoadedModules = {}
for i = 1, #InputFiles - 1 do -- -1 because last file is main file
	if not LoadedModules[InputFiles[i]] then
		LoadModule(InputFiles[i])
		LoadedModules[InputFiles[i]] = true
	end
end
local MainFile = OpenFile(InputFiles[#InputFiles], "r")
AppendLine(MainFile:read("a"))
MainFile:close()

local Concated = table.concat(Lines, '\n')
if Only == "Merge" then
	local File = OpenFile(OutFileName, "w")
	assert(File:write(Concated))
	File:close()
	return
end

local LoadedProgram = assert(load(Concated, "=Program"))
local ByteCode = string.dump(LoadedProgram, Strip)

local CFileContents = MakeC.Make(ByteCode, InputObjects)
if Only == "C" then
	local File = OpenFile(OutFileName, "w")
	assert(File:write(CFileContents))
	File:close()
	return
end


table.insert(InputObjects, "-lmain")
if NoParse then
	table.insert(InputObjects, "-lnoparse")
end
if StandAlone then table.insert(InputObjects, "-lLua")
else table.insert(InputObjects, "-lLuadll")
end

local CFilePath = os.tmppath() .. ".c"
if not WriteString(CFilePath, CFileContents) then
	os.remove(CFilePath)
	os.exit(false)
end
local Option_Strip = Strip and Stuff.Compilers[Compiler].Strip or ""
local Command = string.format("%s %s %s -I %s -L %s -o %s %s %s",
	Compiler, Option_Strip, Extra, Config.IncludeDir, Config.LibDir, OutFileName, CFilePath, table.concat(InputObjects, ' '))

if Verbose then print(Command) end

os.execute(Command)
os.remove(CFilePath)