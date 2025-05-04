--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local TokenEnums <const> = require('tokens.TokenEnums')

local Token <const> = require('tokens.Token')
local setmetatable <const> = setmetatable

local StarAssignmentToken <const> = {type = TokenEnums.StarAssignment}
StarAssignmentToken.__index = StarAssignmentToken
setmetatable(StarAssignmentToken,Token)

_ENV = StarAssignmentToken

function StarAssignmentToken:new(tokenizer,str)
	return setmetatable(Token:new(tokenizer,str),self)
end

return StarAssignmentToken
