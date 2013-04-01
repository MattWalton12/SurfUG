util.AddNetworkString("surf.voteMap")

surf.maps = {}
surf.map_key = 0

function surf.loadMaps()
	if !(file.Exists("surf", "DATA")) then
		file.CreateDir("surf")
		file.Write("surf/maps.txt", "")
		file.Write("surf/map_key.txt", "1")
	end
	local mstr = file.Read("surf/maps.txt", "DATA"):lower()
	local key = file.Read("surf/map_key.txt", "DATA")
	key = tonumber(key)
	surf.map_key = key
	if mstr != "" then
		mstr = string.Explode("\n", mstr)
		surf.maps = mstr
	else
		MsgC(Color(255, 20, 20), "[Surf] NO MAPS IN surf/maps.txt!\n\n")
	end

	for k,v in pairs(surf.maps) do
		if !file.Exists("maps/"..v..".bsp", "MOD") then
			table.remove(surf.maps, k)
			surf.throwError(v.." is not a valid map!")
		end
	end

	if (surf.maps[key]) then
		surf.nextmap = surf.maps[key]
	else
		surf.map_key = 2
		file.Write("surf/map_key.txt", tostring(surf.map_key))
	end
end

function surf.doNextMap()
	if surf.nextmap then
		for k,v in pairs(player.GetAll()) do
			v:Notify("Changing map to "..surf.nextmap.." in 5 seconds!", 1, 3)
		end
		surf.map_key = surf.map_key + 1
		file.Write("surf/map_key.txt", tostring(surf.map_key))

		timer.Simple(5, function()
			game.ConsoleCommand("changelevel "..surf.nextmap.."\n")
		end)
	end
end

function surf.getNextMap()
	return surf.nextmap
end

surf.loadMaps()


/* Votemap stuff */


surf.votemap = {}
surf.votemap.on = false
surf.votemap.votes = {}
surf.nommaps = {}


function surf.startVoteMap()
	if (surf.votemap.on) then return end
	local maps = {}

	if (#surf.maps <= 8) then
		maps = surf.maps
	else
		local rKey = math.random(1, #surf.maps)
		local k = 0
		for i=rKey, rKey+8 do
			if (k >= 8) then
				break
			end
			if surf.maps[i] then
				table.insert(maps, surf.maps[i])
			else
				i = 1
			end
			k = k + 1
		end
	end

	for k,v in pairs(surf.nommaps) do
		if !table.HasValue(maps, v) then
			table.insert(maps, v)
		end
	end

	surf.nommaps = {}
	
	net.Start("surf.voteMap")
		net.WriteTable(maps)
	net.Broadcast()

	for k,v in pairs(player.GetAll()) do
		v:Notify("Vote for the map you wish to play on next!", 1, 3)
	end

	surf.votemap.on = true

	surf.votemap.votes = {}
	surf.votemap.voted = {}

	for k,v in pairs(surf.maps) do
		surf.votemap.votes[v] = 0
	end

	timer.Create("surf.endVoteMap", 45, 1, surf.endVoteMap)
end

function surf.nominateMap(ply, args)
	local map = args[1]
	if !map or map == "" then
		ply:Notify("Invalid map specified!", 0, 3)
		return
	end

	map = map:lower()

	if ply.surf._hasNominated then 
		ply:Notify("You have already nominated a map this game!", 0, 3)
		return
	end
	
	local found = false
	for k,v in pairs(surf.maps) do
		if (v:lower() == map) then
			found = true
			break
		end
	end

	if !found then 
		ply:Notify("That map is not installed on the game server!", 0, 3)
		return
	end

	if surf.votemap.on then
		ply:Notify("A map vote is already in progress!", 0, 3)
		return
	end
	
	local found = false
	for k,v in pairs(surf.nommaps) do
		if (v:lower() == map) then
			found = true
			break
		end
	end

	if found then 
		ply:Notify("That map has already been nominated!", 0, 3)
		return
	end
	
	table.insert(surf.nommaps, map)
	ply.surf._hasNominated = true
	for k,v in pairs(player.GetAll()) do
		v:ChatNotify(ply:Nick().." nominated "..map.." for the next map vote.")
	end
end

surf.addChatCommand("!nominate", surf.nominateMap)

local lastrtv = 0

function surf.endVoteMap()
	local winning = table.GetWinningKey(surf.votemap.votes)
		
	if winning:lower() == game.GetMap():lower() then
		for k,v in pairs(player.GetAll()) do
			v:ChatNotify("Votemap finished, extend current map won with "..surf.votemap.votes[winning].." votes.")
			v:ChatNotify("The current map has been expended by 10 rounds.")
			surf.rounds = surf.rounds - 10
		end
		surf.votemap.on = false
		surf.rtvs = {}
		lastrtv = CurTime() + 300
		return
	end

	for k,v in pairs(player.GetAll()) do
		v:ChatNotify("Votemap finished, "..winning.." won with "..surf.votemap.votes[winning].." votes.")
		v:ChatNotify("The map will change to "..winning.." at the end of the current round.")
	end

	surf.rounds = 10
	surf.nextmap = winning
	local key 
	for k,v in pairs(surf.maps) do 
		if (v:lower() == winning) then
			key = k
			break
		end
	end
	
	if key then 
		surf.map_key = key 
		file.Write("surf/map_key.txt", tostring(key))
	end
	surf.votemap.on = false
end

function surf.voteForMap(ply, _, args)
	local map = args[1]
	if !surf.votemap.on then return end
	if !surf.votemap.votes[map:lower()] then
		ply:Notify("Invalid map specified", 0, 3)
		return
	elseif (table.HasValue(surf.votemap.voted, ply:SteamID())) then
		ply:Notify("You have already voted!", 0, 3)
		return
	end

	for k,v in pairs(player.GetAll()) do
		local ms = map
		if (ms == game.GetMap():lower()) then
			ms = "extend current map"
		end
		v:ChatNotify(ply:Nick().." voted for "..ms)
	end

	ply:Notify("You voted for "..map:lower().."!", 1, 3)

	surf.votemap.votes[map:lower()] = surf.votemap.votes[map:lower()] + 1
	table.insert(surf.votemap.voted, ply:SteamID())
end

concommand.Add("surf_votemap", surf.voteForMap)


surf.rtvs = {}

function surf.doRTV(ply)
	if !IsValid(ply) then return end
	if (surf.votemap.on) then
		ply:Notify("A votemap is currently in progress!", 0, 3)
		return
	end

	if (lastrtv > CurTime()) then
		ply:Notify("Please wait another"..math.ceil(lastrtv - CurTime()).." seconds before doing an RTV.", 0, 3)
		return
	end
	
	if table.HasValue(surf.rtvs, ply:SteamID()) then
		ply:Notify("You have already participated in RTV!", 0, 3)
		return
	end

	table.insert(surf.rtvs, ply:SteamID())
	local needed = math.ceil(#player.GetAll() * 0.75)
	for k,v in pairs(player.GetAll()) do
		v:ChatNotify(ply:Nick().." decided to rock the vote ("..#surf.rtvs.."/"..needed.."). Type !rtv to do the same!")
	end

	if (#surf.rtvs >= needed) then
		surf.rtvs = {}
		lastrtv = CurTime() + 40
		surf.startVoteMap()
	end
end

timer.Create("surf_map_notify", 45, 0, function()
	if surf.rounds >= 9 then 
		for k, v in pairs(player.GetAll()) do
			v:Notify("Next map: "..surf.getNextMap(), 1, 3)
		end
	end
end)


surf.mapents = {}
function surf.handleMapEntities()
	surf.mapents = {}

	for __,ent in pairs(ents.FindByClass("weapon_*")) do
		table.insert(surf.mapents, {ent:GetClass(), ent:GetPos(), ent:GetAngles(), ent:GetModel()})
	end

	for __, ent in pairs(ents.FindByClass("item_*")) do
		table.insert(surf.mapents, {ent:GetClass(), ent:GetPos(), ent:GetAngles(), ent:GetModel()})
	end
end

function surf.refreshMapEntities()
	game.CleanUpMap()

	for _, ent in pairs(ents.FindByClass("weapon_crowbar")) do 
		ent:Remove()
	end
end



