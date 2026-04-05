--[[
	Lua part of sam example.
	Uses functions from sam.c

	Compile like this:
	gcc sam.c -c
	l2e sam.lua sam.o
]]

local sam = require("sam")

sam.huh()
print(sam.os())