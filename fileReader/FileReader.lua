--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local error <const> = error
local read <const> = io.read
local open <const> = io.open
local gmatch <const> = string.gmatch

local FileReader <const> = {type = "FileReader"}
FileReader.__index = FileReader
_ENv = FileReader

local function strToCharArray(str)
	local charArray <const> = {}
	for char in gmatch(str,".") do
		charArray[#charArray + 1] = char
	end
	return charArray
end

local function getFileStr(fileName)
	local file <const> = open(fileName,"r+")
	if not file then error("error: can not open file: " .. fileName) end
	local fileStr <const> = file:read("*a")
	file:close()
	return fileStr
end

function FileReader.readLine()
	return strToCharArray(read("l"))
end

function FileReader.readFile(file)
	local fileStr <const> = getFileStr(file)
	return strToCharArray(fileStr)
end


return {readFile = FileReader.readFile, readLine = FileReader.readLine}
