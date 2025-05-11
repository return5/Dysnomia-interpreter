--[[
    This file is part of Dysnomia interpreter.

    Dysnomia Interpreter is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License only.

    Dysnomia Interpreter is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with Dysnomia Interpreter. If not, see <https://www.gnu.org/licenses/>.
]]

local BoolVal <const> = require('value.BoolValue')
local NumberVal <const> = require('value.NumberValue')
local NilVal <const> = require('value.NilValue')
local ObjVal <const> = require('value.ObjValue')

local ValueConstructor <const> = {type = 'ValueConstructor'}
ValueConstructor.__index = ValueConstructor

_ENV = ValueConstructor

local types <const> = {
	VAL_NIL = NilVal,
	VAL_BOOL = BoolVal,
	VAL_NUMBER = NumberVal,
	VAL_OBJ = ObjVal,
}

function ValueConstructor.value(as,type)
	local class <Const> = types[type]
	return class.new(class,as)
end

return ValueConstructor
