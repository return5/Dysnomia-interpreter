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
local length <const> = string.len
local pairs <const> = pairs

local setmetatable <const> = setmetatable

local Scanner <const> = {type = "Scanner"}
Scanner.__index = Scanner
_ENV = Scanner


function Scanner:initStr(char)
	self.str[1] = char
	self.strI = 2
	return self
end

function Scanner:incrStrI()
	self.strI = self.strI + 1
	return self
end

function Scanner:truncateStr()
	for i=#self.str,self.strI,-1 do
		self.str[i] = nil
	end
	return self
end

function Scanner:addToStr(char)
	self.str[self.strI] = char
	return self:incrStrI()
end

function Scanner:addToken(type)
	self:truncateStr()
	self.tokenCoord:setEndingValues(self.line,self.currentCol - 1)
	self.tokens[#self.tokens + 1] = Token:new(type,concat(self.str),self.tokenCoord)
	return self
end

function Scanner:errorToken(message)
	self:initStr(message)
	self:truncateStr()
	return self:addToken(TokenEnum.Error)
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

function Scanner:consumeCharToStr()
	return self:addToStr(self:consumeCurrentChar())
end

function Scanner:checkLimit()
	return self.i > self.limit
end

function Scanner:errorOnLimit(i,message)
	if i > self.limit then
		self:errorToken(message)
		return true
	end
	return false
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

function Scanner:singleLineCommentEnding(str)
	if self:checkCurrentChar("\n") then
		self:addToken(TokenEnum.Comment):newLine()
		return true
	end
	if self:checkLimit() then
		self:consumeCharToStr()
		self:addToken(TokenEnum.Comment)
		return true
	end
	self:consumeCharToStr()
	return false
end

function Scanner:multiLineCommentEqualSignsEnding()
	if self.runningCount == self.endingCount and self:checkCurrentChar("]") then
		self:consumeCharToStr()
		self:addToken(TokenEnum.Comment)
		return true
	elseif self.runningCount > 0 and self:checkCurrentChar("=") then
		self:consumeCharToStr()
		self.runningCount = self.runningCount + 1
	elseif self:errorOnLimit(self.i,"reached end of file looking for ending of comment.") then
		self:incrI()
		return true
	elseif self:checkCurrentChar("]") and self:checkNextChar("=") then
		self:consumeCharToStr()
		self:consumeCharToStr()
		self.runningCount = self.runningCount + 1
	else
		if self:checkCurrentChar("\n") then
			self:consumeCharToStr()
			self:newLine()
		else
			self:consumeCharToStr()
		end
		self.runningCount = 0
	end
	return false
end

function Scanner:multiLineCommentEnding()
	if self:checkCurrentChar("]") and self:checkNextChar("]") then
		self:consumeCharToStr()
		self:consumeCharToStr()
		self:addToken(TokenEnum.Comment)
		self:incrI()
		return true
	end
	if self:errorOnLimit(self.i,"reached end of file looking for ']'") then self:incrI() return true end
	if self:checkCurrentChar("\n") then
		self:consumeCharToStr()
		self:newLine()
	else
		self:consumeCharToStr()
	end
	return false
end

function Scanner:countMultiLineCommentEqualSigns(str)
	self:consumeCharToStr()
	self.endingCount = 1
	self.runningCount = 0
	while self:checkCurrentChar("=") do
		self:consumeCharToStr()
		self.endingCount = self.endingCount + 1
	end
	if self:checkCurrentChar("[") then return self.multiLineCommentEqualSignsEnding end
	return self.singleLimeCommentTokenizer
end

--checking for multi line comments such as --[[ and --[=[
function Scanner:getMultiLineCommentEnding()
	self:consumeCharToStr()
	if self:checkCurrentChar("[") then
		self:consumeCharToStr()
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
	self:initStr(self:consumeCurrentChar())
	self:addToStr(self:consumeCurrentChar())
	local commentEnding <const> = self:getCommentEndingFunc()
	return self:loopThroughToken(commentEnding,self.str)
end

function Scanner:arrow()
	self:setTokenStart()
	self:initStr(self:consumeCurrentChar())
	self:consumeCharToStr()
	return self:addToken(TokenEnum.Arrow,self.str)
end

function Scanner:checkForMultipleTokens(tokens,default)
	for char,func in pairs(tokens) do
		if self:checkNextChar(char) then
			return func(self)
		end
	end
	return default(self)
end

function Scanner:hyphen()
	return self:checkForMultipleTokens({['-'] = Scanner.scanComment,['>'] = Scanner.arrow},Scanner.minus)
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
	self:initStr("")
	return self:loopThroughToken(strEnding,str)
end

local function stringEnding(char,ending)
	return function(self,str)
		if self:checkCurrentChar(char) and not self:checkPreviousChar("\\") then
			self:addToken(TokenEnum.String)
			self:incrI()
			return true
		end
		if self:errorOnLimit(self.i,"reached end of file looking for closing " .. ending) then self:incrI() return true end
		self:consumeCharToStr(str)
		return false
	end
end

function Scanner:singleQuote()
	return self:scanString(stringEnding("'",[["'"]]))
end

function Scanner:doubleQuote()
	return self:scanString(stringEnding('"',[['"']]))
end

function Scanner:multiLineStringEnding(str)
	if self:checkCurrentChar("]") and not self:checkPreviousChar("%") and self:checkNextChar("]") then
		self:addToken(TokenEnum.String)
		self:incrI():incrI()
		return true
	end
	if self:errorOnLimit(self.i,"reached end of file while searching for closing ']'") then self:incrI() return true end
	self:consumeCharToStr(str)
	return false
end

function Scanner:multiLineString()
	return self:scanString(Scanner.multiLineStringEnding)
end

function Scanner:simpleToken(type)
	self:setTokenStart()
	self:initStr(self:consumeCurrentChar())
	return self:addToken(type):incrStrI()
end

function Scanner:bracket()
	if self:checkNextChar('[') then
		return self:incrI():multiLineString()
	end
	return self:simpleToken(TokenEnum.OpenBracket)
end

function Scanner:curlyBracket()
	return self:simpleToken(TokenEnum.OpenCurlyBracket)
end

function Scanner:twoCharToken(singleCharToken,twoCharToken,char)
	self:setTokenStart()
	self:initStr(self:consumeCurrentChar())
	if self:checkCurrentChar(char) then
		self:consumeCharToStr()
		return self:addToken(twoCharToken)
	end
	return self:addToken(singleCharToken)
end

function Scanner:minus()
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

function Scanner:closingCurlyBracket()
    return self:simpleToken(TokenEnum.ClosingCurlyBracket)
end

function Scanner:parenthesis()
    return self:simpleToken(TokenEnum.OpenParenthesis)
end

function Scanner:closingParenthesis()
    return self:simpleToken(TokenEnum.ClosingParenthesis)
end

function Scanner:closingBracket()
    return self:simpleToken(TokenEnum.ClosingBracket)
end

function Scanner:colon()
	return self:twoCharToken(TokenEnum.Colon,TokenEnum.Inherent,">")
end

function Scanner:semiColon()
    return self:simpleToken(TokenEnum.SemiColon)
end

function Scanner:period()
    return self:simpleToken(TokenEnum.Period)
end

function Scanner:comma()
    return self:simpleToken(TokenEnum.Comma)
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
    ["a"] = true,["A"] = true,["b"] = true,["B"] = true,["c"] = true,["C"] = true,["d"] = true,["D"] = true,["e"] = true,
    ["E"] = true,["f"] = true,["F"] = true,["g"] = true, ["G"] = true,["h"] = true,["H"] = true,["i"] = true,["I"] = true,
    ["j"] = true,["J"] = true,["k"] = true,["K"] = true,["l"] = true,["L"] = true,["m"] = true,["M"] = true,["n"] = true,
    ["N"] = true,["o"] = true,["O"] = true,["p"] = true,["P"] = true,["q"] = true,["Q"] = true,["r"] = true,["R"] = true,
    ["s"] = true,["S"] = true,["t"] = true, ["T"] = true,["u"] = true,["U"] = true,["v"] = true,["V"] = true,["w"] = true,
    ["W"] = true,["x"] = true,["X"] = true,["y"] = true,["Y"] = true,["z"] = true,["Z"] = true
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

function Scanner:keywordEnding()
	if self:checkLiteral() then
		self:consumeCharToStr()
		return false
	end
	return true
end

function Scanner:scanThroughKeyWord()
	self:setTokenStart()
	self:initStr(self:consumeCurrentChar())
	self:loopThroughToken(self.keywordEnding)
	return self
end

function Scanner:checkKeyword(keyword)
	return length(keyword) == self.strI - 1 and keyword == concat(self.str)
end

function Scanner:checkKeyWord(keyword,keywordType)
	self:scanThroughKeyWord()
	self:truncateStr()
	return self:checkKeyword(keyword) and self:addToken(keywordType) or self:addToken(TokenEnum.Identifier)
end

function Scanner:checkMultipleKeyWords(keyWords)
	self:scanThroughKeyWord()
	for keyword,tokenType in pairs(keyWords) do
		if self:checkKeyword(keyword) then return self:addToken(tokenType) end
	end
	return self:addToken(TokenEnum.Identifier)
end

function Scanner:loopThroughDigit()
	while self:checkCurrentCharMatchTable(digits) do
		self:consumeCharToStr()
	end
	return self
end

function Scanner:digit()
	self:setTokenStart()
	self:initStr(self:consumeCurrentChar())
	self:loopThroughDigit()
	if(self:checkCurrentChar(".") and self:checkNextCharMatchTable(digits)) then
		self:consumeCharToStr()
	end
	self:loopThroughDigit()
	return self:addToken(TokenEnum.Digit)
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
	return self:checkMultipleKeyWords({['class'] = TokenEnum.Class,['const'] = TokenEnum.Const,['constructor'] = TokenEnum.Constructor})
end

function Scanner:scanS()
	return self:checkMultipleKeyWords({["self"] = TokenEnum.Self,['super'] = TokenEnum.Super,['static'] = TokenEnum.Static})
end

function Scanner:scanI()
	return self:checkMultipleKeyWords(({['if'] = Token.If,['immutable'] = TokenEnum.Immutable}))
end

function Scanner:scanM()
	return self:checkMultipleKeyWords({["mutable"] = TokenEnum.Mutable,['metamethod'] = TokenEnum.Metamethod,['method'] = TokenEnum.method})
end

function Scanner:global()
	return self:checkKeyWord("global",TokenEnum.Global)
end

function Scanner:scanDo()
	return self:checkKeyWord("do",TokenEnum.Do)
end

function Scanner:checkLiteral()
	return not self:checkLimit() and self:checkCurrentCharMatchTable(alpha) or self:checkCurrentCharMatchTable(digits) or self:checkCurrentChar("_")
end

function Scanner:scanPoundSign()
	return self:simpleToken(TokenEnum.PoundSign)
end

function Scanner:literalEnding()
	if self:checkLiteral() then
		self:consumeCharToStr()
		return false
	end
	return true
end

function Scanner:literal()
	self:setTokenStart()
	self:initStr(self:consumeCurrentChar())
	self:loopThroughToken(self.literalEnding)
	self:addToken(TokenEnum.Identifier)
	return self
end

local charsToTokenize <const> = {
	['-'] = Scanner.hyphen,
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
	["s"] = Scanner.scanS,
	["f"] = Scanner.scanF,
	["r"] = Scanner.scanR,
	["e"] = Scanner.scanE,
	["g"] = Scanner.global,
	["m"] = Scanner.scanM,
	['d'] = Scanner.scanDo,
	["#"] = Scanner.scanPoundSign
}

function Scanner:scanCharArray()
	repeat
		local currentChar <const> = self:getCurrentChar()
		if charsToTokenize[currentChar] then
			charsToTokenize[currentChar](self)
		elseif self:checkLiteral() then
			self:literal()
		else
			self:errorToken("unexpected character encountered."):incrI()
		end
	until self:checkLimit()
	return self.tokens
end

function Scanner:new()
	return setmetatable({charArray = {},tokens = {},str = {},strI = 1,i = 1, limit = 1,currentCol = 1,tokenCoord = TokenCoords:new(),line = 1},self)
end

function Scanner:init(charArray)
	self.charArray = charArray
	self.tokens = {}
	self.strI = 1
	self.i = 1
	self. limit = #charArray
	self.currentCol = 1
	self.line = 1
	return self
end

local scanner <const> = Scanner:new()

function Scanner.scan(charArray)
	return scanner:init(charArray):scanCharArray()
end

return {scan = Scanner.scan}
