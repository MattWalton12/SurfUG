surf.notifications = {}

net.Receive("surf.addNotification", function()
	local text = net.ReadString()
	local ty = tonumber(net.ReadString())
	local time = tonumber(net.ReadString())

	surf.addNotification(text, ty, time)
	
end)

function surf.addNotification(text, ty, time)
	table.insert(surf.notifications, {text, ty, time, CurTime()})
	print("Surf: "..text)
	surface.PlaySound("garrysmod/balloon_pop_cute.wav")
end

function surf.drawNotifications() 
	local v
	local h = ScrH() - 200
	local w
	for i=1, #surf.notifications do
		v = surf.notifications[i]
		if !v then continue end
		
		if (v[2] == 0) then
			surface.SetDrawColor(surf.color.red)
		else
			surface.SetDrawColor(surf.color.blue)
		end


		surface.SetFont("Bebas_32")

		w, _ = surface.GetTextSize(v[1])

		if (v[5]) then
			local wn = v[5]

			if (!v[6] and !v[7]) then 
				if (v[5] >= (w)) then
					v[6] = true
					timer.Simple(v[3], function()
						if (surf.notifications[i]) then
							surf.notifications[i][7] = true
						end
					end)
				else
					v[5] = wn + (400 * FrameTime())
				end
			end

			if (v[7]) then
				if (v[5] <= 0) then
					surf.notifications[i] = false
				else
					v[5] = v[5] - (400 * FrameTime())
				end
			end



			surface.DrawRect(ScrW() - (wn+ 30), h, 10, 40)

			surface.SetDrawColor(surf.color.black_trans)
			surface.DrawRect(ScrW() - (wn+ 20), h, w+20, 40)

			surface.SetTextColor(surf.color.white)

			surface.SetTextPos(ScrW() - (wn + 10), h + 5)
			surface.DrawText(v[1])

			h = h - 50
		else
			v[5] = 0
		end
	end
end
