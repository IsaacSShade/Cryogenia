local initializationScripts = {}

--- Server Side Functions ---

-- Spawning in - resets attributes to full --
function initializationScripts.Initialize(player)
	for i, part in pairs(game.Workspace:WaitForChild(player.Name):GetChildren()) do
		if part:IsA("MeshPart") or part:IsA("BasePart") then
			part.CollisionGroup = "Players"
		end
	end
	
	local oxygen = Instance.new("IntValue")
	oxygen.Parent = player
	-- born with full oxygen supply (if asthmatic, dock a few?)
	oxygen.Value = 100
	
	local maxHealth = Instance.new("IntValue")
	maxHealth.Parent = player
	-- born with full health (changes based on temp)
	maxHealth.Value = 100
	
	local temperature = Instance.new("IntValue")
	temperature.Parent = player
	-- healthy between 96 - 99
	-- slower functioning (less power, durability, health) as temp decreases
	-- dead below 78 degrees
	temperature.Value = 98.6
	
	local power = Instance.new("IntValue")
	power.Parent = player
	-- max power level changes based on what class of player you are 
	power.Value = 15
	
	local durability = Instance.new("IntValue")
	durability.Parent = player
	-- durability level determines if you can survive a trap or not 
	durability.Value = 20
end

-- Starting ambience sounds
function initializationScripts.Start_Sounds(player)
	game.Workspace:WaitForChild(player.Name)
	local soundFolder = player.PlayerGui:WaitForChild("LocalAudio")
	
	soundFolder.Ambience.Windstorm3.Playing = true
end


return initializationScripts
