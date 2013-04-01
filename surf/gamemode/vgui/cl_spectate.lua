function surf.drawSpectatorOverlay()
	surface.SetDrawColor(surf.color.black_trans)
	local relx, rely = ScrW() /2 - 200, ScrH() - 50
	surface.DrawRect(ScrW() /2 - 200, ScrH() - 50, 400, 40)

	surface.SetFont("Bebas_32")
	surface.SetTextColor(surf.color.white)

	local w, h = surface.GetTextSize(surf.getSpectateText())
	surface.SetTextPos(relx + (200 - w/2), rely + (20 - h/2))
	surface.DrawText(surf.getSpectateText())
end

function surf.getSpectateText()
	local mode = LocalPlayer():GetObserverMode()
	if (mode == OBS_MODE_ROAMING) then
		return "Free roam spectate"
	else
		if IsValid(LocalPlayer():GetObserverTarget()) then
			local nick = LocalPlayer():GetObserverTarget():Nick() or "ERROR"
			return "Spectating "..nick
		else
			return "error"
		end
	end
end

local cooldown = 0
local clicker = false
function surf.handleSpectateClick()
	if (LocalPlayer():GetNWBool("surf_spectate")) and (cooldown < CurTime()) and !gui.IsConsoleVisible() and !gui.IsGameUIVisible() then
		if (LocalPlayer():KeyDown(IN_ATTACK)) then
			RunConsoleCommand("surf_nextspectate")
			cooldown = CurTime() + 0.3
		elseif (LocalPlayer():KeyDown(IN_ATTACK2)) then
			RunConsoleCommand("surf_prevspectate")
			cooldown = CurTime() + 0.3
		end
	end

	if (input.IsKeyDown(KEY_C) and !gui.IsConsoleVisible() and !gui.IsGameUIVisible()) then
		clicker = true
		gui.EnableScreenClicker(clicker)
	elseif (!gui.IsConsoleVisible() and !gui.IsGameUIVisible()) then
		clicker = false
		gui.EnableScreenClicker(clicker)
	end
end