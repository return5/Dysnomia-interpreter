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
local write <const> = io.write

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

function Scanner:makeToken(type)
	self:truncateStr()
	self.tokenCoord:setEndingValues(self.line,self.currentCol - 1)
	return Token:new(type,concat(self.str),self.tokenCoord)
end

function Scanner:errorToken(message)
	self:initStr(message)
	self:truncateStr()
	return self:makeToken(TokenEnum.Error)
end

function Scanner:advance()
	self.i = self:incrStrI()
	return self.charArray[self.i - 1]
end

function Scanner:getNextChar()
	return self.charArray[self.i]
end

function Scanner:checkCurrentCharMatchTable(tbl)
	return tbl[self.current]
end

function Scanner:checkNextCharMatchTable(tbl)
	return tbl[self:getNextChar()]
end

function Scanner:checkNextChar(char)
	return self.charArray[self.i] == char
end

function Scanner:checkCurrentChar(char)
	return self.current == char
end

function Scanner:checkPreviousChar(char)
	return self.charArray[self.i - 1] == char
end

function Scanner:consumeCharToStr()
	return self:addToStr(self:advance())
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
	return self:incrLine()
end

function Scanner:singleLineCommentEnding()
	if self:checkCurrentChar("\n") then
		return self:makeToken(TokenEnum.Comment):newLine()
	end
	if self:checkLimit() then
		self:consumeCharToStr()
		return self:makeToken(TokenEnum.Comment)
	end
	self:consumeCharToStr()
	return false
end

function Scanner:multiLineCommentEqualSignsEnding()
	if self.runningCount == self.endingCount and self:checkCurrentChar("]") then
		self:consumeCharToStr()
		return self:makeToken(TokenEnum.Comment)
	elseif self.runningCount > 0 and self:checkCurrentChar("=") then
		self:consumeCharToStr()
		self.runningCount = self.runningCount + 1
	elseif self:checkLimit() then
		local token <const> = self:errorToken("Reached end of file while looking for ending of comment.")
		self:incrI()
		return token
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
		local token <const> = self:makeToken(TokenEnum.Comment)
		self:incrI()
		return token
	end
	if self:checkLimit() then return self:errorToken("reached end of file looking for ']'") end
	if self:checkCurrentChar("\n") then
		self:consumeCharToStr()
		self:newLine()
	else
		self:consumeCharToStr()
	end
	return false
end

function Scanner:countMultiLineCommentEqualSigns()
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
	if self:checkCurrentChar("=") then return self:countMultiLineCommentEqualSigns() end
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
	self:initStr(self:advance())
	self:addToStr(self:advance())
	local commentEnding <const> = self:getCommentEndingFunc()
	return self:loopThroughToken(commentEnding,self.str)
end

function Scanner:arrow()
	self:setTokenStart()
	self:initStr(self:advance())
	self:consumeCharToStr()
	return self:makeToken(TokenEnum.Arrow,self.str)
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

function Scanner:loopThroughToken(ending)
	local token = ending(self)
	while not token do
		token = ending(self)
	end
	return token
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
	return self:loopThroughToken(strEnding)
end

local function stringEnding(char,ending)
	return function(self)
		if self:checkCurrentChar(char) and not self:checkPreviousChar("\\") then
			return self:makeToken(TokenEnum.String)
		end
		if self:checkError() then return self:errorToken("reached end of file looking for closing " .. ending) end
		self:consumeCharToStr()
		return false
	end
end

function Scanner:singleQuote()
	return self:scanString(stringEnding("'",[["'"]]))
end

function Scanner:doubleQuote()
	return self:scanString(stringEnding('"',[['"']]))
end

function Scanner:multiLineStringEnding()
	if self:checkCurrentChar("]") and not self:checkPreviousChar("%") and self:checkNextChar("]") then
		self:incrI()
		return self:makeToken(TokenEnum.String)
	end
	if self:checkLimit() then return self:errorToken("reached end of file while searching for closing ']'") end
	self:consumeCharToStr()
	return false
end

function Scanner:multiLineString()
	return self:scanString(Scanner.multiLineStringEnding)
end

function Scanner:simpleToken(type)
	self:setTokenStart()
	self:initStr(self:advance())
	return self:makeToken(type)
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
	self:initStr(self:advance())
	if self:checkCurrentChar(char) then
		self:consumeCharToStr()
		return self:makeToken(twoCharToken)
	end
	return self:makeToken(singleCharToken)
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
	self:initStr(self:advance())
	self:loopThroughToken(self.keywordEnding)
	return self
end

function Scanner:checkKeyWordMatch(keyword)
	return length(keyword) == self.strI - 1 and keyword == concat(self.str)
end

function Scanner:checkKeyWord(keyword,keywordType)
	self:scanThroughKeyWord()
	self:truncateStr()
	return self:checkKeyWordMatch(keyword) and self:makeToken(keywordType) or self:makeToken(TokenEnum.Identifier)
end

function Scanner:checkMultipleKeyWords(keyWords)
	self:scanThroughKeyWord()
	self:truncateStr()
	for keyword,tokenType in pairs(keyWords) do
		if self:checkKeyWordMatch(keyword) then return self:makeToken(tokenType) end
	end
	return self:makeToken(TokenEnum.Identifier)
end

function Scanner:loopThroughDigit()
	while self:checkCurrentCharMatchTable(digits) do
		self:consumeCharToStr()
	end
	return self
end

function Scanner:digit()
	self:setTokenStart()
	self:initStr(self:advance())
	self:loopThroughDigit()
	if(self:checkCurrentChar(".") and self:checkNextCharMatchTable(digits)) then
		self:consumeCharToStr()
	end
	self:loopThroughDigit()
	return self:makeToken(TokenEnum.Digit)
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

function Scanner:scanOr()
	return self:checkKeyWord("or",TokenEnum.Or)
end

function Scanner:record()
	return self:checkKeyWord("Record",TokenEnum.Record)
end

function Scanner:scanF()
	return self:checkMultipleKeyWords({["for"] = TokenEnum.For,["false"] = TokenEnum.False,["function"] = TokenEnum.Function})
end

function Scanner:scanE()
	return self:checkMultipleKeyWords({["else"] = TokenEnum.Else,["elseif"] = TokenEnum.ElseIf,['end'] = TokenEnum.End})
end

function Scanner:scanR()
	return self:checkMultipleKeyWords({["return"] = TokenEnum.Return,["repeat"] = TokenEnum.Repeat})
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
	return self:checkMultipleKeyWords(({['if'] = TokenEnum.If,['immutable'] = TokenEnum.Immutable}))
end

function Scanner:scanM()
	return self:checkMultipleKeyWords({["mutable"] = TokenEnum.Mutable,['metamethod'] = TokenEnum.Metamethod,['method'] = TokenEnum.Method})
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
	self:initStr(self:advance())
	self:loopThroughToken(self.literalEnding)
	return self:makeToken(TokenEnum.Identifier)
end

local charsToTokenize <const> = {
	['-'] = Scanner.hyphen,
	["'"] = Scanner.singleQuote,
	['"'] = Scanner.doubleQuote,
	["["] = Scanner.bracket,
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
	["#"] = Scanner.scanPoundSign,
	["R"] = Scanner.record
}

local whiteSpaces <const> = {
	[' '] = true,
	['\t'] = true,
	['\r'] = true,
	[""] = true
}

function Scanner:skipOverWhiteSpace()
	while true do
		if self:checkLimit() then return self end
		if self:checkCurrentCharMatchTable(whiteSpaces) then
			self:advance()
		elseif self:checkCurrentChar("\n") then
			self:newLine():advance()
		else
			return self
		end
	end
end

function Scanner:scanToken()
	self:skipOverWhiteSpace()
	if self:checkLimit() then
		return self:makeToken(TokenEnum.EOF)
	end
	self.currentChar = self:advance()
	if charsToTokenize[self.currentChar] then
		return charsToTokenize[self.currentChar](self)
	elseif self:checkLiteral() then
		return self:literal()
	else
		return self:errorToken("unexpected character encountered.")
	end
end

function Scanner:new()
	return setmetatable({charArray = {},current = "",tokens = {},str = {},strI = 1,i = 1, limit = 1,currentCol = 1,tokenCoord = TokenCoords:new(),line = 1},self)
end

local scanner <const> = Scanner:new()

function Scanner.init(charArray)
	scanner.charArray = charArray
	scanner.currentChar = ""
	scanner.strI = 1
	scanner.i = 1
	scanner. limit = #charArray
	scanner.currentCol = 1
	scanner.line = 1
	return scanner
end

return {scanToken = Scanner.scanToken,init = Scanner.init}
