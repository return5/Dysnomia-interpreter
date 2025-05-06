--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local TokenEnum <const> = require('token.TokenEnum')
local Token <const> = require('token.Token')
local TokenCoords <const> = require('token.TokenCoords')

local concat <const> = table.concat
local error <const> = error
local length <const> = string.len
local pairs <const> = pairs
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

function Scanner:checkCurrentCharMatchTable(tbl)
	return tbl[self:getCurrentChar()]
end

function Scanner:checkNextCharMatchTable(tbl)
	return tbl[self:getNextChar()]
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
	return self.i > self.limit
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
		self:addToken(TokenEnum.Comment,str):newLine()
		return true
	end
	if self:checkLimit() then
		self:addCharToStr(str)
		self:addToken(TokenEnum.Comment,str)
		return true
	end
	self:addCharToStr(str)
	return false
end

function Scanner:multiLineCommentEqualSignsEnding(str)
	if self.runningCount == self.endingCount and self:checkCurrentCharErrorOnLimit("]") then
		self:addCharToStr(str)
		self:addToken(TokenEnum.Comment,str)
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
		self:addToken(TokenEnum.Comment,str)
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
			self:addToken(TokenEnum.String,str)
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
		self:addToken(TokenEnum.String,str)
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
	return self:simpleToken(TokenEnum.OpenBracket)
end

function Scanner:curlyBracket()
	self:simpleToken(TokenEnum.OpenCurlyBracket)
end

function Scanner:twoCharToken(singleCharToken,twoCharToken,char)
	self:setTokenStart()
	local str <const> = {self:consumeCurrentChar()}
	if self:checkCurrentCharErrorOnLimit(char) then
		self:addCharToStr(str)
		return self:addToken(twoCharToken,str)
	end
	return self:addToken(singleCharToken,str)
end

function Scanner:negativeSign()
	return self:twoCharToken(TokenEnum.Minus, TokenEnum.MinusAssignment,"=")
end

function Scanner:plus()
	return self:twoCharToken(TokenEnum.Plus, TokenEnum.PlusAssignment,"=")
end

function Scanner:slash()
	return self:twoCharToken(TokenEnum.Slash, TokenEnum.SlashAssignment,"=")
end

function Scanner:star()
	return self:twoCharToken(TokenEnum.Star, TokenEnum.StarAssignment,"=")
end

function Scanner:curlyBracket()
    return self:simpleToken(TokenEnum.curlyBracket)
end

function Scanner:closingCurlyBracket()
    return self:simpleToken(TokenEnum.closingCurlyBracket)
end

function Scanner:parenthesis()
    return self:simpleToken(TokenEnum.parenthesis)
end

function Scanner:closingParenthesis()
    return self:simpleToken(TokenEnum.closingParenthesis)
end

function Scanner:closingBracket()
    return self:simpleToken(TokenEnum.closingBracket)
end

function Scanner:colon()
    return self:simpleToken(TokenEnum.colon)
end

function Scanner:semiColon()
    return self:simpleToken(TokenEnum.semiColon)
end

function Scanner:period()
    return self:simpleToken(TokenEnum.period)
end

function Scanner:comma()
    return self:simpleToken(TokenEnum.comma)
end

function Scanner:bang()
    return self:twoCharToken(TokenEnum.Bang, TokenEnum.BangEquals,"=")
end

function Scanner:lessThan()
    return self:twoCharToken(TokenEnum.LessThan, TokenEnum.LessThanEquals,"=")
end

function Scanner:greaterThan()
    return self:twoCharToken(TokenEnum.GreaterThan, TokenEnum.GreaterThanEquals,"=")
end

function Scanner:equal()
    return self:twoCharToken(TokenEnum.Equal, TokenEnum.EqualEquals,"=")
end

local alpha <const> =  {
    ["a"] = true,["A"] = true,["b"] = true,["B"] = true,["c"] = true,["C"] = true,["d"] = true,["D"] = true,["e"] = true,["E"] = true,["f"] = true,["F"] = true,["g"] = true,
    ["G"] = true,["h"] = true,["H"] = true,["i"] = true,["I"] = true,["j"] = true,["J"] = true,["k"] = true,["K"] = true,["l"] = true,["L"] = true,["m"] = true,["M"] = true,
    ["n"] = true,["N"] = true,["o"] = true,["O"] = true,["p"] = true,["P"] = true,["q"] = true,["Q"] = true,["r"] = true,["R"] = true,["s"] = true,["S"] = true,["t"] = true,
    ["T"] = true,["u"] = true,["U"] = true,["v"] = true,["V"] = true,["w"] = true,["W"] = true,["x"] = true,["X"] = true,["y"] = true,["Y"] = true,["z"] = true,["Z"] = true
}

local digits <const> = {
	["0"] = true,
	["1"] = true,
	["2"] = true,
	["3"] = true,
	["4"] = true,
	["5"] = true,
	["6"] = true,
	["7"] = true,
	["8"] = true,
	["9"] = true
}

function Scanner:keywordEnding(str)
	if self:checkCurrentCharMatchTable(alpha) or self:checkCurrentCharMatchTable(digits) or self:checkCurrentChar("_") then
		self:addCharToStr(str)
		return false
	end
	return true
end

function Scanner:scanThroughKeyWord()
	self:setTokenStart()
	local str = {self:consumeCurrentChar()}
	self:loopThroughToken(self.keywordEnding,str)
	return str
end

local function checkKeyword(keyword,str)
	return length(keyword) == #str and keyword == concat(str)
end

function Scanner:checkKeyWord(keyword,keywordType)
	local str <const> = self:scanThroughKeyWord()
	return checkKeyword(keyword,str) and self:addToken(keywordType,str) or self:addToken(TokenEnum.Identifier,str)
end

function Scanner:checkMultipleKeyWords(keyWords)
	local str <const> = self:scanThroughKeyWord()
	for keyword,tokenType in pairs(keyWords) do
		if checkKeyword(keyword,str) then return self:addToken(tokenType,str) end
	end
	return self:addToken(TokenEnum.Identifier,str)
end

function Scanner:loopThroughDigit(str)
	while self:checkCurrentCharMatchTable(digits) do
		self:addCharToStr(str)
	end
	return self
end

function Scanner:digit()
	self:setTokenStart()
	local str <const> = {self:consumeCurrentChar()}
	self:loopThroughDigit(str)
	if(self:checkCurrentChar(".") and self:checkNextCharMatchTable(digits)) then
		self:addCharToStr(str)
	end
	self:loopThroughDigit(str)
	return self:addToken(TokenEnum.Digit,str)
end

function Scanner:scanAnd()
	return self:checkKeyWord("and",TokenEnum.And)
end

function Scanner:class()
    return self:checkKeyWord("class",TokenEnum.Class)
end

function Scanner:scanWhile()
    return self:checkKeyWord("while",TokenEnum.While)
end

function Scanner:scanNil()
    return self:checkKeyWord("nil",TokenEnum.Nil)
end

function Scanner:scanSelf()
    return self:checkKeyWord("self",TokenEnum.Self)
end

function Scanner:scanUntil()
	return self:checkKeyWord("until",TokenEnum.Until)
end

function Scanner:scanLocal()
	return self:checkKeyWord("local",TokenEnum.Local)
end

function Scanner:scanF()
	return self:checkMultipleKeyWords({["for"] = TokenEnum.For,["false"] = TokenEnum.False,["function"] = TokenEnum.Function})
end

function Scanner:scanE()
	return self:checkMultipleKeyWords({["else"] = TokenEnum.Else,["elseif"] = TokenEnum.ElseIf,['end'] = TokenEnum.End})
end

function Scanner:scanR()
	return self:checkMultipleKeyWords({["return"] = TokenEnum.Return,["record"] = TokenEnum.Record,["repeat"] = TokenEnum.Repeat})
end

function Scanner:scanT()
	return self:checkMultipleKeyWords({["true"] = TokenEnum.True,["then"] = TokenEnum.Then})
end

function Scanner:scanC()
	return self:checkMultipleKeyWords({['class'] = TokenEnum.Class,['const'] = TokenEnum.Const})
end

function Scanner:scanI()
	return self:checkMultipleKeyWords(({['if'] = Token.If,['immutable'] = TokenEnum.Immutable}))
end

function Scanner:mutable()
	return self:checkKeyWord("mutable",TokenEnum.Mutable)
end

function Scanner:global()
	return self:checkKeyWord("global",TokenEnum.Global)
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
	["!"] = Scanner.bang,
	["<"] = Scanner.lessThan,
	[">"] = Scanner.greaterThan,
	["="] = Scanner.equal,
	["0"] = Scanner.digit,
	["1"] = Scanner.digit,
	["2"] = Scanner.digit,
	["3"] = Scanner.digit,
	["4"] = Scanner.digit,
	["5"] = Scanner.digit,
	["6"] = Scanner.digit,
	["7"] = Scanner.digit,
	["8"] = Scanner.digit,
	["9"] = Scanner.digit,
	["a"] = Scanner.scanAnd,
	["l"] = Scanner.scanLocal,
	["o"] = Scanner.scanOr,
	["i"] = Scanner.scanI,
	["c"] = Scanner.scanC,
	["w"] = Scanner.scanWhile,
	["t"] = Scanner.scanT,
	["n"] = Scanner.scanNil,
	['u'] = Scanner.scanUntil,
	["s"] = Scanner.scanSelf,
	["f"] = Scanner.scanF,
	["r"] = Scanner.scanR,
	["e"] = Scanner.scanE,
	["g"] = Scanner.global,
	["m"] = Scanner.mutable
}

function Scanner:scanCharArray()
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

function Scanner.scan(charArray)
	return Scanner:new(charArray):scanCharArray()
end

return {scan = Scanner.scan}
