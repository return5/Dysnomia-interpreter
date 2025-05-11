local Value <const> = require('value.Value')
local ValTypes <const> = require('value.ValueTypesEnum')

local setmetatable <const> = setmetatable

local BoolValue <const> = {type = ValTypes.VAL_BOOL}
BoolValue.__index = BoolValue

setmetatable(BoolValue,Value)

_ENV = BoolValue

function BoolValue:print()
	return self.as and "true" or "false"
end

function BoolValue:compare(a)
	return a.type == self.type and (a.as and self.as)
end

function BoolValue:new(as)
	return setmetatable(Value:new(as),self)
end

return BoolValue
