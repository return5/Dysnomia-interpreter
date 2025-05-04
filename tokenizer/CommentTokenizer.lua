
--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local TokenizerEnums <const> = require('tokenizer.TokenizerEnums')
local Tokenizer <const> = require('tokenizer.Tokenizer')
local CommentToken <const> = require('tokens.CommentToken')

local setmetatable <const> = setmetatable
local concat <const> = table.concat

local CommentTokenizer <const> = {type = TokenizerEnums.CommentTokenizer}
setmetatable(CommentTokenizer,Tokenizer)
CommentTokenizer.__index = CommentTokenizer

_ENV = CommentTokenizer

function CommentTokenizer.regularMultiLineComment(self,str)
	if self:checkCurrentChar("]") and self:checkNextCharErrorOnLimit("]") then
		self:consumeCurrentCharToStr(str)
		self:consumeCurrentCharToStr(str)
		self:addToken(CommentToken,str)
		self:incrI()
		return true
	end
	if self:checkCurrentChar("\n") then
		self:addCurrentCharToStr(str)
		self:newLine()
	else
		self:consumeCurrentCharToStr(str)
	end
	return false
end

local function multiLineCommentEqualSignClosure(endingCount)
	local runningCount = 0
	return function(self,str)
		if runningCount == endingCount and self:checkCurrentCharErrorOnLimit("]") then
			self:consumeCurrentCharToStr(str)
			self:consumeCurrentCharToStr(str)
			self:addToken(CommentToken,str)
			return true
		elseif runningCount > 0 and self:checkCurrentCharErrorOnLimit("=") then
			self:consumeCurrentCharToStr(str)
			runningCount = runningCount + 1
		elseif self:checkCurrentChar("]") and self:checkNextCharErrorOnLimit("=") then
			self:consumeCurrentCharToStr(str)
			self:consumeCurrentCharToStr(str)
			runningCount = runningCount + 1
		else
			if self:checkCurrentChar("\n") then
				self:addCurrentCharToStr(str)
				self:newLine()
			else
				self:consumeCurrentCharToStr(str)
			end
			runningCount = 0
		end
		return false
	end
end

function CommentTokenizer:countMultiLineCommentEqualSigns(str)
	self:consumeCurrentCharToStr(str)
	local endingCount = 1
	while self:checkCurrentChar("=") do
		self:consumeCurrentCharToStr(str)
		endingCount = endingCount + 1
	end
	if self:checkCurrentChar("[") then return multiLineCommentEqualSignClosure(endingCount) end
	return CommentTokenizer.singleLineComment
end

--checking for multi line comments such as --[[ and --[=[
function CommentTokenizer:countCommentEndingChars(str)
	self:consumeCurrentCharToStr(str)
	if self:checkCurrentChar("[") then
		self:consumeCurrentCharToStr(str)
		return CommentTokenizer.regularMultiLineComment
	end
	if self:checkCurrentChar("=") then return self:countMultiLineCommentEqualSigns(str) end
	return CommentTokenizer.singleLineComment
end

function CommentTokenizer.singleLineComment(self,str)
	if self:checkCurrentChar("\n") or self.i >= self.limit then
		self:consumeCurrentCharToStr(str)
		self:addToken(CommentToken,str)
		return true
	end
	self:consumeCurrentCharToStr(str)
	return false
end

function CommentTokenizer:getCommentEnding(str)
	if not self:checkCurrentChar("[") then return CommentTokenizer.singleLineComment end
	return self:countCommentEndingChars(str)
end

function CommentTokenizer:loopOverComment()
	local str <const> = {'--'}
	self:setTokenStart()
	self:incrI():incrI()
	local ending <const> = self:getCommentEnding(str)
	self:loop(ending,str)
end

function CommentTokenizer:tokenizeComment(tokenizer)
	CommentTokenizer:copyValues(tokenizer)
	CommentTokenizer:loopOverComment()
	tokenizer:copyValues(CommentTokenizer)
end

return CommentTokenizer
