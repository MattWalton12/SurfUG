/*
	Surf - UrbanGamers.net
	Developed by Matt-Walton.net
*/

GM.Name = "Surf"
GM.Version = "0.01a"
GM.Author = "Matt-Walton.net"
GM.Website = "urbangamers.net"

surf = {}
surf.Debug = true
surf.DevMode = false

// Debug print function
function surf.DebugMessage(text)
	if (surf.Debug) then
		MsgC(Color(0, 255, 100), "[Surf Debug]: "..text.."\n")
	end
end

function surf.throwError(error)
	MsgC(Color(255, 50, 50), "[Surf Error]: "..error.."\n")
end

surf.DebugMessage("Loading "..GM.Name.." version "..GM.Version)

// Include the gamemode files now

local files = file.Find("surf/gamemode/util/*.lua", "LUA")
local prefix
for _, v in pairs(files) do
	prefix = string.Left(v, 3):lower()
	if (prefix == "sh_") then
		if SERVER then
			AddCSLuaFile("util/"..v)
			include("util/"..v)
			surf.DebugMessage("(Serverside) Loaded util/"..v)
		else
			include("util/"..v)
		end
	elseif (prefix == "sv_") then
		if SERVER then
			include("util/"..v)
		end
	elseif (prefix == "cl_") then
		if SERVER then
			AddCSLuaFile("util/"..v)
		else
			include("util/"..v)
		end
	end
end


local files = file.Find("surf/gamemode/modules/*.lua", "LUA")
local prefix
for _, v in pairs(files) do
	prefix = string.Left(v, 3):lower()
	if (prefix == "sh_") then
		if SERVER then
			AddCSLuaFile("modules/"..v)
			include("modules/"..v)
			surf.DebugMessage("(Serverside) Loaded modules/"..v)
		else
			include("modules/"..v)
		end
	elseif (prefix == "sv_") then
		if SERVER then
			include("modules/"..v)
			surf.DebugMessage("(Serverside) Loaded modules/"..v)
		end
	elseif (prefix == "cl_") then
		if SERVER then
			AddCSLuaFile("modules/"..v)
			surf.DebugMessage("(Serverside) Loaded modules/"..v)
		else
			include("modules/"..v)
		end
	end
end


local files = file.Find("surf/gamemode/vgui/*.lua", "LUA")
for _, v in pairs(files) do
	if SERVER then
		AddCSLuaFile("vgui/"..v)
	else
		include("vgui/"..v)
	end
end