--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local TokenizerEnums <const> = require('tokenizer.TokenizerEnums')
local Tokenizer <const> = require('tokenizer.Tokenizer')

local setmetatable <const> = setmetatable

local MathTokenizer <const> = {type = TokenizerEnums.MathTokenizer}
MathTokenizer.__index = MathTokenizer
setmetatable(MathTokenizer,Tokenizer)

_ENV = MathTokenizer

function MathTokenizer:loop()
	self:setTokenStart()
	local str <const> = {self:consumeCurrentChar()}
	if self:getCurrentChar() == "=" then
		self:consumeCurrentCharToStr(str)
		self:addToken(self.assignmentToken,str)
	else
		self:addToken(self.token,str)
	end
	return true
end

function MathTokenizer:tokenize(tokenizer)
	self:copyValues(tokenizer)
	self:loop()
	tokenizer:copyValues(self)
	return true
end

return MathTokenizer
