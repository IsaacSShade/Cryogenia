local droneScripts = {}

local flyingHeight = 152
local hoverheight = 10

function droneScripts.Find_Home(droneFolder)
	local home = droneFolder.Home
	
	for i, model in pairs(game.Workspace.Buildings:GetChildren()) do
		local droneCapacity = model:FindFirstChild("droneCapacity", true)

		if droneCapacity then
			local droneCount = droneCapacity.Parent.droneCount

			if droneCount.Value < droneCapacity.Value then
				home.Value = model
				droneCount.Value += 1

				return
			end
		end
	end

	droneFolder:Destroy()-- Destroy drone if it has no home :(
end

function droneScripts.Wait_For_Alignment(droneFolder)
	while wait(1) do
		if not droneFolder then
			return
		end
		
		if (droneFolder.drone.body.droneAttachment.WorldPosition - droneFolder.droneGuide.endGoal.WorldPosition).Magnitude < 0.53 then
			break
		end
	end
end

function droneScripts.Return_To_Home(droneFolder)
	local home = droneFolder.Home
	
	if home.Value == nil or not home.Value:IsDescendantOf(game.Workspace.Buildings) then
		droneScripts.Find_Home(droneFolder)
	end

	if home.Value.Name == "fabricator" then
		local position = home.Value:FindFirstChild("EntranceDronePoint").Position
		droneFolder.droneGuide.CFrame = CFrame.new(position.X, flyingHeight, position.Z)

		droneScripts.Wait_For_Alignment(droneFolder)

		droneFolder.droneGuide.CFrame = CFrame.new(position)

		droneScripts.Wait_For_Alignment(droneFolder)

		droneFolder.Parent = game.Workspace.Drones.InactiveDrones
	end
	
	if home.Value == nil or not home.Value:IsDescendantOf(game.Workspace.Buildings) then
		droneScripts.Find_Home(droneFolder)
	end
	
end

function droneScripts.Exit_Home(droneFolder)
	local home = droneFolder.Home
	
	if not home.Value:IsDescendantOf(game.Workspace.Buildings) then
		droneScripts.Find_Home(droneFolder)
	end
	
	if droneFolder.Parent ~= game.Workspace.Drones.InactiveDrones then
		print("drone not in storage!")
		return
	end

	droneFolder.Parent = game.Workspace.Drones

	if home.Value.Name == "fabricator" then

		droneFolder.droneGuide.CFrame = home.Value:FindFirstChild("ExitDronePoint").CFrame

		droneScripts.Wait_For_Alignment(droneFolder)

		droneFolder.droneGuide.CFrame = CFrame.new(Vector3.new(droneFolder.droneGuide.Position.X, flyingHeight, droneFolder.droneGuide.Position.Z))

		droneScripts.Wait_For_Alignment(droneFolder)
	end
end

function droneScripts.Construct(droneFolder, model, realname)
	droneScripts.Exit_Home(droneFolder)

	droneFolder.droneGuide.CFrame = CFrame.new(Vector3.new(model.PrimaryPart.Position.X, flyingHeight, model.PrimaryPart.Position.Z))

	droneScripts.Wait_For_Alignment(droneFolder)

	droneFolder.droneGuide.CFrame = CFrame.new(model.PrimaryPart.Position + Vector3.new(0, hoverheight, 0))

	droneScripts.Wait_For_Alignment(droneFolder)
	
	droneScripts.Build(realname, model.PrimaryPart.Position)
	droneFolder.droneGuide.CFrame = CFrame.new(Vector3.new(model.PrimaryPart.Position.X, flyingHeight, model.PrimaryPart.Position.Z))
	model:Destroy()

	droneScripts.Wait_For_Alignment(droneFolder)
	droneScripts.Return_To_Home(droneFolder)

end

--Input: The name of the building to build, and the position to place it (Primary Part location)
--Output: Places a builing if not over the capacity
function droneScripts.Build(buildingName, position)

	print("build name is", ("! " .. buildingName .. " !"))
	local building = game.ReplicatedStorage.Buildings:FindFirstChild(buildingName):Clone()

	building:PivotTo(CFrame.new(position))
	building.Parent = game.Workspace.Buildings
end

return droneScripts
