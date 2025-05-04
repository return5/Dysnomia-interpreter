--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local TokenizerEnums <const> = require('tokenizer.TokenizerEnums')
local MathTokenizer <const> = require('tokenizer.math.MathTokenizer')
local MinusToken <const> = require('tokens.math.MinusToken')
local MinusAssignmentToken <const> = require('tokens.math.MinusAssignmentToken')

local setmetatable <const> = setmetatable

local MinusTokenizer <const> = {type = TokenizerEnums.MinusTokenizer,token = MinusToken,assignmentToken = MinusAssignmentToken}
MinusTokenizer.__index = MinusTokenizer
setmetatable(MinusTokenizer,MathTokenizer)

_ENV = MinusTokenizer

return MinusTokenizer
