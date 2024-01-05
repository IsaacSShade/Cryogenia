local droneFolder = script.Parent
local drone = droneFolder.drone
local droneAttachment = drone.body.droneAttachment
local goal = droneFolder.droneGuide
local goalAttachment = goal.endGoal

local home = nil

local function Find_Home()
	for i, model in pairs(game.Workspace.Buildings:GetChildren()) do
		local droneCapacity = model:FindFirstChild("droneCapacity", true)

		if droneCapacity then
			local droneCount = droneCapacity.Parent.droneCount

			if droneCount.Value < droneCapacity.Value then
				home = model
				return
			end
		end
	end
	
	droneFolder:Destroy() -- Destroy drone if it has no home :(
end

local function Return_To_Home()
	if home.Name == "fabricator" then
		goal.Position = home.PrimaryPart.Position + Vector3.new(-11.2, 32.6, 47.9)
		
		while wait(1) do
			if droneAttachment.CFrame.Position == goalAttachment.CFrame.Position then
				break
			end
		end
		
		goal.Position = goal.Position - Vector3.new(0, 30, 0)
		
		while wait(1) do
			if droneAttachment.CFrame.Position == goalAttachment.CFrame.Position then
				break
			end
		end
		
		droneFolder.Parent = home
	end
end


Find_Home()
Return_To_Home()