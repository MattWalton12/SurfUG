util.AddNetworkString("surf.updateRound")
util.AddNetworkString("surf.roundWon")
util.AddNetworkString("surf.newRoundSound")
surf.cur_round = {}
surf.rounds = 0
surf.score = {}
surf.round_players = {}

timer.Destroy("surf.retryRound")

function surf.newRound()
	if (#player.GetAll() >= 2) and (team.NumPlayers(surf.TEAM_RED) + team.NumPlayers(surf.TEAM_BLUE) >= 2) then
		net.Start("surf.newRoundSound")
		net.Broadcast()
		for k,v in pairs(player.GetAll()) do
			v:KillSilent()
			v:Spawn()
			v:Freeze(true)
			v:SetFrags(0)
		end

		surf.cur_round = {CurTime(), 3}
		surf.balanceTeams()
		surf.score[surf.TEAM_RED] = team.NumPlayers(surf.TEAM_RED)
		surf.score[surf.TEAM_BLUE] = team.NumPlayers(surf.TEAM_BLUE)

		timer.Create("surf.endRound", 240, 1, function()
			surf.endRound()
		end)

		timer.Simple(3, function()
			if surf.refreshMapEntities then surf.refreshMapEntities() end
			surf.cur_round = {CurTime(), 1, false, surf.rounds, surf.getNextMap()}
			for k,v in pairs(player.GetAll()) do
				v:Freeze(false)
			end
			net.Start("surf.updateRound")
				net.WriteTable(surf.cur_round)
			net.Broadcast()
		end)
	else
		surf.cur_round = {CurTime(), -1, false, surf.rounds, surf.getNextMap()}
		timer.Create("surf.retryRound", 10, 1, surf.newRound)
	end

	net.Start("surf.updateRound")
		net.WriteTable(surf.cur_round)
	net.Broadcast()
end

function surf.endRound(ply)
	surf.doRoundWinner(ply)
	surf.rounds = surf.rounds + 1

	local changemap = (surf.rounds >= 10)
	local map = surf.getNextMap()
	surf.cur_round = {CurTime(), 2, changemap, surf.rounds, map}

	net.Start("surf.updateRound")
		net.WriteTable(surf.cur_round)
	net.Broadcast()

	if (changemap) then
		surf.doNextMap()
	else
		timer.Simple(10, surf.newRound)
	end
end

function surf.doRoundWinner(ply)
	local rscore = 0
	local bscore = 0

	if IsValid(ply) and (ply:Team() == surf.TEAM_RED) then
		rscore = -1
	elseif IsValid(ply) and (ply:Team() == surf.TEAM_BLUE) then
		bscore = -1
	end

	for k,v in pairs(team.GetPlayers(surf.TEAM_RED)) do
		if v:Alive() then
			rscore = rscore + 1
		end
	end

	for k,v in pairs(team.GetPlayers(surf.TEAM_BLUE)) do
		if v:Alive() then
			bscore = bscore + 1
		end
	end

	local wstate
	if (rscore == bscore) then
		wstate = 0 // draw
	elseif (rscore > bscore) then
		wstate = 2 // red won
		team.AddScore(surf.TEAM_RED, 1)
	elseif (bscore > rscore) then
		wstate = 1 // red won
		team.AddScore(surf.TEAM_BLUE, 1)
	end

	for k,v in pairs(player.GetAll()) do
		if !v.surf.stats then continue end
		if (v:Team() == wstate or wstate == 0) then
			v.surf.stats['wins'] = v.surf.stats['wins'] + 1
		else
			v.surf.stats['loss'] = v.surf.stats['loss'] + 1
		end
		v.surf.stats['rounds'] = v.surf.stats['rounds'] + 1

		surf.savePlayerStats(v)
	end

	net.Start("surf.roundWon")
		net.WriteTable({wstate, rscore, bscore, CurTime()})
	net.Broadcast()

	for k,v in pairs(player.GetAll()) do
		v:Notify("New round will begin in 10 seconds", 1, 3)
	end
end

timer.Simple(2, surf.newRound)

function surf.handleRoundDeath(ply)
	local alive = -1
	for k,v in pairs(team.GetPlayers(ply:Team())) do 
		if v:Alive() then
			alive = alive + 1
		end
	end
	
	if (alive == 0) then
		surf.endRound(ply)
	end
end