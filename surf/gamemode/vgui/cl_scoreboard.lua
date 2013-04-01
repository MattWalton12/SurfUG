function surf.drawScoreBoard()
	surf.scoreboard = vgui.Create("DFrame")
	surf.scoreboard:SetSize(900, ScrH() * 0.65)
	surf.scoreboard:Center()
	surf.scoreboard:SetTitle(" ")

	surf.scoreboard.btnClose.Paint = function() end // Hide em icons
	surf.scoreboard.btnMaxim.Paint = function() end
	surf.scoreboard.btnMinim.Paint = function() end

	surf.scoreboard.btnClose.DoClick = function() end // Hide em icons
	surf.scoreboard.btnMaxim.DoClick = function() end
	surf.scoreboard.btnMinim.DoClick = function() end

	surf.scoreboard.Paint = function(self)
		surface.SetDrawColor(surf.color.blue_a)
		surface.DrawRect(0, 0, 900, 25)

		surface.SetDrawColor(surf.color.black_trans)
		surface.DrawRect(0, 25, 900, ScrH() - 75)

		surface.SetFont("Bebas_122i")
		surface.SetTextColor(surf.color.blue)
		local w,h = surface.GetTextSize("Surf")
		surface.SetTextPos(450 - w/2, 40)
		surface.DrawText("Surf")

		if (#team.GetPlayers(TEAM_SPECTATOR) > 0) then
			surface.SetFont("Arial_14")
			surface.SetTextPos(10, self:GetTall() - 20)
			surface.SetTextColor(surf.color.white)
			local ns = ""
			for k,v in pairs(team.GetPlayers(TEAM_SPECTATOR)) do
				ns = ns..v:Nick()
				if (k != #team.GetPlayers(TEAM_SPECTATOR)) then
					ns = ns.." ,"
				end
			end
			surface.DrawText("Spectators: "..ns)
		end
	end

	surf.scoreboard.playerListBlue = vgui.Create("DPanelList", surf.scoreboard)
	surf.scoreboard.playerListBlue:SetPos(20, 185)
	surf.scoreboard.playerListBlue:SetSize(420, (ScrH() * 0.65) - 200)
	surf.scoreboard.playerListBlue:SetSpacing(10)
	surf.scoreboard.playerListBlue:EnableVerticalScrollbar()


	surf.scoreboard.titlePanel = vgui.Create("DPanel", surf.scoreboard)
	surf.scoreboard.titlePanel:SetSize(860, 20)
	surf.scoreboard.titlePanel:SetPos(20, 170)
	surf.scoreboard.titlePanel.Paint = function()
		surface.SetFont("Arial_14")
		surface.SetTextColor(surf.color.white)

		surface.SetTextPos(30, 0)
		surface.DrawText("Player")

		surface.SetTextPos(300, 0)
		surface.DrawText("Kills")

		surface.SetTextPos(360, 0)
		surface.DrawText("Deaths")
	end

	surf.scoreboard.playerListRed = vgui.Create("DPanelList", surf.scoreboard)
	surf.scoreboard.playerListRed:SetPos(460, 185)
	surf.scoreboard.playerListRed:SetSize(420, (ScrH() * 0.65) - 200)
	surf.scoreboard.playerListRed:SetSpacing(10)
	surf.scoreboard.playerListRed:EnableVerticalScrollbar()

	function surf.scoreboard:Update()
		self.playerListBlue:Clear(true)
		self.playerListRed:Clear(true)

		if (self.playerListBlue.VBar) then
			self.playerListBlue.VBar.Paint = function() end
			self.playerListBlue.VBar.btnUp.Paint = function() end
			self.playerListBlue.VBar.btnDown.Paint = function() end
			self.playerListBlue.VBar.btnGrip.Paint = function() end
		end

		if (self.playerListRed.VBar) then
			self.playerListRed.VBar.Paint = function() end
			self.playerListRed.VBar.btnUp.Paint = function() end
			self.playerListRed.VBar.btnDown.Paint = function() end
			self.playerListRed.VBar.btnGrip.Paint = function() end
		end
		// Sorting out the player tables
		local sply = player.GetAll() 

		for k, ply in pairs(sply) do
			if (ply:Team() == TEAM_SPECTATOR) then
				continue
			end
			local pp = vgui.Create("DButton")
			pp:SetSize(420, 30)
			pp:SetText(" ")
			pp.Paint = function()
				surface.SetDrawColor(team.GetColor(ply:Team()))
				if !ply:Alive() then surface.SetDrawColor(surf.color.gray) end
				surface.DrawRect(0, 0, 420, 30)

				surface.SetTextColor(surf.color.white)
				surface.SetFont("Bebas_24")
				surface.SetTextPos(30, 2)

				surface.DrawText(string.Left(ply:Nick(), 30))

				surface.SetTextPos(300, 2)
				surface.DrawText(ply:Frags())

				surface.SetTextPos(360, 2)
				surface.DrawText(ply:Deaths())
			end
			if (LocalPlayer():Team() != surf.TEAM_SPECTATOR) then
				if (ply:Team() == LocalPlayer():Team()) then self.playerListBlue:AddItem(pp) else self.playerListRed:AddItem(pp) end
			else
				if (ply:Team() == surf.TEAM_RED) then
					self.playerListRed:AddItem(pp)
				elseif (ply:Team() == surf.TEAM_BLUE) then
					self.playerListBlue:AddItem(pp)
				end
			end
		end
	end

	surf.scoreboard:MakePopup()
	surf.scoreboard:Update()
	return surf.scoreboard
end

function GM:ScoreboardShow()
	self.ShowScoreboard = true
	gui.EnableScreenClicker(true)

	if !ValidPanel(self.scoreboardPanel) then
		self.scoreboardPanel = surf.drawScoreBoard()
	else
		self.scoreboardPanel:SetVisible(true)
		self.scoreboardPanel:Update()
	end
end

function GM:ScoreboardHide()
	self.ShowScoreboard = false
	gui.EnableScreenClicker(false)

	if ValidPanel(self.scoreboardPanel) then
		self.scoreboardPanel:SetVisible(false)
	end
end
