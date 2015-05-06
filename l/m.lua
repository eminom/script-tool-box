
local CreateValueMaster = require("valuemaster")

local function main()
	local MainState = {
		Idle = 0,
		Attackin = 1,
		Smurtin = 2
	}
	local t = CreateValueMaster(MainState, {_value=MainState.Idle})
	--rint("OK, gen these methods")
	--for k,v in pairs(t) do
	--	print(k,v)
	--end
	--print("t.isIdle =", t.isIdle)
	--print("t.isIdle =", t.isIdle)	
	t:setAttackin()
	local names = {'Idle', 'Attackin', 'Smurtin'}
	for _, v in ipairs(names) do
		print(t["is"..v](t))
	end
	--print(t:isIdle())
	--print(t:isAttackin())
	--print(t:isSmurtin())
end

-- Entries
main()

