local healthBar = {}

local bar = script.Parent.box
local healthLabel = script.Parent.HealthLabel


--- Server Side Functions ---

-- displays value of health as it changes  --
function healthBar.updateHealthValue(player)

	local health = player:FindFirstChild("Humanoid").Health
	local maxHealth = player:FindFirstChild("MaxHealth").Value --set max health
	local value = health/maxHealth
	local size = UDim2.new(value, 1)

	bar.TweenSize(
		size,
		Enum.EasingDirection.InOut,
		Enum.EasingStyle.Quint,
		0.5,
		true
	)
	healthLabel.Text = health .. "/" .. maxHealth

end

-- creates health bar on screen  
function healthBar.createHealthBar(player)
	local character = game.Workspace:FindFirstChild(player.Name)
	
	-- when health changes
	
	character.Humanoid.Health.Changed:Connect(function()
		healthBar.updateHealthValue(character)
	end)
end


return healthBar
