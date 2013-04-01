include("sh_init.lua")
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("cl_init.lua")

util.AddNetworkString("surf.addNotification")

function surf.addNotification(text, ty, time, ply)
	net.Start("surf.addNotification")
		net.WriteString(text)
		net.WriteString(tostring(ty))
		net.WriteString(tostring(time))
	if IsValid(ply) or (type(ply) == "table") then net.Send(ply) else net.Broadcast() end
end