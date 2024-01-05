local WS = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

local droneScripts = require(game.ServerScriptService:FindFirstChild("droneScripts", true))

--clones teleportation script to all parts "PLAYER_TP_PART"
--does not set up the script, just places it in the workspace
--"Target" child object requires setting up when rooms are generated
local function Clone_Teleport()
	
	--loop through workspace to find matching parts
	for i,v in pairs(WS:GetDescendants()) do
		if v:IsA("Part") and v.Name == "PLAYER_TP_PART" and not v:FindFirstChild("PlayerTP") then
			
			--if a part is found clone the script into it
			local ClonedScript = ServerStorage.StartupScripts.PlayerTP:Clone()
			ClonedScript.Parent = v

		end
	end
	
end

local function Verify_Drone_Storage()
	game.Workspace.Buildings.ChildRemoved:Connect(function(child)
		if child.Name == "fabricator" then
			for i, drone in pairs (game.Workspace.Drones.InactiveDrones:GetChildren()) do
				if not drone.Home.Value:IsDescendantOf(game.Workspace.Buildings) then
					droneScripts.Find_Home(drone)
				end
			end
		end
	end)
end
	
--run functions here (ONE TIME at server start)
Clone_Teleport()
Verify_Drone_Storage()