--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local TokenizerEnums <const> = require('tokenizer.TokenizerEnums')
local concat <const> = table.concat
local write <const> = io.write
local error <const> = error

local setmetatable <const> = setmetatable

local Tokenizer <const> = {type = TokenizerEnums.Tokenizer}
Tokenizer.__index = Tokenizer
_ENV = Tokenizer

local symbols <const> = {
	['function'] = true,
	['<'] = true,
	['const'] = true,
	['immutable'] = true,
	['mutable'] = true,
	['global'] = true,
	['local'] = true,
	['if'] = true,
	['else'] = true,
	['elseif'] = true,
	['then'] = true,
	['end'] = true,
	['while'] = true,
	['do'] = true,
	['repeat'] = true,
	['until'] = true,
	['while'] = true,
	['for'] = true,
	['{'] = true,
	['('] = true,
	[';'] = true,
	['return'] = true,
	['='] = true,
	['+'] = true,
	['/'] = true,
	['*'] = true,
	['and'] = true,
	['or'] = true,
	['%'] = true,
	['.'] = true,
	[':'] = true,
	['break'] = true,
	['continue'] = true
}

local stringSymbols <const> = {
	['['] = true,
	['"'] = true,
	["'"] = true
}

local commentSymbols <const> = {
	['--'] = true,
	['--[['] = true
}

local spaceSymbols <const> = {
	[' '] = true,
	['\t'] = true,
	['\r'] = true
}

function Tokenizer:copyValues(tokenizer)
	self.charArray = tokenizer.charArray
	self.tokens = tokenizer.tokens
	self.i = tokenizer.i
	self.limit = tokenizer.limit
	self.tokenStartCol = tokenizer.tokenStartCol
	self.tokenStartLine = tokenizer.tokenStartLine
	self.line = tokenizer.line
	return self
end

function Tokenizer:addToken(token)
	self.tokens[#self.tokens + 1] = token
	return self
end

function Tokenizer:setTokenStart()
	self.tokenStartCol = self.i
	self.tokenStartLine = self.line
	return self
end

function Tokenizer:incrI()
	self.i = self.i + 1
	return self
end

function Tokenizer:getChar(i)
	return self.charArray[i]
end

function Tokenizer:getCurrentChar()
	return self:getChar(self.i)
end

function Tokenizer:consumeCurrentChar()
	local char <const> = self:getChar(self.i)
	self:incrI()
	return char
end

function Tokenizer:checkChar(i, char)
	return self.charArray[i] == char
end

function Tokenizer:checkCurrentChar(char)
	return self:checkChar(self.i,char)
end

function Tokenizer:checkNextChar(char)
	return self:checkChar(self.i + 1,char)
end

function Tokenizer:consumeCurrentCharToStr(str)
	str[#str + 1] = self:consumeCurrentChar()
	return self
end

function Tokenizer:checkNextCharErrorOnLimit(char)
	if self:checkNextChar(char) then return true end
	if self.i + 1 >= self.limit then error("reached end of file when searching for: " .. char) end
	return false
end

function Tokenizer:new(charArray)
	return setmetatable({charArray = charArray,tokens = {},i = 1, limit = #charArray,tokenStartCol = 1,tokenStartLine = 1,line = 1},self)
end

return Tokenizer
