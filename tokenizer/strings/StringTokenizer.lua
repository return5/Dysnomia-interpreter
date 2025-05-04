local TokenizerEnums <const> = require('tokenizer.TokenizerEnums')
local Tokenizer <const> = require('tokenizer.Tokenizer')
local StringToken <const> = require('tokens.StringToken')

local setmetatable <const> = setmetatable

local StringTokenizer <const> = {type = TokenizerEnums.StringTokenizer}
setmetatable(StringTokenizer,Tokenizer)
StringTokenizer.__index = StringTokenizer

_ENV = StringTokenizer

function StringTokenizer:checkForEndOfString()
	return self:checkCurrentCharErrorOnLimit('"')
end

function StringTokenizer:ending(str)
	if self:checkForEndOfString() then
		self:consumeCurrentCharToStr(str)
		self:addToken(StringToken,str)
		self:incrI()
		return true
	end
	self:consumeCurrentCharToStr(str)
	return false
end

function StringTokenizer:loopOverString(strChar)
	local str <const> = {strChar}
	self:setTokenStart()
	self:incrI()
	self:loop(self.ending,str)
end

function StringTokenizer:tokenizeString(tokenizer)
	self:copyValues(tokenizer)
	self:loopOverString(tokenizer:getCurrentChar())
	tokenizer:copyValues(self)
end

return StringTokenizer
