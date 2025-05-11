--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local Value <const> = require('value.Value')
local ValTypes <const> = require('value.ValueTypesEnum')

local setmetatable <const> = setmetatable

local NumberValue <const> = {type = ValTypes.VAL_NUMBER}
NumberValue.__index = NumberValue

setmetatable(NumberValue,Value)

_ENV = NumberValue

function NumberValue:print()
	return self.as
end

function NumberValue:compare(a)
	return a.type == self.type and a.as == self.as
end

function NumberValue:new(as)
	local o <const> = setmetatable(Value:new(as),self)
	return o
end

return NumberValue
