net.Receive("surf.voteMap", function()
	local maps = net.ReadTable()
	local bp = vgui.Create("DFrame")
		bp:SetSize(200, 300)
		bp:SetPos(15, ScrH() /2 - 150)
		bp:SetTitle("Vote for a map")

	local li = vgui.Create("DPanelList", bp)
		li:SetSize(200, 260)
		li:SetPos(0, 30)
		li:SetSpacing(10)
		li:EnableVerticalScrollbar()

	for _,v in pairs(maps) do
		local but = vgui.Create("DButton")
			but:SetSize(200, 20)
			if (v:lower() == game.GetMap():lower()) then
				but:SetText("Extend current map")
			else
				but:SetText(v:lower())
			end
			but.DoClick = function()
				RunConsoleCommand("surf_votemap", v:lower())
				bp:Close()
			end
		li:AddItem(but)
	end
end)