local buildScripts = {}

local droneScripts = require(game.ServerScriptService:FindFirstChild("droneScripts", true))

--Input: The player that's triggering the event, and the building to place
--Output: Moves a ghost building to the player's mouse
function buildScripts.Move_Ghost_Building(player, building)

	local lastValid = true
	local valid = true

	local success, response = pcall(function()
		while not building:FindFirstChild("CLICKED") do
			valid = true

			if game.Workspace.Blueprints:FindFirstChild(building.Name) ~= building then
				for i,model in game.Workspace.Blueprints:GetChildren() do

					if model:IsA("Model") then
						if string.find(model.Name, ("GHOST" .. player.Name)) then
							building = model
						end
					end
				end
			end

			--Finding if there's any parts that intersect
			local frame, scale = building:GetBoundingBox()
			scale -= Vector3.new(0.1, 0.1, 0.1)
			for i,part in game.Workspace:GetPartBoundsInBox(frame, scale) do
				if part:IsDescendantOf(building) == false and part.Name ~= "ignore" then
					valid = false
				end
			end

			--Change colors if the valid status has changed
			if lastValid ~= valid then
				buildScripts.Change_Ghost_Color(building, valid)
			end

			building:PivotTo(CFrame.new(game.ReplicatedStorage.RemoteFunctions.GetMousePosition:InvokeClient(player)))
			game:GetService("RunService").Heartbeat:Wait()
			lastValid = valid
		end
	end)

	if not success then
		--User has either left the game or the building is deleted
		if building then
			building:Destroy()
		end

		warn(response)
		return
	end

	--Ghost building is sitting there and user has just clicked
	--TODO: Play a buzzer soudn to inform player that placement is invalid
	if valid then
		local realName = string.sub(building.Name, 1, string.find(building.Name, " GHOST") - 1)
		building.Name = "BLUEPRINT CONSTRUCTING"
		
		while #game.Workspace.Drones.InactiveDrones:GetChildren() == 0 do
			wait(1)
		end
		
		local drone = game.Workspace.Drones.InactiveDrones:GetChildren()[1]
		droneScripts.Construct(drone, building, realName)
	end
end

--Input: The building ghost to change colors of, and a boolean on whether it's a valid placement or not
--Output: Changes the entire building's colors to be blue or red
function buildScripts.Change_Ghost_Color(building, valid)
	for i,child in pairs (building:GetDescendants()) do

		local proximityPrompt = child:FindFirstChild("ProximityPrompt")
		if proximityPrompt then
			proximityPrompt.Enabled = false
		end

		if child:IsA("MeshPart") then
			if valid then
				child.TextureID = "rbxassetid://12044968766"
			else
				child.TextureID = "rbxassetid://12044968190"
			end

			child.Transparency = 0.2
		end

		if child:IsA("Part") then
			child.CanCollide = false

			if valid then
				child.Color = Color3.fromRGB(34, 80, 78)
			else
				child.Color = Color3.fromRGB(255, 25, 17)
			end

			if child.Transparency ~= 1 then
				child.Transparency = 0.2
			end
		end
	end
end

--Input: The player calling the function, the building name
--Output: Creates a ghost of a building and removes any old ghosts
function buildScripts.Create_Ghost_Building(player, buildingName)
	
	--If the player clicked on a new building to build, remove the ghost of the previous building
	for i,model in game.Workspace.Blueprints:GetChildren() do
		if model:IsA("Model") then
			if string.find(model.Name, "GHOST" .. player.Name) then
				model:Destroy()
			end
		end
	end

	print(buildingName)
	local building = game.ReplicatedStorage.Buildings:FindFirstChild(buildingName):Clone()
	buildScripts.Change_Ghost_Color(building, true)
	building.Name = building.Name .. " GHOST".. player.Name

	
	
	building.Parent = game.Workspace.Blueprints
	buildScripts.Move_Ghost_Building(player, building)
end

--Input: The name of the building to build
--Output: Triggers the Move_Ghost_Building function to stop looping and place a building down
function buildScripts.Trigger_Build(building)
	local stopIndicator = Instance.new("Weld")
	stopIndicator.Name = "CLICKED"
	stopIndicator.Parent = building
end

function buildScripts.Delete_Build(player, building)
	print("destroying")
	local highlight = Instance.new("Highlight")
	highlight.Name = "Destroying"
	highlight.Parent = building
	highlight.FillTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded

	for i = 0, 10, 1 do
		highlight.OutlineColor = Color3.fromRGB(229, 165, 15)
		wait(0.1)
		highlight.OutlineColor = Color3.fromRGB(230, 230, 33)
		wait(0.1)
	end

	building:Destroy()
end

return buildScripts
