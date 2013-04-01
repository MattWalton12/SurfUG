function surf.loadPlayerStats(ply)
	if !IsValid(ply) then return end
	surf.mysql.query("SELECT * FROM stats WHERE steamid='"..ply:SteamID().."'", function(d)
		if (d and d[1]) then
			ply.surf.stats = d[1]
		else
			surf.mysql.query("INSERT INTO stats(steamid, name, kills, deaths, rounds, wins, loss, playtime) VALUES('"..ply:SteamID().."', '"..surf.mysql.escape(ply:Nick()).."', 0, 0, 0, 0, 0, 0)", function()
				ply.surf.stats = {kills=0, deaths=0, rounds=0, wins=0, loss=0, playtime=0}
			end)
		end
	end)
end

function surf.getPlayerRank(ply, callback)
	surf.mysql.query("SELECT * FROM stats ORDER BY kills DESC", function(d)
		local i = 1
		for k,v in pairs(d) do
			if (v['steamid'] == ply:SteamID()) then
				callback(i, ply)
				break
			end
			i = i + 1
		end
	end)
end

function surf.savePlayerStats(ply)
	if IsValid(ply) then
		surf.mysql.query("UPDATE stats SET `name`='"..surf.mysql.escape(ply:Nick()).."', `kills`="..ply.surf.stats['kills']..", `deaths`="..ply.surf.stats['deaths']..", `rounds`="..ply.surf.stats['rounds']..", `wins`="..ply.surf.stats['wins']..", `loss`="..ply.surf.stats['loss'].." WHERE steamid='"..ply:SteamID().."'")
	end
end

timer.Create("surf_addplaytime", 60, 0, function()
	for k,v in pairs(player.GetAll()) do
		surf.mysql.query("UPDATE stats SET playtime=playtime+1 WHERE steamid='"..v:SteamID().."'")
	end
end)