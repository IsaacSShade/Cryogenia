local inputService = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local character = game.Workspace:WaitForChild(player.Name)
local mouse = player:GetMouse()
mouse.TargetFilter = game.Workspace.Blueprints

local destructionMode = false
local rotating = false

--Input: N/A
--Output: User's mouse's position 
local function Get_Mouse_Position()
	return mouse.Hit.Position
end


-- TODO: Recreate this so that it highlights models the player has their mouse over
local function Highlight_Hits(partsHighlighted, partsNotFound)

	while destructionMode == true do
		wait()
		partsNotFound = table.clone(partsHighlighted)

		for i,part in game.Workspace:GetPartBoundsInBox(CFrame.new(Get_Mouse_Position()), Vector3.new(0.2, 0.2, 0.2)) do
			if part.Parent:IsA("Model") then 
				part = part.Parent
			end

			if game.ReplicatedStorage.Buildings:FindFirstChild(part.Name) then
				if part:FindFirstChild("DestructionHighlight") then
					--If the part is still within bounds it won't be deleted at the end of this while loop run-through
					local index = table.find(partsHighlighted, part)

					if index then
						table.remove(partsNotFound, index)
					end
					break
				else
					--If this model is something punchable (has Health) then add it to the highlights
					if not part:FindFirstChild("Destroying") then
						local highlight = Instance.new("Highlight")
						highlight.Name = "DestructionHighlight"
						highlight.Parent = part
						highlight.FillTransparency = 1
						highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
						highlight.DepthMode = Enum.HighlightDepthMode.Occluded
						table.insert(partsHighlighted, part)
					end

					break
				end
			end
		end

		for i,part in partsNotFound do
			local highlight = part:FindFirstChild("DestructionHighlight")

			if highlight then
				highlight:Destroy()
			end
			table.remove(partsHighlighted, table.find(partsHighlighted, part))
		end
	end

	for i,part in partsHighlighted do
		local highlight = part:FindFirstChild("DestructionHighlight")

		if highlight then
			highlight:Destroy()
		end
	end
end

--Input: Any input provided by the user
--Output: Fires server events depending on what key is pressed
local function On_Input(input)
	if (inputService:GetFocusedTextBox()) then
		return
	end

	if input.KeyCode == Enum.KeyCode.F then
		--TODO: Flashlight
	elseif input.KeyCode == Enum.KeyCode.E then
		--TODO: Inventory, add dropping system and whole UI shebang
	elseif input.KeyCode == Enum.KeyCode.C then
		local gui = player.PlayerGui:WaitForChild("BuildingGUI")

		if gui.Enabled == true then
			gui.Enabled = false
		else
			gui.Enabled = true
		end

	elseif input.KeyCode == Enum.KeyCode.R then --Rotating a building if in build mode
		
		local rotating = true
		for i,model in game.Workspace.Blueprints:GetChildren() do
			
			if model:IsA("Model") then
				if string.find(model.Name, "GHOST" .. player.Name) then
					
					while rotating == true  do
						model.PrimaryPart.CFrame *= CFrame.Angles(0, 1, 0) -- TODO: Test if this works
					end
				end
			end
		end
		
	elseif input.KeyCode == Enum.KeyCode.X then --Toggles ability to destroy buildings
		
		if destructionMode then
			destructionMode = false
		else
			destructionMode = true

			local partsHighlighted = {}
			local partsNotFound = {}

			Highlight_Hits(partsHighlighted, partsNotFound)
		end
	end

end

-- Input: User's unput
-- Output: Stops the rotating loop by changing a variable
local function Input_Ended(input)
	if rotating == true and input.KeyCode == Enum.KeyCode.R then
		rotating = false
	end
end

--Input: N/A
--Output: Build's a building at player's mouse position if there's a blueprint in the workspace
local function Build_Click()
	
	for i,model in game.Workspace.Blueprints:GetChildren() do
		
		if model:IsA("Model") then
			if string.find(model.Name, "GHOST" .. player.Name) then
				game.ReplicatedStorage.Events.build:FireServer(model)
			end
		end
	end
end

--Input: N/A
--Output: Checks if there's a building to destroy and if so then sends a command to the server to delete it
local function Destroy_Click()
	
	if destructionMode then
		for i, part in  game.Workspace:GetPartBoundsInBox(CFrame.new(Get_Mouse_Position()), Vector3.new(0.2, 0.2, 0.2)) do
			if part.Parent:IsA("Model") then
				part = part.Parent
			end

			local highlight = part:FindFirstChild("DestructionHighlight")
			if highlight and not part:FindFirstChild("Destroying") then

				highlight:Destroy()
				game.ReplicatedStorage.Events.delete:FireServer(part)
			end
		end
	end
end

inputService.InputBegan:Connect(On_Input)
mouse.Button1Down:Connect(Build_Click)
mouse.Button1Down:Connect(Destroy_Click)

function game.ReplicatedStorage.RemoteFunctions.GetMousePosition.OnClientInvoke()
	return Get_Mouse_Position()
end
