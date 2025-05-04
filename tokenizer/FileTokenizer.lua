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

local FileTokenizer <const> = {}
FileTokenizer.__index = FileTokenizer

_ENV = FileTokenizer


local function checkForComment(tokenizer)
	if tokenizer:checkNextCharErrorOnLimit("-") then
		TokenizeComment.tokenizeComment(tokenizer)
	else
		tokenizer:consumerCurrentChar() --TODO
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
		tokenizer:consumerCurrentChar() --TODO
	end
	return true
end

local function consumeSpace(tokenizer)
	tokenizer:consumeCurrentChar()
	return true
end

local function add(tokenizer)
	return PlusTokenizer:tokenizePlus(tokenizer)
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
	['+'] = add,
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
