local placeId, port, sleeptime = ...

if port==nil then
	port = 53640
end
if sleeptime==nil then
	sleeptime = 20
end

-- establish this peer as the Server
local ns = game:service("NetworkServer")

--game:GetService("Players"):SetAbuseReportUrl("http://www.roblox.com/AbuseReport/InGameChatHandler.ashx")

-- This code might move to C++
function characterRessurection(player)
	if player.Character then
		local humanoid = player.Character.Humanoid
		humanoid.Died:connect(function() wait(5) player:LoadCharacter() end)
	end
end
game:service("Players").PlayerAdded:connect(function(player)
	print("Player " .. player.userId .. " added")
	characterRessurection(player)
	player.Changed:connect(function(name)
		if name=="Character" then
			characterRessurection(player)
		end
	end)
end)

if placeId~=nil and placeId~=0 then
	-- load the game
	game:load("http://www.roblox.com/Data/Get.ashx?id=" .. placeId)
end
	
-- Now start the connection
ns:start(port, sleeptime) 

game:service("RunService"):run()
