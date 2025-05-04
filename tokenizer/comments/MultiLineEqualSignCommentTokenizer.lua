--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local CommentTokenizer <const> = require('tokenizer.comments.CommentTokenizer')
local TokenizerEnums < const> = require('tokenizer.TokenizerEnums')
local setmetatable <const> = setmetatable

local MultiLineEqualSignCommentTokenizer <const> = {type = TokenizerEnums.MultiLineEqualSignCommentTokenizer,endingCount = -1, runningCount = 0}
MultiLineEqualSignCommentTokenizer.__index = MultiLineEqualSignCommentTokenizer
setmetatable(MultiLineEqualSignCommentTokenizer,CommentTokenizer)

_ENV = MultiLineEqualSignCommentTokenizer

function MultiLineEqualSignCommentTokenizer.ending(self,str)
	if self.runningCount == self.endingCount and self:checkCurrentCharErrorOnLimit("]") then
		self:consumeCurrentCharToStr(str)
		self:consumeCurrentCharToStr(str)
		self:addCommentToken(str)
		return true
	elseif self.runningCount > 0 and self:checkCurrentCharErrorOnLimit("=") then
		self:consumeCurrentCharToStr(str)
		self.runningCount = self.runningCount + 1
	elseif self:checkCurrentChar("]") and self:checkNextCharErrorOnLimit("=") then
		self:consumeCurrentCharToStr(str)
		self:consumeCurrentCharToStr(str)
		self.runningCount = self.runningCount + 1
	else
		if self:checkCurrentChar("\n") then
			self:addCurrentCharToStr(str)
			self:newLine()
		else
			self:consumeCurrentCharToStr(str)
		end
		self.runningCount = 0
	end
	return false
end

function MultiLineEqualSignCommentTokenizer.singleton(endingCount)
	MultiLineEqualSignCommentTokenizer.runningCount = 0
	MultiLineEqualSignCommentTokenizer.endingCount = endingCount
	return MultiLineEqualSignCommentTokenizer
end

return MultiLineEqualSignCommentTokenizer
