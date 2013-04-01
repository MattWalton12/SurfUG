local extensions = {"vtf", "vmt", "png", "ttf", "mdl", "wav", "mp3"}
function surf.SendContentFolder(folder)
	local files, folders = file.Find("gamemodes/surf/content/"..folder.."/*", "GAME")
	for _, v in pairs(files) do
		if (table.HasValue(extensions, string.Right(v, 3):lower())) then
			resource.AddFile(folder.."/"..v)
			surf.DebugMessage("Added "..folder.."/"..v.." to the downloads table")
		end
	end
	
	for _, v in pairs(folders) do
		surf.SendContentFolder(folder.."/"..v)
	end
end

surf.SendContentFolder("models")
surf.SendContentFolder("resource")
surf.SendContentFolder("materials")
surf.SendContentFolder("sound")