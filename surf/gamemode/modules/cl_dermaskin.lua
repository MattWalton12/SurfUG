local skin = {}

skin.PrintName			= "UG"
skin.Author				= "Matt W"
skin.DermaVersion		= 1
skin.colPropertySheet	= Color(0,0,0,150)

local osk = derma.GetNamedSkin("Default")

skin.Colours = osk.Colours
skin.Colours.Button = {}

skin.Colours.Button.Disabled = Color(190, 190, 190, 255)
skin.Colours.Button.Down = Color(90, 90, 90, 255)
skin.Colours.Button.Hover = Color(90, 90, 90, 255)
skin.Colours.Button.Normal = surf.color.white

function skin:PaintFrame(frame)
	local w,h = frame:GetSize()
	surface.SetDrawColor(surf.color.blue_a)
	surface.DrawRect(0, 0, w, 25)

	surface.SetDrawColor(surf.color.black_trans)
	surface.DrawRect(0, 25, w, h-25)
end



function skin:PaintButton(frame)
	if (frame:GetTall() >= 35) then frame:SetFont("Bebas_32") else frame:SetFont("Bebas_16") end
	if (frame._color) then surface.SetDrawColor(frame._color) else surface.SetDrawColor(surf.color.blue) end
	surface.DrawRect(0,0, frame:GetSize())
end

derma.DefineSkin("UG", "UG Skin", skin)