local localPlayer = game.Players.LocalPlayer

local tethered = false
local tetheredTo = nil

---- Functions ----

local function Find_Closest_Part(humanoidRoot)
	local minDistancePart = nil

	for i, part in workspace:GetPartBoundsInRadius(humanoidRoot.Position, 20) do
		local partName = part.Name

		if not part.Parent:IsA("Model") then  -- Requiring the part to be a model
			continue
		end
		
		partName = part.Parent.Name
		if part.Parent and part.Parent:FindFirstChild("primary") then
			part = part.Parent:FindFirstChild("primary")
		else
			part = part.Parent.PrimaryPart
		end
		
			
		if part == minDistancePart then
			continue
		end

		
		if game.ReplicatedStorage.Buildings:FindFirstChild(partName, true) then
			
			if minDistancePart ~= nil then
				if not ( (part.Position - humanoidRoot.Position).magnitude < (minDistancePart.Position - humanoidRoot.Position).magnitude ) then
					continue -- If the part isn't the minimum distance away, continue in the loop and don't replace minDistancePart
				end
			end
			
			minDistancePart = part
			
		end
	end

	return minDistancePart
end

-- Checks if the character is within radius of a tetherable object and then tethers them if so
local function Tether()
	local character = game.Workspace:WaitForChild(localPlayer.Name)
	local humanoidRoot = character:WaitForChild("HumanoidRootPart")

	local part = Find_Closest_Part(humanoidRoot)
	
	if part then 
		print(part.Name)
		if not tethered then
			tethered = true
			tetheredTo = part

			game.ReplicatedStorage.Events.createTether:FireServer(humanoidRoot, part)
		end

		if part ~= tetheredTo then
			tetheredTo = part

			game.ReplicatedStorage.Events.createTether:FireServer(humanoidRoot, part)
		end
		
		return
	end

	if tethered then
		game.ReplicatedStorage.Events.breakTether:FireServer(humanoidRoot)

		tethered = false
	end
end



-- Events --

while true do
	Tether()
	wait(0.3)
end




