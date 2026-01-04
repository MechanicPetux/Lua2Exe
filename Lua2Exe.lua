local Stuff = require("Stuff")
local MakeC = require("MakeC")

local OutFileName = "Out.exe"
local Compiler = "gcc"
local Strip = false
local StandAlone = true
local ExtraOptions = ""

-- Main string with all modules packed into
-- package.preload and main file after
local Concated = ""
---@param Line string
local function AppendLine(Line)
	Concated = Concated .. Line .. '\n'
end

---@param OptionName string
---@param OptionIndex number
---@return string
local function GetArgForOption(OptionName, OptionIndex)
	return assert(arg[OptionIndex + 1], string.format("Option '%s' requires an argument", OptionName))
end

---@param Name string
---@return string
local function FindModule(Name)
	return assert(package.searchpath(Name, package.path))
end

---@param Name string
local function LoadModule(Name)
	local Path = FindModule(Name)
	local File = assert(io.open(Path, "r"))
	AppendLine("package.preload[\"" .. Name .. "\"] = function()")
	AppendLine('\t' .. File:read("a"):gsub('\n', "\n\t"))
	AppendLine("end")
	File:close()
end

local InputFiles = {} -- An array containing all modules and main file
local i = 1 -- Need to do 'while' because 'for' is not incrementing when option requires arg
while i <= #arg do
	local FirstChar = arg[i]:sub(1, 1)
	if FirstChar ~= '-' and FirstChar ~= '/' then
		table.insert(InputFiles, arg[i])
	else
		local Option = arg[i]:sub(2)
			if Option == "o"  then OutFileName =  GetArgForOption(arg[i], i) i = i + 1
		elseif Option == "c"  then Compiler =     GetArgForOption(arg[i], i) i = i + 1
		elseif Option == "s"  then Strip = true
		elseif Option == "dll"then StandAlone = false
		elseif Option == "a"  then ExtraOptions = GetArgForOption(arg[i], i) i = i + 1
		elseif Option == "?" or Option == "h" then
			Stuff.PrintHelp()
			os.exit(true)
		else
			print(string.format("Unrecognized option \"%s\"", arg[i]))
		end
	end

	i = i + 1
end

if not Stuff.Compilers[Compiler] then -- Is compiler supported?
	print(string.format("Compiler \"%s\" is not supported", Compiler))
	os.exit(false)
end

if not InputFiles[1] then -- Is there at least one input file?
	Stuff.PrintHelp()
	os.exit(false)
end

for i = 1, #InputFiles - 1 do -- -1 because last file is main file
	LoadModule(InputFiles[i])
end
local MainFile = assert(io.open(InputFiles[#InputFiles], "r"))
AppendLine(MainFile:read("a"))
MainFile:close()

local LoadedProgram = assert(load(Concated, "=Program"))
local ByteCode = string.dump(LoadedProgram, Strip)

local CFileDir = os.getenv("TEMP") or os.getenv("TMP") or "." -- Put file into %TEMP% if exist, to current dir otherwise
local CFilePath = CFileDir .. os.tmpname()

local Option_LangSpec = Stuff.Compilers[Compiler].LangSpec
local Option_Strip = Strip and Stuff.Compilers[Compiler].Strip or ""

if StandAlone then
	local Success = MakeC.MakeStandAlone(ByteCode, CFilePath)
	if not Success then os.exit(false) end
	os.execute(string.format("%s %s %s %s -o %s %s", Compiler, Option_LangSpec, Option_Strip, ExtraOptions, OutFileName, CFilePath))
else
	local Success = MakeC.MakeDLLDependent(ByteCode, CFilePath)
	if not Success then os.exit(false) end
	os.execute(string.format("%s %s %s %s -llua54 -o %s %s", Compiler, Option_LangSpec, Option_Strip, ExtraOptions, OutFileName, CFilePath))
end

os.remove(CFilePath)