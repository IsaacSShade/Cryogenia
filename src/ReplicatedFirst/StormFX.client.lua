local WS = game:GetService("Workspace")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Camera = WS.CurrentCamera 

--when character added run the function to create effect
Player.CharacterAdded:Connect(function(Character)
	
	--check for existing StormParts and delete them
	while WS:FindFirstChild("LocalFX"):FindFirstChild("Part") do
		WS:FindFirstChild("LocalFX"):FindFirstChild("Part"):Destroy()
	end
	
	--base part for ParticleEmitter
	local StormPart = Instance.new("Part")
	
	--initialize with properties and parent to Workspace.LocalFX
	StormPart.Transparency = 1
	StormPart.CanCollide = false
	StormPart.CanTouch = false
	StormPart.CanQuery = false
	StormPart.Anchored = true
	StormPart.Parent = WS:FindFirstChild("LocalFX")
	StormPart.Size = Vector3.new(100,100,100)
	
	--parent emitter to part
	local StormFX = script.SnowFX:Clone()
	StormFX.Parent = StormPart
	
	--pivot part to camera
	StormPart:PivotTo(Camera.CFrame)
	
	--while character exists keep sending this part to the camera
	while Character do
		StormPart:PivotTo(Camera.CFrame)
		task.wait(0.1)
	end
	
	--if character is gone then destroy the part
	StormPart:Destroy()
	
end)