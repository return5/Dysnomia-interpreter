--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local TokenEnums <const> = require('tokens.TokenEnums')

local setmetatable <const> = setmetatable
local write <const> = io.write

local Token <const> = {type = TokenEnums.Token}
Token.__index = Token

_ENV = Token

function Token:print()
	write(self.type," :: ",self.str," :: ",self.startLine,":",self.startCol," :: ",self.endLine,":",self.endCol,"\n")
end

function Token:new(tokenizer,str)
	return setmetatable({str = str,startCol = tokenizer.tokenStartCol,endCol = tokenizer.currentCol - 1,startLine = tokenizer.tokenStartLine,endLine = tokenizer.line},self)
end

return Token
