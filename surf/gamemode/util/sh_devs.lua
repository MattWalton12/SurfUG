surf.devs = {
	"76561198010869532", // [FL] Matt
	"76561198080490518" // [UG] Munch
}

function surf.playerIsDev(ply)
	if (type(ply) == "string") then
		return table.HasValue(surf.devs, ply)
	else
		return table.HasValue(surf.devs, ply:SteamID())
	end
end