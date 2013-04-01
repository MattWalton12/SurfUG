util.AddNetworkString("surf.showTeamMenu")

function surf.teamFull(t)
	local tful = team.NumPlayers(t)
 	local oful

 	if (tful == 0) then
 		return false
 	end 	

 	if (t == surf.TEAM_RED) then
 		oful = team.NumPlayers(surf.TEAM_BLUE)
 	elseif (t == surf.TEAM_BLUE) then
 		oful = team.NumPlayers(surf.TEAM_RED)
 	elseif (t == surf.TEAM_SPECTATE) then
 		return false
 	end

 	return (tful > oful)
 end
 	
function surf.calculateTeam()
	local bn = team.NumPlayers(surf.TEAM_BLUE)
	local rn = team.NumPlayers(surf.TEAM_RED)

	if (bn < rn) then
		return bn
	elseif  (rn < bn) then
		return rn
	else
		return math.random(1, 2)
	end
end

function surf.balanceTeams()
	local bn = team.NumPlayers(surf.TEAM_BLUE)
	local rn = team.NumPlayers(surf.TEAM_RED)

	if (bn == rn) then
		return true
	end

	if ((bn - rn) > 1) then
		for i=1, math.floor((bn -rn) /2) do
			local randply = table.Random(team.GetPlayers(surf.TEAM_BLUE))
			randply:Notify("You have been moved to team red for balance", 1, 3)
			surf.setTeam(randply, surf.TEAM_RED)
		end
	elseif ((rn - bn) > 1) then
		for i=1, math.floor((rn -bn) /2) do
			local randply = table.Random(team.GetPlayers(surf.TEAM_RED))
			randply:Notify("You have been moved to team blue for balance", 1, 3)
			surf.setTeam(randply, surf.TEAM_BLUE)
		end
	end
end

function surf.setTeam(ply, t)
	local res = false
	if (ply:Team() == surf.TEAM_SPECTATOR) then
		ply:KillSilent()
		res = true
	end
	ply:SetTeam(t)
	ply:UnSpectate()
	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetNoDraw(false)
	ply.surf.team = t
	ply:SetNWBool("surf_spectate", false)
	if res then ply:Spawn() end
end

function surf.chooseTeam(ply, t)
	ply.surf._cooldowns['team_change'] = ply.surf._cooldowns['team_change'] or 0
	if (ply.surf._cooldowns['team_change'] >= CurTime()) then
		ply:Notify("Please wait another "..math.ceil(ply.surf._cooldowns['team_change'] - CurTime()).." seconds to change team!", 0, 5)
		return
	end

	if (t == ply:Team()) then
		ply:Notify("You are already on that team!", 0, 3)
		return
	end

	if (t == surf.TEAM_SPECTATOR) then
		surf.setSpectator(ply)
		ply:Notify("You have become a spectator!", 1, 3)
	else
		if (surf.teamFull(t)) then
			ply:Notify("That team is currently full!", 0, 3)
			return
		end

		ply.surf.team = t
		if (ply:Team() != surf.TEAM_SPECTATOR) then 
			ply:Notify("You will change to team "..team.GetName(t).." next round!", 1, 3)
		else
			ply:Notify("You have changed to team "..team.GetName(t), 1, 3)
			ply:KillSilent()
			ply:SetTeam(t)
			ply:SetNWBool("surf_spectate", true)
		end

		ply.surf._cooldowns['team_change'] = CurTime() + 30
	end
end

concommand.Add("surf_chooseteam", function(ply, _, args)
	if IsValid(ply) and args[1] then
		args[1] = tonumber(args[1])
		if (type(args[1]) != "number") or !team.Valid(args[1]) then
			ply:Notify("Invalid team!", 0, 3)
			return
		end
		surf.chooseTeam(ply, args[1])
	end
end)

function surf.setSpectator(ply)
	if !IsValid(ply) then return end
	ply:StripWeapons()
	ply:SetNoDraw(true)
	ply:SetMoveType(MOVETYPE_OBSERVER)

	ply:Spectate(OBS_MODE_ROAMING)
	ply:SetTeam(surf.TEAM_SPECTATOR)
	ply:SetNWBool("surf_spectate", true)
end
	
function surf.doTeam(ply)
	if (!ply.surf or !ply.surf.team) then
		surf.setSpectator(ply)
	else
		surf.setTeam(ply, ply.surf.team)
	end
end

timer.Create("surf.notifySpectators", 20, 0, function()
	for k,v in pairs(team.GetPlayers(surf.TEAM_SPECTATOR)) do
		if IsValid(v) then
			v:Notify("Press F2 to open the team menu", 1, 4)
		end
	end
end)

function surf.updateSpectatorState(ply, back, reset)
	if !IsValid(ply) || !(ply:GetNWBool("surf_spectate")) then return end
	ply.surf._spectate = ply.surf._spectate or 0

	local posplys = {}

	for k,v in pairs(player.GetAll()) do
		if (!v:GetNWBool("surf_spectate")) then
			table.insert(posplys, v)
		end
	end

	if back then
		ply.surf._spectate =  (ply.surf._spectate -1)
	else
		ply.surf._spectate = (ply.surf._spectate + 1)
	end

	if reset then
		ply.surf._spectate = 0
	end

	if (#posplys == 0) then
		ply.surf._spectate = 0
	end

	if (ply.surf._spectate > #posplys) then
		ply.surf._spectate = 0
	end

	if (ply.surf._spectate < 0) then
		ply.surf._spectate = #posplys
	end
	
	if (ply.surf._spectate == 0) then
		ply:SetObserverMode(OBS_MODE_ROAMING)
	else
		if (IsValid(posplys[ply.surf._spectate]) and (posplys[ply.surf._spectate] != ply) and (posplys[ply.surf._spectate]:Team() != surf.TEAM_SPECTATOR)) then
			ply:SetObserverMode(OBS_MODE_CHASE)
			ply:SpectateEntity(posplys[ply.surf._spectate])
		else
			surf.updateSpectatorState(ply, back)
		end
	end
end

concommand.Add("surf_nextspectate", function(ply)
	surf.updateSpectatorState(ply, false)
end)

concommand.Add("surf_prevspectate", function(ply)
	surf.updateSpectatorState(ply, true)
end)


/* -- My debug functions
concommand.Add("teamtest", function()
	for k,v in pairs(player.GetAll()) do
		if v:IsBot() then
			surf.setTeam(v, surf.TEAM_RED)
		end
	end
end)

concommand.Add("killred", function()
	for k,v in pairs(team.GetPlayers(surf.TEAM_RED)) do
		v:Kill()
	end
end)

*/