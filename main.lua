local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModulesFolder = ServerScriptService.ServerifyInjector.Modules

local LuaExp = require(ModulesFolder.LuaExp)
local Loadstring = require(ModulesFolder.Loadstring)
local attached = false
local currsessionid = tostring(math.random(1, 2000))

coroutine.wrap(function ()
	local app = LuaExp()
	app.use(LuaExp.json)
	
	-- Handle GET request on "/"
	app.get("/", function (req, res)
		print('Got request to POST on "/"')
		res.status(200).send()
	end)
	
	-- Handle POST request to attach a session
	app.post("/attach", function (req, res)
		local sessionid = req.body['sessionid']
		local username = req.body['user']		
		if sessionid == currsessionid then
			if not attached then
				attached = true
				local player = Players:FindFirstChild(username)
				if player then
					ReplicatedStorage:WaitForChild("ServerifyRemotes"):FindFirstChild("Notify"):FireClient(player, "Attached!")
				else
					print("Player not found: " .. username)
				end
			end
		end
		res.status(200).send()
	end)
	
	-- Handle POST request to execute code
	app.post("/execute", function (req, res)
		local code = req.body['code']
		local username = req.body['user']
		local sessionid = req.body['sessionid']
		if sessionid == currsessionid then
			Loadstring(code)()
			local player = Players:FindFirstChild(username)
			if player then
				ReplicatedStorage:WaitForChild("ServerifyRemotes"):FindFirstChild("Notify"):FireClient(player, "Script Executed")
			else
				print("Player not found: " .. username)
			end
		end
		res.status(200).send()
	end)
	
	-- Start listening to the session
	app.listen("ScriptifySession_".. game.PlaceId.. "_".. currsessionid, function (url)
		print("ScriptifySession listening on ".. url)
		
		for _, plr in pairs(Players:GetPlayers()) do
			plr.Chatted:Connect(function (msg)
				if string.find(msg, "sessionid") then
					ReplicatedStorage:WaitForChild("ServerifyRemotes"):FindFirstChild("Notify"):FireClient(plr, "Session id: ".. currsessionid)
				end
			end)
		end

		Players.PlayerAdded:Connect(function (plr)
			plr.Chatted:Connect(function (msg)
				if string.find(msg, "sessionid") then
					ReplicatedStorage:WaitForChild("ServerifyRemotes"):FindFirstChild("Notify"):FireClient(plr, "Session id: ".. currsessionid)
				end
			end)		
		end)
	end)
end)()
