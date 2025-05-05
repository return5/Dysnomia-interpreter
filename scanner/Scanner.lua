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
	self.tokenCoord:setEndingValues(self.line,self.currentCol - 1)
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

function Scanner:checkPreviousChar(char)
	return self:checkChar(self.i - 1,char)
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

function Scanner:checkCurrentCharErrorOnLimit(char)
	self:errorOnLimit(self.i)
	return self:checkCurrentChar(char)
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
function Scanner:getMultiLineCommentEnding(str)
	self:addCharToStr(str)
	if self:checkCurrentChar("[") then
		self:addCharToStr(str)
		return self.multiLineCommentEnding
	end
	if self:checkCurrentChar("=") then return self:countMultiLineCommentEqualSigns(str) end
	return self.singleLineCommentEnding
end

function Scanner:getCommentEndingFunc(str)
	if not self:checkCurrentChar("[") then
		return Scanner.singleLineCommentEnding
	end
	return self:getMultiLineCommentEnding(str)
end

function Scanner:scanComment()
	self:setTokenStart()
	local str <const> = {self:consumeCurrentChar(),self:consumeCurrentChar()}
	local commentEnding <const> = self:getCommentEndingFunc(str)
	return self:loopThroughToken(commentEnding,str)
end

function Scanner:minus()
	if self:checkNextCharErrorOnLimit("-") then
		return self:scanComment()
	end
	return self:negativeSign()
end

function Scanner:negativeSign()

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

function Scanner:scanString(strEnding)
	self:incrI()
	self:setTokenStart()
	local str <const> = {}
	return self:loopThroughToken(strEnding,str)
end

local function stringEnding(char)
	return function(self,str)
		if self:checkCurrentCharErrorOnLimit(char) and not self:checkPreviousChar("\\") then
			self:addToken(TokenEnums.String,str)
			self:incrI()
			return true
		end
		self:addCharToStr(str)
		return false
	end
end

function Scanner:singleQuote()
	return self:scanString(stringEnding("'"))
end

function Scanner:doubleQuote()
	return self:scanString(stringEnding('"'))
end

function Scanner:multiLineStringEnding(str)
	if self:checkCurrentCharErrorOnLimit("]") and not self:checkPreviousChar("%") and self:checkNextCharErrorOnLimit("]") then
		self:addToken(TokenEnums.String,str)
		self:incrI():incrI()
		return true
	end
	self:addCharToStr(str)
	return false
end

function Scanner:multiLineString()
	return self:scanString(Scanner.multiLineStringEnding)
end

function Scanner:simpleToken(type)
	self:setTokenStart()
	return self:addToken(type,{self:consumeCurrentChar()})
end

function Scanner:bracket()
	if self:checkNextCharErrorOnLimit('[') then
		return self:incrI():multiLineString()
	end
	return self:simpleToken(TokenEnums.OpenBracket)
end

function Scanner:curlyBracket()
	self:simpleToken(TokenEnums.OpenCurlyBracket)
end

function Scanner:math(mathToken,updateToken)
	self:setTokenStart()
	local str <const> = {self:consumeCurrentChar()}
	if self:checkCurrentCharErrorOnLimit("=") then
		self:addCharToStr(str)
		return self:addToken(updateToken,str)
	end
	return self:addToken(mathToken,str)
end

function Scanner:negativeSign()
	return self:math(TokenEnums.Minus,TokenEnums.MinusAssignment)
end

function Scanner:plus()
	return self:math(TokenEnums.Plus,TokenEnums.PlusAssignment)
end

function Scanner:slash()
	return self:math(TokenEnums.Slash,TokenEnums.SlashAssignment)
end

function Scanner:star()
	return self:math(TokenEnums.Star,TokenEnums.StarAssignment)
end

function Scanner:curlyBracket()
    return self:simpleToken(TokenEnums.curlyBracket)
end

function Scanner:closingCurlyBracket()
    return self:simpleToken(TokenEnums.closingCurlyBracket)
end

function Scanner:parenthesis()
    return self:simpleToken(TokenEnums.parenthesis)
end

function Scanner:closingParenthesis()
    return self:simpleToken(TokenEnums.closingParenthesis)
end

function Scanner:closingBracket()
    return self:simpleToken(TokenEnums.closingBracket)
end

function Scanner:colon()
    return self:simpleToken(TokenEnums.colon)
end

function Scanner:semiColon()
    return self:simpleToken(TokenEnums.semiColon)
end

function Scanner:period()
    return self:simpleToken(TokenEnums.period)
end

function Scanner:comma()
    return self:simpleToken(TokenEnums.comma)
end


local charsToTokenize <const> = {
	['-'] = Scanner.minus,
	["'"] = Scanner.singleQuote,
	['"'] = Scanner.doubleQuote,
	["\n"] = Scanner.newLine,
	["["] = Scanner.bracket,
	[' '] = Scanner.consumeCurrentChar,
	['\t'] = Scanner.consumeCurrentChar,
	['\r'] = Scanner.consumeCurrentChar,
	['+'] = Scanner.plus,
	['/'] = Scanner.slash,
	['*'] = Scanner.star,
	["{"] = Scanner.curlyBracket,
	["}"] = Scanner.closingCurlyBracket,
	["("] = Scanner.parenthesis,
	[")"] = Scanner.closingParenthesis,
	["]"] = Scanner.closingBracket,
	[":"] = Scanner.colon,
	[";"] = Scanner.semiColon,
	["."] = Scanner.period,
	[","] = Scanner.comma,

}

function Scanner:scanFile()
	repeat
		local currentChar <const> = self:getCurrentChar()
		if charsToTokenize[currentChar] then
			charsToTokenize[currentChar](self)
		else
			self:consumeCurrentChar()
		end
	until self:checkLimit()
	return self.tokens
end

function Scanner:new(charArray)
	return setmetatable({charArray = charArray,tokens = {},i = 1, limit = #charArray,currentCol = 1,tokenCoord = TokenCoords:new(),line = 1},self)
end

return Scanner
