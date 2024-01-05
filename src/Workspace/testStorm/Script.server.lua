local tweenService = game:GetService("TweenService")

local stormIncoming = false
local grassTweenInfo = TweenInfo.new(6.5, Enum.EasingStyle.Linear)
local grassTweenIn = tweenService:Create(game.Workspace, grassTweenInfo, {GlobalWind = Vector3.new(0, 0, 35)})
local grassTweenOut = tweenService:Create(game.Workspace, grassTweenInfo, {GlobalWind = Vector3.new(0, 0, 5)})

game.Workspace:WaitForChild("testStorm", true).Touched:Connect(function(hit)
	if game.Players:FindFirstChild(hit.Parent.Name)and stormIncoming == false then
		stormIncoming = true
		game.ReplicatedStorage.Events.stormTremor:FireAllClients()
		
		grassTweenIn:Play()
		wait(94)
		
		grassTweenOut:Play()
		wait(2)
		stormIncoming = false
	end
end)

