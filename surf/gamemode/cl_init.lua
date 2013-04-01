include("sh_init.lua")

function GM:ForceDermaSkin()
	return "UG"
end

function GM:Think()
	surf.handleSpectateClick()
end

net.Receive("surf.chatNotify", function()
	local text = net.ReadString()
	chat.AddText(surf.color.blue, "[Surf]: ", surf.color.white, text)
end)