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

function Compiler:comment()

end

function Compiler:string()

end

function Compiler:token()

end

function Compiler:plus()

end

function Compiler:plusAssignment()

end

function Compiler:minus()

end

function Compiler:minusAssignment()

end

function Compiler:slash()

end

function Compiler:slashAssignment()

end

function Compiler:star()

end

function Compiler:starAssignment()

end

function Compiler:openBracket()

end

function Compiler:openCurlyBracket()

end

function Compiler:openParenthesis()

end

function Compiler:closingParenthesis()

end

function Compiler:closingBracket()

end

function Compiler:closingCurlyBracket()

end

function Compiler:comma()

end

function Compiler:colon()

end

function Compiler:semiColon()

end

function Compiler:period()

end

function Compiler:bang()

end

function Compiler:bangEquals()

end

function Compiler:lessThan()

end

function Compiler:lessThanEquals()

end

function Compiler:greaterThan()

end

function Compiler:greaterThanEquals()

end

function Compiler:equal()

end

function Compiler:equalEquals()

end

function Compiler:digit()

end

function Compiler:identifier()

end

function Compiler:class()

end

function Compiler:compileAnd()

end

function Compiler:compileOr()

end

function Compiler:compileWhile()

end

function Compiler:compileNil()

end

function Compiler:compileIf()

end

function Compiler:compileTrue()

end

function Compiler:compileSelf()

end

function Compiler:compileUntil()

end

function Compiler:compileRepeat()

end

function Compiler:compileReturn()

end

function Compiler:compileElse()

end

function Compiler:compileFor()

end

function Compiler:compileEnd()

end

function Compiler:compileFalse()

end

function Compiler:compileFunction()

end

function Compiler:compileDo()

end

function Compiler:compileError()

end

function Compiler:compileThen()

end

function Compiler:compileLocal()

end

function Compiler:elseIf()

end

function Compiler:record()

end

function Compiler:const()

end

function Compiler:mutable()

end

function Compiler:immutable()

end

function Compiler:global()

end

function Compiler:arrow()

end

function Compiler:poundSign()

end

function Compiler:metamethod()

end

function Compiler:method()

end

function Compiler:super()

end

function Compiler:inherent()

end

function Compiler:constructor()

end

function Compiler:static()

end

local parseRules <const> = {
	[TokenEnum.Comment] = Compiler.comment,
	[TokenEnum.String] = Compiler.string,
	[TokenEnum.Token] = Compiler.token,
	[TokenEnum.Plus] = Compiler.plus,
	[TokenEnum.PlusAssignment] = Compiler.plusAssignment,
	[TokenEnum.Minus] = Compiler.minus,
	[TokenEnum.MinusAssignment] = Compiler.minusAssignment,
	[TokenEnum.Slash] = Compiler.slash,
	[TokenEnum.SlashAssignment] = Compiler.slashAssignment,
	[TokenEnum.Star] = Compiler.star,
	[TokenEnum.StarAssignment] = Compiler.starAssignment,
	[TokenEnum.OpenBracket] = Compiler.openBracket,
	[TokenEnum.OpenCurlyBracket] = Compiler.openCurlyBracket,
	[TokenEnum.OpenParenthesis] = Compiler.openParenthesis,
	[TokenEnum.ClosingParenthesis] = Compiler.closingParenthesis,
	[TokenEnum.ClosingBracket] = Compiler.closingBracket,
	[TokenEnum.ClosingCurlyBracket] = Compiler.closingCurlyBracket,
	[TokenEnum.Comma] = Compiler.comma,
	[TokenEnum.Colon] = Compiler.colon,
	[TokenEnum.SemiColon] = Compiler.semiColon,
	[TokenEnum.Period] = Compiler.period,
	[TokenEnum.Bang] = Compiler.bang,
	[TokenEnum.BangEquals] = Compiler.bangEquals,
	[TokenEnum.LessThan] = Compiler.lessThan,
	[TokenEnum.LessThanEquals] = Compiler.lessThanEquals,
	[TokenEnum.GreaterThan] = Compiler.greaterThan,
	[TokenEnum.GreaterThanEquals] = Compiler.greaterThanEquals,
	[TokenEnum.Equal] = Compiler.equal,
	[TokenEnum.EqualEquals] = Compiler.equalEquals,
	[TokenEnum.Digit] = Compiler.digit,
	[TokenEnum.Identifier] = Compiler.identifier,
	[TokenEnum.Class] = Compiler.class,
	[TokenEnum.And] = Compiler.compileAnd,
	[TokenEnum.Or] = Compiler.compileOr,
	[TokenEnum.While] = Compiler.compileWhile,
	[TokenEnum.Nil] = Compiler.compileNil,
	[TokenEnum.If] = Compiler.compileIf,
	[TokenEnum.True] = Compiler.compileTrue,
	[TokenEnum.Self] = Compiler.compileSelf,
	[TokenEnum.Until] = Compiler.compileUntil,
	[TokenEnum.Repeat] = Compiler.compileRepeat,
	[TokenEnum.Return] = Compiler.compileReturn,
	[TokenEnum.Else] = Compiler.compileElse,
	[TokenEnum.For] = Compiler.compileFor,
	[TokenEnum.End] = Compiler.compileEnd,
	[TokenEnum.False] = Compiler.compileFalse,
	[TokenEnum.Function] = Compiler.compileFunction,
	[TokenEnum.Do] = Compiler.compileDo,
	[TokenEnum.Error] = Compiler.compileError,
	[TokenEnum.Then] = Compiler.compileThen,
	[TokenEnum.Local] = Compiler.compileLocal,
	[TokenEnum.ElseIf] = Compiler.elseIf,
	[TokenEnum.Record] = Compiler.record,
	[TokenEnum.Const] = Compiler.const,
	[TokenEnum.Mutable] = Compiler.mutable,
	[TokenEnum.Immutable] = Compiler.immutable,
	[TokenEnum.Global] = Compiler.global,
	[TokenEnum.Arrow] = Compiler.arrow,
	[TokenEnum.PoundSign] = Compiler.poundSign,
	[TokenEnum.Metamethod] = Compiler.metamethod,
	[TokenEnum.Method] = Compiler.method,
	[TokenEnum.Super] = Compiler.super,
	[TokenEnum.Inherent] = Compiler.inherent,
	[TokenEnum.Constructor] = Compiler.constructor,
	[TokenEnum.Static] = Compiler.static,
}

function Compiler:checkLimit()
	return self.i <= self.limit
end

function Compiler:getCurrentToken()
	return self.tokens[self.i]
end

function Compiler:advance()
	self.i = self.i + 1
	return self
end

function Compiler:loopTokens()
	while self:checkLimit() do
		parseRules[self:getCurrentToken().type](self)
		self:advance()
	end
	return self
end

function Compiler:new()
	return setmetatable({tokens = {},i = 1,limit = 1},self)
end

function Compiler:init(tokens)
	self.tokens = tokens
	self.i = 1
	self.limit = #tokens
	return self
end

local compiler <const> = Compiler:new()

function Compiler.compile(tokens)
	return compiler:init(tokens):loopTokens()
end

return {compile = Compiler.compile}
