local Deb = false

script.Parent.Touched:Connect(function(Part)	
	--check for debounce and other parts in hierarchy
	if Deb then return end
	if Part.Parent:IsA("Accessory") then return end
	--we only want the root part
	if Part.Name ~= "HumanoidRootPart" then return end
	
	--check for humanoid and get player from character
	local Humanoid = Part.Parent:FindFirstChild("Humanoid")
	
	if Humanoid then
		local Player = game.Players:GetPlayerFromCharacter(Humanoid.Parent)
		--send player to target defined by child object value
		local Target = script.Target
		Player.Character:PivotTo(Target.Value.CFrame)
	end
	
end)