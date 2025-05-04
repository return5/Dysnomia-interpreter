--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local TokenizerEnums <const> = require('tokenizer.TokenizerEnums')
local MathTokenizer <const> = require('tokenizer.math.MathTokenizer')
local StarToken <const> = require('tokens.math.StarToken')
local StarAssignmentToken <const> = require('tokens.math.StarAssignmentToken')

local setmetatable <const> = setmetatable

local StarTokenizer <const> = {type = TokenizerEnums.StarTokenizer,token = StarToken,assignmentToken = StarAssignmentToken}
StarTokenizer.__index = StarTokenizer
setmetatable(StarTokenizer,MathTokenizer)

_ENV = StarTokenizer

return StarTokenizer
