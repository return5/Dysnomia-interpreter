--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local TokenEnum <const> = require('token.TokenEnum')

local setmetatable <const> = setmetatable

local Compiler <const> = {type = "Compiler"}
Compiler.__index = Compiler

_ENV = Compiler


local parseRules <const> = {
	[TokenEnum.Comment] = Compiler. ,
	[TokenEnum.String] = Compiler. ,
	[TokenEnum.Token] = Compiler. ,
	[TokenEnum.Plus] = Compiler. ,
	[TokenEnum.PlusAssignment] = Compiler. ,
	[TokenEnum.Minus] = Compiler. ,
	[TokenEnum.MinusAssignment] = Compiler. ,
	[TokenEnum.Slash] = Compiler. ,
	[TokenEnum.SlashAssignment] = Compiler. ,
	[TokenEnum.Star] = Compiler. ,
	[TokenEnum.StarAssignment] = Compiler. ,
	[TokenEnum.OpenBracket] = Compiler. ,
	[TokenEnum.OpenCurlyBracket] = Compiler. ,
	[TokenEnum.OpenParenthesis] = Compiler. ,
	[TokenEnum.ClosingParenthesis] = Compiler. ,
	[TokenEnum.ClosingBracket] = Compiler. ,
	[TokenEnum.ClosingCurlyBracket] = Compiler. ,
	[TokenEnum.Comma] = Compiler. ,
	[TokenEnum.Colon] = Compiler. ,
	[TokenEnum.SemiColon] = Compiler. ,
	[TokenEnum.Period] = Compiler. ,
	[TokenEnum.Bang] = Compiler. ,
	[TokenEnum.BangEquals] = Compiler. ,
	[TokenEnum.LessThan] = Compiler. ,
	[TokenEnum.LessThanEquals] = Compiler. ,
	[TokenEnum.GreaterThan] = Compiler. ,
	[TokenEnum.GreaterThanEquals] = Compiler. ,
	[TokenEnum.Equal] = Compiler. ,
	[TokenEnum.EqualEquals] = Compiler. ,
	[TokenEnum.Digit] = Compiler. ,
	[TokenEnum.Identifier] = Compiler. ,
	[TokenEnum.And] = Compiler. ,
	[TokenEnum.Or] = Compiler. ,
	[TokenEnum.While] = Compiler. ,
	[TokenEnum.Nil] = Compiler. ,
	[TokenEnum.If] = Compiler. ,
	[TokenEnum.Class] = Compiler. ,
	[TokenEnum.True] = Compiler. ,
	[TokenEnum.Self] = Compiler. ,
	[TokenEnum.Until] = Compiler. ,
	[TokenEnum.Repeat] = Compiler. ,
	[TokenEnum.Return] = Compiler. ,
	[TokenEnum.Record] = Compiler. ,
	[TokenEnum.Else] = Compiler. ,
	[TokenEnum.ElseIf] = Compiler. ,
	[TokenEnum.For] = Compiler. ,
	[TokenEnum.False] = Compiler. ,
	[TokenEnum.End] = Compiler. ,
	[TokenEnum.Function] = Compiler. ,
	[TokenEnum.Then] = Compiler. ,
	[TokenEnum.Local] = Compiler. ,
	[TokenEnum.Const] = Compiler. ,
	[TokenEnum.Mutable] = Compiler. ,
	[TokenEnum.Immutable] = Compiler. ,
	[TokenEnum.Global] = Compiler. ,
	[TokenEnum.Error] = Compiler. ,
	[TokenEnum.Arrow] = Compiler. ,
	[TokenEnum.Do] = Compiler. ,
	[TokenEnum.PoundSign] = Compiler. ,
	[TokenEnum.Metamethod] = Compiler. ,
	[TokenEnum.Method] = Compiler. ,
	[TokenEnum.Super] = Compiler. ,
	[TokenEnum.Inherent] = Compiler. ,
	[TokenEnum.Constructor] = Compiler. ,
	[TokenEnum.Static] = Compiler. ,
}

function Compiler:loopTokens()

end

function Compiler:new(tokens)
	return setmetatable({tokens = tokens},self)
end

function Compiler.compile(tokens)
	return Compiler:new(tokens):loopTokens()
end

return {compile = Compiler.compile}
