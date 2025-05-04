--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local TokenizerEnums <const> = require('tokenizer.TokenizerEnums')
local Tokenizer <const> = require('tokenizer.Tokenizer')
local StringToken <const> = require('tokens.StringToken')

local setmetatable <const> = setmetatable

local StringTokenizer <const> = {type = TokenizerEnums.StringTokenizer}
setmetatable(StringTokenizer,Tokenizer)
StringTokenizer.__index = StringTokenizer

_ENV = StringTokenizer

function StringTokenizer:checkForEndOfString()
	return self:checkCurrentCharErrorOnLimit('"')
end

function StringTokenizer:ending(str)
	if self:checkForEndOfString(str) then
		self:consumeCurrentCharToStr(str)
		self:addToken(StringToken,str)
		self:incrI()
		return true
	end
	self:consumeCurrentCharToStr(str)
	return false
end

function StringTokenizer:loopOverString(strChar)
	local str <const> = {strChar}
	self:setTokenStart()
	self:incrI()
	self:loop(self.ending,str)
end

function StringTokenizer:tokenizeString(tokenizer)
	self:copyValues(tokenizer)
	self:loopOverString(self:getCurrentChar())
	tokenizer:copyValues(self)
	return true
end

return StringTokenizer
