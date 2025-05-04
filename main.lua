--[[

	Dysnomia interpreter. interpreter for the Dysnomia programing language.
    Copyright (C) <2025>  github/return5  - chris nichols
    contact me via github or return5_programming@pm.me
     This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

]]

local FileTokenizer <const> = require('tokenizer.FileTokenizer')

local function strToCharArray(str)
	local charArray <const> = {}
	for char in str:gmatch(".") do
		charArray[#charArray + 1] = char
	end
	return charArray
end

--[==  thisis astring == and this is too

local function main()
	local str <const> = '"this is a string" \n--this is a comment'
	local tokens <const> = FileTokenizer.tokenize(strToCharArray(str))
	for i=1,#tokens,1 do
		io.write(i,"::")
		tokens[i]:print()
	end
end


main()
