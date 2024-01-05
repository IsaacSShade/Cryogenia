local button = script.Parent
local baseModel = button.ViewportFrame:GetChildren()[1]
local player = game.Players.LocalPlayer

button.Activated:Connect(function()
	game.ReplicatedStorage.Events.createGhost:FireServer(baseModel.Name)
end)

