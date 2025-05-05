--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local setmetatable <const> = setmetatable
local TokenCoords <const> = {type = "TokenCoords"}
TokenCoords.__index = TokenCoords

_ENV = TokenCoords

function TokenCoords:setEndingValues(endingLine,endCol)
	self.endLine = endingLine
	self.endCol = endCol
	return self
end

function TokenCoords:setStartValues(startLine,startCol)
	self.startCol = startCol
	self.startLine = startLine
	return self
end

function TokenCoords:new()
	return setmetatable({startCol = 1, startLine = 1,endLine = 1, endCol = 1},self)
end

return TokenCoords
