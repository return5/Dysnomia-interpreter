--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]


local setmetatable <const> = setmetatable
local write <const> = io.write

local Token <const> = {type = "Token"}
Token.__index = Token

_ENV = Token

function Token:print()
	write(self.type," :: ",self.str," :: ",self.startLine,":",self.startCol," :: ",self.endLine,":",self.endCol,"\n")
end

function Token:new(type,str,tokenCoords)
	return setmetatable({type = type,str = str,startCol = tokenCoords.startCol,endCol = tokenCoords.endCol,startLine = tokenCoords.startLine,endLine = tokenCoords.endLine},self)
end

return Token
