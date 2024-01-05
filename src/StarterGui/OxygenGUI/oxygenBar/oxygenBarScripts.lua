local oxygenBar = {}

local bar = script.Parent.box
local oxygenAmount = script.Parent.OxygenLabel
-- seconds to add 1 to oxygen amount when tethered
local addAir = 5 
-- seconds to lose 1 oxygen when not tethered
local loseAir = 5

-- TO DO: connect with GUI bar, create local script that defs maxOxygen, test out 

function oxygenBar.createOxygenBar(player, tetherBool, maxOxygen)
	local character = game.Workspace:FindFirstChild(player.Name)
	local oxygen = player:FindFirstChild("Oxygen").Value
	
	local newOxygenLevel = oxygenAmount.Value
	
	character.oxygen.Value.Changed:Connect(function()
		if tetherBool == true then
			oxygenBar.increaseOxygen(character, maxOxygen, newOxygenLevel)
		else 
			oxygenBar.decreaseOxygen(character, maxOxygen, newOxygenLevel)
		end
	end)
	
	if newOxygenLevel < 1 then 
		character.health = 0
	end

end

function oxygenBar.increaseOxygen(player, maxOxygen, newOxygenLevel)
	-- change color of bar when connected to tether ??

	while wait(addAir) do
		newOxygenLevel = math.clamp(newOxygenLevel + 1, 0, maxOxygen)
	end
end

function oxygenBar.decreaseOxygen(player, maxOxygen, newOxygenLevel)

	while wait(loseAir) do
		newOxygenLevel = math.clamp(newOxygenLevel - 1, 0, maxOxygen)
	end
	
end

return oxygenBar
