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

local CommentTokenizer <const> = {type = TokenizerEnums.CommentTokenizer}
setmetatable(CommentTokenizer,Tokenizer)
CommentTokenizer.__index = CommentTokenizer

_ENV = CommentTokenizer


function CommentTokenizer:addCommentToken(str)
	self:addCurrentCharToStr(str)
	self:addToken(CommentToken,str)
	return self
end

return CommentTokenizer
