--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local CommentToken <const> = require('tokens.CommentToken')
local concat <const> = table.concat

local setmetatable <const> = setmetatable

local Tokenizer <const> = {}
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

function Tokenizer:setTokenStart()
	self.tokenStartCol = self.i
	self.tokenStartLine = self.line
	return self
end

function Tokenizer:incrI()
	self.i = self.i + 1
	return self
end

function Tokenizer:getToken(i)
	return self.fileArray[i]
end

function Tokenizer:checkToken(i,char)
	return i < self.limit and self:checkToken(i,char)
end

function Tokenizer:checkCurrentToken(char)
	return self:checkToken(self.i,char)
end

function Tokenizer:checkNextToken(char)
	return self:checkToken(self.i + 1,char)
end

--checking for multi line comments such as --[[ and --[=[
function Tokenizer:countCommentEndingChars()
	self:incrI()
	if self:checkCurrentToken("[") then
		return "]",0
	end
	self:incrI()
	if self:checkCurrentToken("[") and self:checNextToken("=") then return "]", self:countChars("=") end
end

function Tokenizer.singleLineComment(self,str)
	if self:checkCurrentToken("\n") then
		self:incrI()
		str[#str + 1] = "\n"
		self.addToken(CommentToken:new(self,concat(str)))
		return true
	end
end

function Tokenizer:getCommentEnding()
	if not self:checkCurrentToken("[") then return Tokenizer.singleLineComment end
	return self:countCommentEndingChars()
end


function Tokenizer:loopOverComment()
	local str <const> = {'--'}
	self:setTokenStart()
	self:incrI():incrI()
	local ending <const>, endingCount <const> = self:getCommentEnding()
end

function Tokenizer:tokenizeFile()
	local cont = true
	while cont do
		if self:checkCurrentToken("-") and self:checkNextToken('-') then
			cont = self:loopOverComment()
		end

	end
	return tokens
end

function Tokenizer:new(fileArray)
	return setmetatable({fileArray = fileArray,tokens = {},i = 1, limit = #fileArray,tokenStartCol = 1,tokenStartLine = 1,line = 1},self)
end

function Tokenizer.tokenize(fileArray)
	local fileTokenizer <const> = Tokenizer:new(fileArray)
	return fileTokenizer:tokenizeFile()
end

return Tokenizer
