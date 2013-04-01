if SERVER then util.AddNetworkString("surf.chatNotify") end
local meta = debug.getregistry().Player

function meta:Notify(text, ty, time)
	surf.addNotification(text, ty, time, self)
end

function meta:ChatNotify(text)
	net.Start("surf.chatNotify")
		net.WriteString(text)
	net.Send(self)
end