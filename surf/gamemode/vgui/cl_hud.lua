function GM:HUDPaint()
	if (LocalPlayer():GetNWBool("surf_spectate") != true) then surf.drawMainHUD() else surf.drawSpectatorOverlay() end
	if surf.drawNotifications then surf.drawNotifications() end
	if surf.drawRounds then surf.drawRounds() end
end

function surf.drawMainHUD()
	surface.SetDrawColor(surf.color.black_trans)
	local relx, rely = 20, ScrH() - 150
	surface.DrawRect(relx, rely, 250, 130)

	surface.SetDrawColor(Color(30, 30, 30, 120))

	surface.DrawRect(relx + 15, rely + 15, 220, 40)
	surface.DrawRect(relx + 15, rely + 75, 220, 40)

	local w = math.Clamp((2.2 * LocalPlayer():Health()), 0, 220)
	surface.SetDrawColor(Color(183, 22, 22, 203))
	surface.DrawRect(relx + 15, rely + 15, w, 40)

	local w = math.Clamp((2.2 * LocalPlayer():Armor()), 0, 220)
	surface.SetDrawColor(surf.color.blue_a)
	surface.DrawRect(relx + 15, rely + 75, w, 40)

	surface.SetTextColor(surf.color.white)
	surface.SetFont("Bebas_32")
	local w, h = surface.GetTextSize("Health")
	surface.SetTextPos(relx + 15 + (220/2 - w/2), rely+ 15 + (20 - h/2) + 2)
	surface.DrawText("Health")

	local w, h = surface.GetTextSize("Armor")
	surface.SetTextPos(relx + 15 + (220/2 - w/2), rely+ 75 + (20 - h/2) + 2)
	surface.DrawText("Armor")	

	if (LocalPlayer():GetActiveWeapon() != nil and LocalPlayer():GetActiveWeapon().Clip1) then
		// Ammo

		surface.SetDrawColor(surf.color.black_trans)
		local relx, rely = ScrW() - 270, ScrH() - 90
		surface.DrawRect(relx, rely, 250, 70)

		surface.SetDrawColor(surf.color.blue_a)
		surface.DrawRect(relx + 15, rely + 15, 220, 40)
		surface.SetFont("Bebas_32")


		local text = LocalPlayer():GetActiveWeapon():Clip1().." / "..LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType())
		local w,h = surface.GetTextSize(text)

		surface.SetTextPos(relx + 15 + (220/2 - w/2), rely + 15 + (20 - h/2) + 2)
		surface.DrawText(text)
	end
end

local nodraw = {"CHudHealth", "CHudBattery", "CHudAmmo"}
function GM:HUDShouldDraw(n)
	if table.HasValue(nodraw, n) then
		return false
	end
	return true
end