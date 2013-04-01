require("mysqloo")

if !mysqloo then
	surf.throwError("MySQLOO Module not installed!")
end

surf.mysql = {}
surf.mysql.cachedq = {}

surf.mysql.config = {}
surf.mysql.config['host'] 	= "127.0.0.1"
surf.mysql.config['user'] 	= "root"
surf.mysql.config['pass'] 	= ""
surf.mysql.config['db'] 	= "surf"

function surf.mysql.connect()
	timer.Destroy("_surf_keep_sql_connection_alive")
	surf.mysql.dbo = mysqloo.connect(surf.mysql.config['host'], surf.mysql.config['user'], surf.mysql.config['pass'], surf.mysql.config['db'])

	surf.mysql.dbo.onConnected = function()
		surf.DebugMessage("Successfully connected to MySQL database")
		surf.mysql.dbo:status()
		for k,v in pairs(surf.mysql.cachedq) do
			surf.mysql.query(v[1], v[2])
			surf.DebugMessage("Ran cached query")
		end

		timer.Create("_surf_keep_sql_connection_alive", 10, 0, function()
			if (#player.GetAll() == 0) then
				if surf.mysql.dbo then
					if (surf.mysql.dbo:status() == mysqloo.DATABASE_NOT_CONNECTED) then
						surf.mysql.connect()
					end
				end
			end
		end)

		surf.mysql.query("CREATE TABLE IF NOT EXISTS stats(steamid varchar(50), name varchar(100), kills int(255), deaths int(255), rounds int(255), wins int(255), loss int(255), playtime int(255))")
		hook.Call("surf.DatabaseConnected", GAMEMODE)
	end
	
	surf.mysql.dbo.onConnectionFailed = function(_, err)
		surf.throwError("Error connecting to MySQL: "..err)
	end

	surf.mysql.dbo:connect()
end

function surf.mysql.query(query, callback)
	if query then
		if !surf.mysql.dbo then
			surf.throwError("Attempted to run a query on non existant database object")
			return
		end
		local q = surf.mysql.dbo:query(query)
		q.onSuccess = function(_, data)
			if (callback) then
				callback(data)
			end
			surf.DebugMessage("Successfully ran MySQL Query, "..query)
		end
		
		q.onError = function(err)
			surf.throwError("SQL Error: "..err)
		end

		q:start()
	end
end

function surf.mysql.escape(str)
	return surf.mysql.dbo:escape(str)
end

surf.mysql.connect()