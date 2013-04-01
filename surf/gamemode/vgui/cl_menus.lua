function surf.showMenu()
	local bp = vgui.Create("DFrame")
		bp:SetSize(600, 400)
		bp:Center()
		bp:SetTitle("Surf")
		bp:MakePopup()

	local men_back = vgui.Create("DPanelList", bp)
		men_back:SetPos(20, 60)
		men_back:SetSize(190, 350)
		men_back:SetSpacing(10)

	local menu_items = {}
		menu_items['Help'] = surf.showHelpMenu
		menu_items['Donate'] = surf.showDonateMenu
		menu_items['Settings'] = surf.showSettingsMenu

	local page = vgui.Create("DPanelList", bp)
		page:SetPos(240, 60)
		page:SetSize(340, 320)

		function page:setPage(func)
			self:Clear(true)
			self:AddItem(func())
		end
	
	for t, func in pairs(menu_items) do
		local but = vgui.Create("DButton")
		but:SetSize(190, 40)
		but:SetText(t)
		but.DoClick = function()
			page:setPage(func)
		end
		
		men_back:AddItem(but)
	end
	page:setPage(surf.showHelpMenu)
end

net.Receive("surf.showMenu", surf.showMenu)

function surf.showHelpMenu()
	local commands = {}
		commands["!rtv"] = "Rock the vote - vote to start a map vote"
		commands["!rank"] = "Displays your current server rank"
		commands["!nominate"] = "Nominate a map for the next votemap"

	local pan = vgui.Create("DPanel")
		pan:SetSize(340, 350)
		pan.Paint = function()
			surface.SetTextColor(surf.color.white)
			surface.SetTextPos(0, 0)
			surface.SetFont("Bebas_24")
			surface.DrawText("Chat Commands")

			local h = 40
			for k,v in pairs(commands) do
				surface.SetFont("Arial_16")
				surface.SetTextPos(0, h)
				surface.DrawText(k.." - "..v)

				h = h + 20
			end
		end
	return pan
end

function surf.showDonateMenu()
	local pan = vgui.Create("DPanel")
		pan:SetSize(340, 350)
		pan.Paint = function()
			surface.SetTextColor(surf.color.white)
			surface.SetTextPos(0, 0)
			surface.SetFont("Bebas_24")
			surface.DrawText("Donate")

			surface.SetFont("Arial_16")
			surface.SetTextPos(0, 40)
			surface.DrawText("Donate coming soon!")
		end
	return pan
end

function surf.showSettingsMenu()
	local pan = vgui.Create("DPanel")
		pan:SetSize(340, 350)
		pan.Paint = function()
			surface.SetTextColor(surf.color.white)
			surface.SetTextPos(0, 0)
			surface.SetFont("Bebas_24")
			surface.DrawText("Settings")

			surface.SetFont("Arial_16")
			surface.SetTextPos(0, 40)
			surface.DrawText("Settings coming soon!")
		end
	return pan
end