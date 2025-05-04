--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local SingleLimeCommentTokenizer <const> = require('tokenizer.comments.SingleLineCommentTokenizer')
local RegularMultiLineCommentTokenizer <const> = require('tokenizer.comments.RegularMultiLineCommentTokenizer')
local MultiLineEqualSignCommentTokenizer <const> = require('tokenizer.comments.MultiLineEqualSignCommentTokenizer')

local TokenizeComment <const> = {}
TokenizeComment.__index = TokenizeComment

_ENV = TokenizeComment

function TokenizeComment.countMultiLineCommentEqualSigns(tokenizer,str)
	tokenizer:consumeCurrentCharToStr(str)
	local endingCount = 1
	while tokenizer:checkCurrentChar("=") do
		tokenizer:consumeCurrentCharToStr(str)
		endingCount = endingCount + 1
	end
	if tokenizer:checkCurrentChar("[") then return MultiLineEqualSignCommentTokenizer.singleton(endingCount) end
	return SingleLimeCommentTokenizer
end

--checking for multi line comments such as --[[ and --[=[
function TokenizeComment.countCommentEndingChars(tokenizer,str)
	tokenizer:consumeCurrentCharToStr(str)
	if tokenizer:checkCurrentChar("[") then
		tokenizer:consumeCurrentCharToStr(str)
		return RegularMultiLineCommentTokenizer
	end
	if tokenizer:checkCurrentChar("=") then return TokenizeComment.countMultiLineCommentEqualSigns(tokenizer,str) end
	return SingleLimeCommentTokenizer
end

function TokenizeComment.getTokenizer(tokenizer,str)
	if not tokenizer:checkCurrentChar("[") then return SingleLimeCommentTokenizer end
	return TokenizeComment.countCommentEndingChars(tokenizer,str)
end

function TokenizeComment.tokenizeComment(tokenizer)
	local str <const> = {'--'}
	tokenizer:setTokenStart()
	tokenizer:incrI():incrI()
	local commentTokenizer <const> = TokenizeComment.getTokenizer(tokenizer,str)
	commentTokenizer:copyValues(tokenizer)
	commentTokenizer:loop(commentTokenizer.ending,str)
	tokenizer:copyValues(commentTokenizer)
	return true
end

return TokenizeComment
