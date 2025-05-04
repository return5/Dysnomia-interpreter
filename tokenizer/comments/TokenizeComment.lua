
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
	return TokenizeComment.countCommentEndingChars(str,tokenizer)
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
