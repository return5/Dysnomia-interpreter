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

function Tokenizer:getChar(i)
	return self.fileArray[i]
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
	return i < self.limit and self:checkChar(i,char)
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

function Tokenizer.regularMultiLineComment(self,str)
	if self:checkCurrentChar("]") and self:checkNextChar("]") then
		self:consumerCurrentCharToStr(str)
		self:addToken(CommentToken:new(self,str))
		self:incrI()
		return true
	end
	return false
end

local function multiLineCommentEqualSignClosure(endingCount)
	local runningCount = 0
	return function(self,str)
		if self:checkCurrentChar("=") then
			self:consumeCurrentCharToStr(str)
			runningCount = runningCount + 1
			if runningCount == endingCount then
				self:incrI()
				return true
			end
		else
			runningCount = 0
		end
		return false
	end
end

function Tokenizer:countMultiLineCommentEqualSigns(str)
	self:consumeCurrentCharToStr(str)
	local endingCount = 1
	while self:checkCurrentChar("=") do
		self:consumeCurrentCharToStr(str)
		endingCount = endingCount + 1
	end
	return multiLineCommentEqualSignClosure(endingCount)

end

--checking for multi line comments such as --[[ and --[=[
function Tokenizer:countCommentEndingChars(str)
	self:consumerCurrentCharToStr(str)
	if self:checkCurrentChar("[") then
		self:consumerCurrentCharToStr(str)
		return Tokenizer.regularMultiLineComment
	end
	if self:checkCurrentChar("=") then return self:countMultiLineCommentEqualSigns(str) end
	return Tokenizer.singleLineComment
end

function Tokenizer.singleLineComment(self,str)
	if self:checkCurrentChar("\n") then
		str[#str + 1] = "\n"
		self.addToken(CommentToken:new(self,concat(str)))
		self:incrI()
		return true
	end
	return false
end

function Tokenizer:getCommentEnding(str)
	if not self:checkCurrentChar("[") then return Tokenizer.singleLineComment end
	return self:countCommentEndingChars(str)
end


function Tokenizer:loopOverComment()
	local str <const> = {'--'}
	self:setTokenStart()
	self:incrI():incrI()
	local ending <const> = self:getCommentEnding(str)
	for i = self.i,self.limit,1 do
		if ending(self,str) then
			return true
		end
		str[#str + 1] = self:getCurrentChar()
	end
	return false
end

function Tokenizer:tokenizeFile()
	local cont = true
	while cont do
		if self:checkCurrentChar("-") and self:checkNextChar('-') then
			cont = self:loopOverComment()
		end

	end
	return self.tokens
end

function Tokenizer:new(fileArray)
	return setmetatable({fileArray = fileArray,tokens = {},i = 1, limit = #fileArray,tokenStartCol = 1,tokenStartLine = 1,line = 1},self)
end

function Tokenizer.tokenize(fileArray)
	local fileTokenizer <const> = Tokenizer:new(fileArray)
	return fileTokenizer:tokenizeFile()
end

return Tokenizer
