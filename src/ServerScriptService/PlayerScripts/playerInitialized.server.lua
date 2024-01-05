local initializationScripts = require(game.ServerScriptService:FindFirstChild("initializationScripts", true))
local tetherScripts = require(game.ServerScriptService:FindFirstChild("tetherScripts", true))

--- Gives baseline oxygen, nutrition, temp for players ---
game.Players.PlayerAdded:Connect(function(player)
	
	player.CharacterAdded:Connect(function(character)
		
		initializationScripts.Start_Sounds(player)
		initializationScripts.Initialize(player)
		tetherScripts.Create_Tether(player)
		-- create oxygen bar 
	end)

	player.CharacterRemoving:Connect(function()
		tetherScripts.Delete_Tether(player)
	end)
end)


-- make code for how quickly oxygen runs out normally 

-- increase/decrease nutrition based on consumed items 

-- temperature increase/decrease 