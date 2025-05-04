--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local CommentTokenizer <const> = require('tokenizer.comments.CommentTokenizer')
local TokenizerEnums < const> = require('tokenizer.TokenizerEnums')
local setmetatable <const> = setmetatable

local RegularMultiLineCommentTokenizer <const> = {type = TokenizerEnums.RegularMultiLineCommentTokenizer}
RegularMultiLineCommentTokenizer.__index = RegularMultiLineCommentTokenizer
setmetatable(RegularMultiLineCommentTokenizer,CommentTokenizer)

_ENV = RegularMultiLineCommentTokenizer

function RegularMultiLineCommentTokenizer.ending(self,str)
	if self:checkCurrentChar("]") and self:checkNextCharErrorOnLimit("]") then
		self:consumeCurrentCharToStr(str)
		self:consumeCurrentCharToStr(str)
		self:addCommentToken(str)
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

return RegularMultiLineCommentTokenizer
