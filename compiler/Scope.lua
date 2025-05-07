--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local Scope <Const> = {type = "Scope",depth = 1}
Scope.__index = Scope

_ENV = Scope


function Scope:beginScope()
	self.depth = self.depth + 1
	return self
end

function Scope:endScope()
	self.depth = self.depth - 1
	return self
end


function Scope:init()
	self.depth = 1
	return self
end

return Scope
