surf.chatcommands = {}
function surf.addChatCommand(cmd, func)
	surf.chatcommands[cmd] = func
end

surf.addChatCommand("!rtv", function(ply)
	if IsValid(ply) then
		surf.doRTV(ply)
	end
end)

surf.addChatCommand("!rank", function(ply)
	if IsValid(ply) then
		ply.surf._cooldowns['rank'] = ply.surf._cooldowns['rank'] or 0
		if (ply.surf._cooldowns['rank'] >= CurTime()) then
			ply:Notify("Please wait another "..math.ceil(ply.surf._cooldowns['rank'] - CurTime()).." seconds to get your rank!", 0, 5)
			return
		end
		surf.getPlayerRank(ply, function(rank, ply)
			if IsValid(ply) then
				for k,v in pairs(player.GetAll()) do 
					v:ChatNotify(ply:Nick().." is ranked #"..rank.." with "..ply.surf.stats['kills'].." kills!")
				end
			end
		end)
		ply.surf._cooldowns['rank'] = CurTime() + 40
	end
end)

