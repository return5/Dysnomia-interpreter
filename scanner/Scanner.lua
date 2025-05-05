--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local TokenEnums <const> = require('token.TokenEnums')
local Token <const> = require('token.Token')
local TokenCoords <const> = require('token.TokenCoords')

local concat <const> = table.concat
local error <const> = error
local write = io.write

local setmetatable <const> = setmetatable

local Scanner <const> = {type = "Scanner"}
Scanner.__index = Scanner
_ENV = Scanner

function Scanner:addToken(type,str)
	self.tokenCoord:setEndingValues(self.line,self.currentCol)
	self.tokens[#self.tokens + 1] = Token:new(type,concat(str),self.tokenCoord)
	return self
end

function Scanner:getChar(i)
	return self.charArray[i]
end

function Scanner:getNextChar()
	return self:getChar(self.i + 1)
end

function Scanner:getCurrentChar()
	return self:getChar(self.i)
end

function Scanner:consumeCurrentChar()
	local char <const> = self:getChar(self.i)
	self:incrI()
	return char
end

function Scanner:checkChar(i,char)
	return self.charArray[i] == char
end

function Scanner:checkNextChar(char)
	return self:checkChar(self.i + 1,char)
end

function Scanner:checkCurrentChar(char)
	return self:checkChar(self.i,char)
end

function Scanner:addCharToStr(str)
	str[#str + 1] = self:consumeCurrentChar()
	return self
end

function Scanner:checkLimit()
	return self.i >= self.limit
end

function Scanner:errorOnLimit(i)
	if i > self.limit then
		error("error when searching for end of token\n")
	end
end

function Scanner:restCol()
	self.currentCol = 0
	return self
end

function Scanner:incrLine()
	self.line = self.line + 1
	return self:restCol()
end

function Scanner:newLine()
	self:consumeCurrentChar()
	return self:incrLine()
end

function Scanner:checkNextCharErrorOnLimit(char)
	self:errorOnLimit(self.i + 1)
	return self:checkNextChar(char)
end

function Scanner:singleLineCommentEnding(str)
	if self:checkCurrentChar("\n") then
		self:addToken(TokenEnums.Comment,str):newLine()
		return true
	end
	if self:checkLimit() then
		self:addCharToStr(str)
		self:addToken(TokenEnums.Comment,str)
		return true
	end
	self:addCharToStr(str)
	return false
end

function Scanner:multiLineCommentEqualSignsEnding(str)
	if self.runningCount == self.endingCount and self:checkCurrentCharErrorOnLimit("]") then
		self:addCharToStr(str)
		self:addCharToStr(str)
		self:addToken(TokenEnums.Comment,str)
		return true
	elseif self.runningCount > 0 and self:checkCurrentCharErrorOnLimit("=") then
		self:addCharToStr(str)
		self.runningCount = self.runningCount + 1
	elseif self:checkCurrentChar("]") and self:checkNextCharErrorOnLimit("=") then
		self:addCharToStr(str)
		self:addCharToStr(str)
		self.runningCount = self.runningCount + 1
	else
		if self:checkCurrentCharErrorOnLimit("\n") then
			self:addCharToStr(str)
			self:newLine()
		else
			self:addCharToStr(str)
		end
		self.runningCount = 0
	end
	return false
end

function Scanner:multiLineCommentEnding(str)
	if self:checkCurrentChar("]") and self:checkNextCharErrorOnLimit("]") then
		self:addCharToStr(str)
		self:addCharToStr(str)
		self:addToken(TokenEnums.Comment,str)
		self:incrI()
		return true
	end
	if self:checkCurrentChar("\n") then
		self:addCharToStr(str)
		self:newLine()
	else
		self:addCharToStr(str)
	end
	return false
end

function Scanner:countMultiLineCommentEqualSigns(str)
	self:addCharToStr(str)
	self.endingCount = 1
	self.runningCount = 0
	while self:checkCurrentChar("=") do
		self:addCharToStr(str)
		self.endingCount = self.endingCount + 1
	end
	if self:checkCurrentChar("[") then return self.multiLineCommentEqualSignsEnding end
	return self.singleLimeCommentTokenizer
end

--checking for multi line comments such as --[[ and --[=[
function Scanner:getMultiLineEnding(str)
	self:addCharToStr(str)
	if self:checkCurrentChar("[") then
		self:addCharToStr(str)
		return self.multiLineCommentEnding
	end
	if self:checkCurrentChar("=") then return self:countMultiLineCommentEqualSigns(str) end
	return self.singleLineCommentEnding
end

function Scanner:getCommentEndingFunc()
	if not self:checkCurrentChar("[") then
		return Scanner.singleLineCommentEnding
	end
	return self:getMultiLineCommentEnding()
end

function Scanner:scanComment()
	self:setTokenStart()
	local str <const> = {self:consumeCurrentChar(),self:consumeCurrentChar()}
	local commentEnding <const> = self:getCommentEndingFunc()
	return self:loopThroughToken(commentEnding,str)
end

function Scanner:checkForComment()
	if self:checkNextCharErrorOnLimit("-") then
		return self:scanComment()
	end
	return self:minus()
end

function Scanner:loopThroughToken(ending,str)
	while not ending(self,str) do end
	return self
end

function Scanner:setTokenStart()
	self.tokenCoord:setStartValues(self.line,self.currentCol)
	return self
end

function Scanner:incrCol()
	self.currentCol = self.currentCol + 1
	return self
end

function Scanner:incrI()
	self.i = self.i + 1
	return self:incrCol()
end

local charsToTokenize <const> = {
	['-'] = Scanner.checkForComment,
	["'"] = Scanner.singleQuote,
	['"'] = Scanner.doubleQuote,
	["\n"] = Scanner.consumeNewLine,
	["["] = Scanner.checkMultiLineString,
	[' '] = Scanner.consumeSpace,
	['\t'] = Scanner.consumeSpace,
	['\r'] = Scanner.consumeSpace,
	['+'] = Scanner.plus,
	['/'] = Scanner.slash,
	['*'] = Scanner.star
}

function Scanner:scanFile()
	while not self:checkLimit() do
		local currentChar <const> = self:getCurrentChar()
		if charsToTokenize[currentChar] then
			charsToTokenize[currentChar](self)
		else
			self:consumeCurrentChar()
		end
	end
	return self.tokens
end

function Scanner:new(charArray)
	return setmetatable({charArray = charArray,tokens = {},i = 1, limit = #charArray,currentCol = 1,tokenCoord = TokenCoords:new(),line = 1},self)
end

return Scanner
