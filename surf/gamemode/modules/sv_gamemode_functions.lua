util.AddNetworkString("surf.PlayerInitialSpawn")
util.AddNetworkString("surf.showMenu")

function GM:CheckPassword(steam)
	if (surf.DevMode) then
		if !surf.playerIsDev(steam) then
			return false, "The server is currently in development mode, please try again later"
		end
	end
end

function GM:InitPostEntity()
	// Surf CVars - Hardcoded :)
	RunConsoleCommand("sv_airaccelerate", 80)
	RunConsoleCommand("sv_sticktoground", 0)
	RunConsoleCommand("sv_alltalk", 1)

	if (surf.DevMode) then
		for i=1, 20 do
			RunConsoleCommand("bot")
		end
	end

	if surf.handleMapEntities then surf.handleMapEntities() end
end

function GM:PlayerInitialSpawn(ply)
	if !IsValid(ply) then return end
	ply.surf = {}
	ply.surf._cooldowns = {}
	surf.setSpectator(ply)
	timer.Simple(1, function()
		if (IsValid(ply)) then
			net.Start("surf.updateRound")
				net.WriteTable(surf.cur_round)
			net.Send(ply)
		end
	end)
end

function GM:PlayerAuthed(ply)
	timer.Simple(1, function()
		net.Start("surf.PlayerInitialSpawn")
		net.Send(ply)

		if surf.loadPlayerStats then surf.loadPlayerStats(ply) end
	end)
end

function GM:PlayerSpawn(ply)
	ply:SetArmor(100)
	ply:SetJumpPower(210)
	self.BaseClass:PlayerSpawn(ply)
	surf.doTeam(ply)
	ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	if (ply:Team() != surf.TEAM_SPECTATOR) then ply:SetNWBool("surf_spectate", false) end
	ply:Give("weapon_mad_knife")
end

function GM:PlayerDeathThink(ply)
	if (ply:GetNWBool("surf_spectate")) then ply:SetMoveType(MOVETYPE_NOCLIP) end
	return false
end

function GM:PlayerNoClip(ply)
	return ply:IsAdmin()
end

function GM:ShowTeam(ply)
	net.Start("surf.showTeamMenu")
	net.Send(ply)
end

function GM:ShowHelp(ply)
	net.Start("surf.showMenu")
	net.Send(ply)
end

function GM:PlayerDeath(ply, weapon, killer)
	if IsValid(ply) then
		self.BaseClass:PlayerDeath(ply, weapon, killer)
		surf.handleRoundDeath(ply)
		ply:SetNWBool("surf_spectate", true)
		if (IsValid(killer) and killer:IsPlayer()) then 
			ply:Spectate(OBS_MODE_CHASE)
			ply:SpectateEntity(killer)
		else
			ply:Spectate(OBS_MODE_ROAMING)
		end
		ply:SetMoveType(MOVETYPE_OBSERVER)

		ply.surf.stats['deaths'] = ply.surf.stats['deaths'] + 1
		if IsValid(killer) and killer:IsPlayer() then killer.surf.stats['kills'] = killer.surf.stats['kills'] + 1 end
		surf.savePlayerStats(ply)
		surf.savePlayerStats(killer)
	end
end

function GM:PlayerSay(ply, text, team)
	local ex = string.Explode(" ", text)
	if (surf.chatcommands[ex[1]:lower()]) then
		local cmd = ex[1]:lower()
		table.remove(ex, 1)
		surf.chatcommands[cmd](ply, ex)
		return ""
	end
	return self.BaseClass:PlayerSay(ply, text, team)
end

function GM:PlayerCanHearPlayersVoice(ply, ply2)
	local pr = self.BaseClass:PlayerCanHearPlayersVoice(ply, ply2)
	if (pr != false) then
		return true
	else
		return pr
	end
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	if IsValid(ply) and IsValid(attacker) and ply:IsPlayer() and attacker:IsPlayer() then
		return ply:Team() != attacker:Team()
	end
	return self.BaseClass:PlayerShouldTakeDamage(ply, attacker)
end

function GM:PlayerCanPickupWeapon(ply, wep)
	if (ply:HasWeapon(wep:GetClass())) then
		return false
	end
	return self.BaseClass:PlayerCanPickupWeapon(ply, wep)
end

function GM:PlayerSelectSpawn(ply)
	if !IsValid(ply) then return end
	local spawns = {}

	if (ply:Team() == surf.TEAM_RED) then
		spawns = ents.FindByClass("info_player_terrorist")
	elseif (ply:Team() == surf.TEAM_BLUE) then
		spawns = ents.FindByClass("info_player_counterterrorist")
	end

	if (#spawns > 0) then
		return table.Random(spawns)
	else
		return self.BaseClass:PlayerSelectSpawn(ply)
	end
end

function GM:EntityTakeDamage(ent, dmginfo)
	if IsValid(ent) and ent:IsPlayer() and dmginfo:IsFallDamage() then
		dmginfo:ScaleDamage(0.2)
	end

	return self.BaseClass:EntityTakeDamage(ent, dmginfo)
end
	