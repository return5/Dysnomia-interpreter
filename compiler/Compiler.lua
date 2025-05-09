--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local TokenEnum <const> = require('token.TokenEnum')
local Scope <const> = require('compiler.Scope')

local setmetatable <const> = setmetatable

local Compiler <const> = {type = "Compiler"}
Compiler.__index = Compiler

_ENV = Compiler

function Compiler:synchronize()

end

function Compiler:statement()
	if self:checkCurrentToken(TokenEnum.Then) or self:checkCurrentToken(TokenEnum.Do) then
		Scope:beginScope()
		self:block()
		Scope:endScope()
	else

	end

end

function Compiler:declaration()
	if self:checkCurrentToken(TokenEnum.Local) or self:checkCurrentToken(TokenEnum.Global) or self:checkCurrentToken(TokenEnum.Identifier) then
		self:varDeclaration() --TODO
	else
		self:statement()
	end
	if self.panicMode then
		self:synchronize()
	end
end

function Compiler:block()
	while not self:checkCurrentToken(TokenEnum.End) and self:checkLimit() do
		self:declaration()
	end
	self:consumeCurrentToken(TokenEnum.End,"Expected 'end' after block.")
end

function Compiler:checkLimit()
	return self.i <= self.limit
end

function Compiler:checkCurrentToken(type)
	return self:getCurrentToken().type == type
end

function Compiler:getCurrentToken()
	return self.tokens[self.i]
end

function Compiler:consumeCurrentToken()
	local token <const> = self:getCurrentToken()
	self.i = self.i + 1
	return token
end

function Compiler:advance()
	self.previous = self:getCurrentToken()
	while self:checkLimit() and self:consumeCurrentToken().type == TokenEnum.Error do
		self:errorAtCurrent()
	end
	return self
end

function Compiler:loopTokens()
	while self:checkLimit() do
		self:declaration()
	end
	return self
end

function Compiler:new()
	return setmetatable({locals = {},scopeDepth = 1},self)
end

function Compiler:init()
	self.locals = {}
	self.scopeDepth = 1
	Scope:inti()
	return self
end

local compiler <const> = Compiler:new()

function Compiler.compile(tokens)
	return compiler:init(tokens):loopTokens()
end

return {compile = Compiler.compile}
