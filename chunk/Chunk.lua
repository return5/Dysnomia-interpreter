--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local setmetatable <const> = setmetatable
local Chunk <const> = {type = "Chunk"}
Chunk.__index = Chunk

_ENV = Chunk

function Chunk:addConstant(value)
	self.constants[#self.constants + 1] = value
	return #self.constants - 1
end

function Chunk:writeChunk(byte,line)
	self.lines[#self.lines + 1] = line
	self.code[#self.code + 1] = byte
	return self
end

function Chunk:new()
	return setmetatable({code = {},lines = {},constants = {}},self)
end

return Chunk
