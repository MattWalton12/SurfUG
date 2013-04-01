surf.cur_round = {}
surf.draw_round = true
surf.round_stats = false

function surf.drawRounds()
	if (surf.draw_round) then
		local rscore = 0
		local bscore = 0

		for _, v in pairs(team.GetPlayers(surf.TEAM_RED)) do
			rscore = rscore + v:Frags()
		end

		for _, v in pairs(team.GetPlayers(surf.TEAM_BLUE)) do
			bscore = bscore + v:Frags()
		end

		surface.SetFont("Bebas_32")
		surface.SetTextColor(surf.color.white)

		local w, h = surface.GetTextSize(surf.getRoundText())

		surface.SetDrawColor(surf.color.black_trans)
		local width = w + 50
		local relx, rely = ScrW() /2 - (width/2), 10
		surface.DrawRect(relx, rely, width, 35)

		surface.SetTextPos(relx + (width /2 - w/2), rely + (35/2 - h/2) +3)
		surface.DrawText(surf.getRoundText())

		if (rscore > bscore) then surface.SetDrawColor(surf.color.red_a) else surface.SetDrawColor(surf.color.blue_a) end
		surface.DrawRect(relx, rely + 35, width, 5)
	end

	if (surf.round_stats) then
		if (surf.cur_round[3] == true) then
			surf.drawGameStats()
		else
			surf.drawRoundStats()
		end
	end
end

function surf.getRoundText()
	if !surf.cur_round or !surf.cur_round[1] or (surf.cur_round[1] == 0) then
		return "Preparing..."
	end
	
	if (surf.cur_round[2] == 1) then
		local time = surf.formatTimeR(240 - (math.ceil(CurTime() - surf.cur_round[1])))
		return tostring(time)
	elseif (surf.cur_round[2] == -1) then
		return "Waiting for players"
	elseif (surf.cur_round[2] == 2) then
		if (surf.cur_round[3]) then
			return "Changing map"
		else
			return "Round end"
		end
	elseif (surf.cur_round[2] == 3) then
		return "Round starting in "..math.abs(math.Clamp(math.ceil(3-(CurTime() - surf.cur_round[1])), 1, 3)).." seconds"
	end
end

net.Receive("surf.updateRound", function()
	surf.cur_round = net.ReadTable()
	if (surf.cur_round[2] == 3) then
		surf.cur_round[1] = surf.cur_round[1] - 0.2
		surf.round_stats = false
	end
end)

net.Receive("surf.newRoundSound", function()
	surface.PlaySound("vo/k_lab/kl_initializing02.wav")
end)

net.Receive("surf.roundWon", function()
	surf.round_stats = net.ReadTable()
end)

function surf.drawRoundStats()
	local relx, rely = ScrW() /2 - 300, ScrH() /2 - 250
	surface.SetDrawColor(surf.color.black_trans)
	surface.DrawRect(relx, rely, 600, 400)

	surface.SetTextColor(surf.color.white)
	surface.SetFont("Bebas_42")
	local w,h = surface.GetTextSize("Round over!")


	surface.SetTextPos(relx + (300 - w/2), rely + 30)
	surface.DrawText("Round over!")

	surface.SetFont("Bebas_38")
	
	surface.SetTextColor(team.GetColor(surf.round_stats[1]))
	local text = team.GetName(surf.round_stats[1]).." won!"
	if surf.round_stats[1] == 0 then
		text = "It's a draw!"
		surface.SetTextColor(surf.color.white)
	end

	local w,h = surface.GetTextSize(text)
	surface.SetTextPos(relx + (300 - w/2), rely + 90)
	surface.DrawText(text)

	surface.SetDrawColor(surf.color.blue)
	surface.DrawRect(relx + 15, rely + 150, 280, 200)

	surface.SetDrawColor(surf.color.red)
	surface.DrawRect(relx + 15 + 280 + 10, rely+ 150, 280, 200)

	surface.SetFont("Bebas_122")
	local w,h = surface.GetTextSize(tostring(team.GetScore(surf.TEAM_BLUE)))
	surface.SetTextPos((relx + 15) + 140 - w/2, rely+150 + (100 - h/2))
	surface.SetTextColor(surf.color.white)
	surface.DrawText(tostring(tostring(team.GetScore(surf.TEAM_BLUE))))

	local w,h = surface.GetTextSize(tostring(team.GetScore(surf.TEAM_RED)))
	surface.SetTextPos((relx + 15 + 280 + 10) + 140 - w/2, rely+150 + (100 - h/2))
	surface.SetTextColor(surf.color.white)
	surface.DrawText(tostring(team.GetScore(surf.TEAM_RED)))

	surface.SetFont("Bebas_24")
	if !surf.cur_round[5] or !surf.cur_round[4] then return end
	local text = "Changing map to "..surf.cur_round[5].." in "..(5 - surf.cur_round[4]).." round(s)"
	local w,h = surface.GetTextSize(text)
	surface.SetTextPos(relx + (300 - w/2), rely + 370)
	surface.SetTextColor(surf.color.white)
	surface.DrawText(text)
end


function surf.drawGameStats()
	local relx, rely = ScrW() /2 - 300, ScrH() /2 - 250
	surface.SetDrawColor(surf.color.black_trans)
	surface.DrawRect(relx, rely, 600, 400)

	surface.SetTextColor(surf.color.white)
	surface.SetFont("Bebas_42")
	local w,h = surface.GetTextSize("Game over!")


	surface.SetTextPos(relx + (300 - w/2), rely + 30)
	surface.DrawText("Game over!")

	surface.SetFont("Bebas_38")

	local winner = 0

	if (team.GetScore(surf.TEAM_RED) > team.GetScore(surf.TEAM_BLUE)) then
		winner = surf.TEAM_RED
	elseif (team.GetScore(surf.TEAM_RED) < team.GetScore(surf.TEAM_BLUE)) then
		winner = surf.TEAM_BLUE
	end
	
	surface.SetTextColor(team.GetColor(winner))
	local text = team.GetName(winner).." won!"
	if winner == 0 then
		text = "It's a draw!"
		surface.SetTextColor(surf.color.white)
	end

	local w,h = surface.GetTextSize(text)
	surface.SetTextPos(relx + (300 - w/2), rely + 90)
	surface.DrawText(text)

	surface.SetDrawColor(surf.color.blue)
	surface.DrawRect(relx + 15, rely + 150, 280, 200)

	surface.SetDrawColor(surf.color.red)
	surface.DrawRect(relx + 15 + 280 + 10, rely+ 150, 280, 200)

	surface.SetFont("Bebas_122")
	local w,h = surface.GetTextSize(tostring(team.GetScore(surf.TEAM_BLUE)))
	surface.SetTextPos((relx + 15) + 140 - w/2, rely+150 + (100 - h/2))
	surface.SetTextColor(surf.color.white)
	surface.DrawText(tostring(tostring(team.GetScore(surf.TEAM_BLUE))))

	local w,h = surface.GetTextSize(tostring(team.GetScore(surf.TEAM_RED)))
	surface.SetTextPos((relx + 15 + 280 + 10) + 140 - w/2, rely+150 + (100 - h/2))
	surface.SetTextColor(surf.color.white)
	surface.DrawText(tostring(team.GetScore(surf.TEAM_RED)))

	surface.SetFont("Bebas_24")
	local text = "Changing map to "..(surf.cur_round[5])
	local w,h = surface.GetTextSize(text)
	surface.SetTextPos(relx + (300 - w/2), rely + 370)
	surface.SetTextColor(surf.color.white)
	surface.DrawText(text)
end
