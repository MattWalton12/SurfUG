function surf.showTeamMenu(j)
	local bp = vgui.Create("DFrame")
		bp:SetSize(500, 400)
		bp:SetTitle("Welcome to Surf")
		bp:MakePopup()
		bp:Center()
		if j then 
			bp:ShowCloseButton(false)
		end
	local title = vgui.Create("DLabel", bp)
		title:SetFont("Bebas_42")
		title:SetTextColor(surf.color.blue)
		title:SetPos(50, 40)
		title:SetText("Choose a team")
		title:SizeToContents()

	local but_blue = vgui.Create("DButton", bp)
		but_blue:SetPos(50, 100)
		but_blue:SetSize(400, 80)
		but_blue.DoClick = function()
			RunConsoleCommand("surf_chooseteam", "1")
			bp:Close()
		end
		but_blue:SetText("Blue team")

	local but_red = vgui.Create("DButton", bp)
		but_red:SetPos(50, 200)
		but_red:SetSize(400, 80)
		but_red._color = surf.color.red
		but_red.DoClick = function()
			RunConsoleCommand("surf_chooseteam", "2")
			bp:Close()
		end
		but_red:SetText("Red team")

	local but_spectate = vgui.Create("DButton", bp)
		but_spectate:SetPos(50, 300)
		but_spectate:SetSize(400, 50)
		but_spectate.DoClick = function()
			RunConsoleCommand("surf_chooseteam", "1002")
			bp:Close()
		end
		but_spectate:SetText("Spectate")

end

net.Receive("surf.showTeamMenu", function()
	surf.showTeamMenu()
end)

net.Receive("surf.PlayerInitialSpawn", function()
	surf.showTeamMenu(true)
end)