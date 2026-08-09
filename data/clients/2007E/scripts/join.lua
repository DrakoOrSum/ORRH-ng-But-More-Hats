-- arguments ---------------------------------------

local threadSleepTime = ...

if threadSleepTime==nil then
	threadSleepTime = 15
end

-- globals -----------------------------------------

client = game:service("NetworkClient")
visit = game:service("Visit")

-- functions ---------------------------------------

function setMessage(message)
	-- todo: animated "..."
	game:SetMessage(message)
end

function showErrorWindow(message)
	game:SetMessage(message)
end

function reportError(err)
	print("***ERROR*** " .. err)
	visit:setUploadUrl("")
	client:disconnect()
	wait(4)
	showErrorWindow("Error: " .. err)
end

-- called when the client connection closes
function onDisconnection(peer, lostConnection)
	if lostConnection then
		showErrorWindow("You have lost the connection to the game")
	else
		showErrorWindow("You have disconnected from the game")
	end
end

function requestCharacter(replicator)
	
	-- prepare code for when the Character appears
	local connection
	connection = player.Changed:connect(function (property)
		if property=="Character" then
			game:ClearMessage()
			connection:disconnect()
		end
	end)
	
	setMessage("Requesting character")
	-- a little delay to give you a chance to prepare:
	wait(1.5)

	local success, err = pcall(function()	
		replicator:RequestCharacter()
		setMessage("Waiting for character")
	end)
	if not success then
		reportError(err)
		return
	end
end

-- called when the client connection is established
function onConnectionAccepted(url, replicator)

	local waitingForMarker = true
	
	local success, err = pcall(function()	
		setMessage("Setting ping")
		visit:setPing("", 300)

		game:SetMessageBrickCount()
		replicator.Disconnection:connect(onDisconnection)
		
		-- Wait for a marker to return before creating the Player
		local marker = replicator:SendMarker()
		
		marker.Received:connect(function()
			waitingForMarker = false
			requestCharacter(replicator)
		end)
	end)
	
	if not success then
		reportError(err)
		return
	end
	
	-- TODO: report marker progress
	
	while waitingForMarker do
		workspace:ZoomToExtents()
		wait(0.5)
	end
end

-- called when the client connection is rejected
function onConnectionRejected()
	showErrorWindow("Please upgrade ROBLOX")
end

-- called when the client connection fails
function onConnectionFailed()
	showErrorWindow("Failed to connect to the Game")
end

-- main ------------------------------------------------------------


local success, err = pcall(function()	

	setMessage("Creating Player")
	player = game:service("Players"):createLocalPlayer({userid})
	player:SetUnder13(false)
	player:SetSuperSafeChat(false)
	
	player.Name = [======[{username}]======]
	player.CharacterAppearance = "{charapp}"	
	visit:setUploadUrl("")

	setMessage("Connecting to Server")
	client.ConnectionAccepted:connect(onConnectionAccepted)
	client.ConnectionRejected:connect(onConnectionRejected)
	client.ConnectionFailed:connect(onConnectionFailed)
	client:connect("{serverip}", {serverport}, 0, threadSleepTime)
end)

if not success then
	reportError(err)
end
