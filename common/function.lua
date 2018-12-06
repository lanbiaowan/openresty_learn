require "string"
local func ={}

function func.split(str,reps )
   local resultStrList = {}
	string.gsub(str,'[^'..reps..']+',function ( w )
		table.insert(resultStrList,w)
	end)
	return resultStrList
end


              

return func