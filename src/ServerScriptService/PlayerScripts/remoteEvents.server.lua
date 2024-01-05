local initializationScripts = require(game.ServerScriptService:FindFirstChild("initializationScripts", true))
local tetherScripts = require(game.ServerScriptService:FindFirstChild("tetherScripts", true))
local buildScripts = require(game.ServerScriptService:FindFirstChild("buildScripts", true))

game.ReplicatedStorage.Events.delete.OnServerEvent:Connect(function(player, building)
	buildScripts.Delete_Build(player, building)
end)

game.ReplicatedStorage.Events.createGhost.OnServerEvent:Connect(function(player, buildingName)
	buildScripts.Create_Ghost_Building(player, buildingName)
end)

game.ReplicatedStorage.Events.build.OnServerEvent:Connect(function(player, buildingName)
	buildScripts.Trigger_Build(buildingName)
end)


game.ReplicatedStorage.Events.createTether.OnServerEvent:Connect(tetherScripts.Update_Tether)
game.ReplicatedStorage.Events.breakTether.OnServerEvent:Connect(tetherScripts.Break_Tether)
