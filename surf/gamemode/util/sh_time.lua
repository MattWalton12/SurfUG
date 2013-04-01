function surf.formatTimeR(sec)
	local mins = tostring(math.floor(sec / 60))
	local secs = tostring(sec - (mins * 60))
	
	if (mins:len() == 1) then
		mins = "0"..mins
	end
	
	if (secs:len() == 1) then
		secs = "0"..secs
	end

	return tostring(mins)..":"..tostring(secs)
end