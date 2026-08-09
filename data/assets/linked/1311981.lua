print("Vote Kicker 1.0 Loaded")
---------------------------------------------------
-- This script adds the "kick" command to your game.
-- Players can type "kick [player name]" to vote to kick an abusive player.
-- If enough people vote to kick the same person, that person contracts a deadly case of NoTorsoItis
-- There is no cure for NoTorsoItis, even rejoining the game doesn't stop it.
-- The number of votes required to kick a player depends on the number of people in the game.
-- 
-- One cool thing - you don't need to type the player's full name, just enough letters to be sure of who you
-- want to kick.
--
-- For example: if Builderman and Builderdude are in-game, "kick builderm" is enough
-- if Builderman and Telamon are the only people in the game, you can vote to kick both
-- by typing "kick b t"
--
-- Multiple votes from the same person are ignored. As are ambigious votes:
-- Example: Builderman and Builderdude are in-game. "kick bu" is ambigious.
---------------------------------------------------


-- This hack brought to you by Telamon. 

-- If you find bugs in this script, post them to the scripting forum.
-- If you find a bug and change the script to fix it, post your solution in the scripting forum. There is a 500 R$ bonus for each fix.

kickedlist = {}

voteMatrix = {}


function onPlayerEntered(newPlayer)


	local stats = Instance.new("IntValue")
	stats.Name = "punkstats"

	local votes = Instance.new("IntValue")
	votes.Name = "votes"
	votes.Value = 0

	


	votes.Parent = stats


	-- VERY UGLY HACK
	-- Will this leak threads?
	-- Is the problem even what I think it is (player arrived before character)?
	while true do
		if newPlayer.Character ~= nil then break end
		wait(5)
	end

	-- start to listen for new humanoid
	newPlayer.Changed:connect(function(property) onPlayerRespawn(property, newPlayer) end )

	stats.Parent = newPlayer

	newPlayer.Chatted:connect(function(msg, recipient) onChatted(msg, recipient, newPlayer) end) 

	-- make sure this isn't a previously banned player re-entering the game

	for i = 1, #kickedlist do
		if (string.lower(newPlayer.Name) == kickedlist[i]) then
			banish(newPlayer)
		end
	end

end

function getVotesNeeded()
	local np = game.Players.NumPlayers
	
	if np > 10 then return 4 end
	if np > 4   then return 3 end
	return 2
	
end

function onPlayerRespawn(property, player)
	if property == "Character" and player.Character ~= nil then
		local stats = player:findFirstChild("punkstats")
		if (stats ~= nil) then
			if (stats:findFirstChild("banned") ~= nil) then
				punish(player)
			end
		end
	end
end

function banish(player)
	
	local stats = player:findFirstChild("punkstats")
	local votes = stats:findFirstChild("votes")

	if (stats ~= nil and votes ~= nil) then
		
		votes.Value = votes.Value + 1
		if (votes.Value >= getVotesNeeded()) then
			local banned = Instance.new("IntValue")
			banned.Name  = "banned"
			banned.Parent = stats
			local message = Instance.new("Message")
			message.Text = "You caught NoTorsoItis!"
			message.Parent = player
			table.insert(kickedlist, string.lower(player.Name))
			punish(player)
		end
	end

	
end

function punish(player)
	-- called when we think the player has respawned
	while true do
			if player.Character ~= nil then break end
			wait(5)
	end

	player.Character.Torso.Parent = nil
end

function matchPlayer(str)
	-- find all players that start with the str
	-- if there is only one, match it
	-- 0 or 2+, don't match it
	local result = nil

	local players = game.Players:GetPlayers()

	for i = 1,#players do
		if (string.find(string.lower(players[i].Name), str) == 1) then
			if (result ~= nil) then return nil end
			result = players[i]
		end
	end

	return result
end

function voteAgainst(voter, victim)
	-- consult the voteMatrix to see if this guy has voted against that guy before

	-- voter is a string - all lowers
	-- victim is a player

	local votesList = voteMatrix[voter]

	if (votesList ~= nil) then
		local prior = votesList[string.lower(victim.Name)]
		if (prior ~= nil) then
			-- this dude voted against that dude before
			return
		end
	else
		voteMatrix[voter] = {}
	end

	-- insert the record
	voteMatrix[voter][string.lower(victim.Name)] = 1
	
	banish(victim)

end

function onChatted(msg, recipient, speaker)

	-- convert to all lower case

	local source = string.lower(speaker.Name)
	msg = string.lower(msg)

	
	-- vote to kick the following players
	-- "kick telamon buildman wookong"
	if (string.find(msg, "kick") == 1) then --- msg starts with "kick"
		-- words and numbers
		for word in msg:gmatch("%w+") do 
			if word ~= "kick" then
				local p = matchPlayer(word)
				if p ~= nil then
					voteAgainst(source, p)
				end
			end
		end
	end
	

end


game.Players.ChildAdded:connect(onPlayerEntered)