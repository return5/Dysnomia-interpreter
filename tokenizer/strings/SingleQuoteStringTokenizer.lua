local TokenizerEnums <const> = require('tokenizer.TokenizerEnums')
local StringTokenizer <const> = require('tokenizer.strings.StringTokenizer')

local setmetatable <const> = setmetatable

local SingleQuoteStringTokenizer <const> = {type = TokenizerEnums.SingleQuoteStringTokenizer}
setmetatable(SingleQuoteStringTokenizer,StringTokenizer)
SingleQuoteStringTokenizer.__index = SingleQuoteStringTokenizer

_ENV = SingleQuoteStringTokenizer

function SingleQuoteStringTokenizer:checkForEndOfString()
	return self:checkCurrentCharErrorOnLimit("'")
end

return SingleQuoteStringTokenizer