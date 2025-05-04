--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local Tokenizer <const> = require('tokenizer.Tokenizer')
local TokenizeComment <const> = require('tokenizer.comments.TokenizeComment')
local StringTokenizer <const> = require('tokenizer.strings.StringTokenizer')
local SingleQuoteStringTokenizer <const> = require('tokenizer.strings.SingleQuoteStringTokenizer')
local MultiLineStringTokenizer <const> = require('tokenizer.strings.MultiLineStringTokenizer')
local PlusTokenizer <const> = require('tokenizer.math.PlusTokenizer')
local MinusTokenizer <const> = require('tokenizer.math.MinusTokenizer')
local SlashTokenizer <const> = require('tokenizer.math.SlashTokenizer')
local StarTokenizer <const> = require('tokenizer.math.StarTokenizer')

local FileTokenizer <const> = {}
FileTokenizer.__index = FileTokenizer

_ENV = FileTokenizer


local function checkForComment(tokenizer)
	if tokenizer:checkNextCharErrorOnLimit("-") then
		TokenizeComment.tokenizeComment(tokenizer)
	else
		MinusTokenizer:tokenize(tokenizer)
	end
	return true
end

local function consumeNewLine(tokenizer)
	tokenizer:newLine()
	return true
end

local function checkMultiLineString(tokenizer)
	if tokenizer:checkNextCharErrorOnLimit("[") then
		MultiLineStringTokenizer:tokenizeString(tokenizer)
	else
		tokenizer:consumeCurrentChar() --TODO
	end
	return true
end

local function consumeSpace(tokenizer)
	tokenizer:consumeCurrentChar()
	return true
end

local function plus(tokenizer)
	return PlusTokenizer:tokenize(tokenizer)
end

local function star(tokenizer)
	return StarTokenizer:tokenize(tokenizer)
end

local function slash(tokenizer)
	return SlashTokenizer:tokenize(tokenizer)
end

local charsToTokenize <const> = {
	['-'] = checkForComment,
	["'"] = function(tokenizer) return SingleQuoteStringTokenizer:tokenizeString(tokenizer) end,
	['"'] = function(tokenizer) return StringTokenizer:tokenizeString(tokenizer) end,
	["\n"] = consumeNewLine,
	["["] = checkMultiLineString,
	[' '] = consumeSpace,
	['\t'] = consumeSpace,
	['\r'] = consumeSpace,
	['+'] = plus,
	['/'] = slash,
	['*'] = star
}

function FileTokenizer.tokenizeFile(charArray)
	local tokenizer <const> = Tokenizer:new(charArray)
	while tokenizer.i <= tokenizer.limit do
		local currentChar <const> = tokenizer:getCurrentChar()
		if charsToTokenize[currentChar] then
			charsToTokenize[currentChar](tokenizer)
		else
			tokenizer:consumeCurrentChar()
		end
	end
	return tokenizer.tokens
end

return {tokenize = FileTokenizer.tokenizeFile}
