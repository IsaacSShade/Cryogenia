local tetherScripts = {}

---- Server Side Functions ----

-- Lays the foundation for tethers whenever a character spawns in
function tetherScripts.Create_Tether(player)
	local character = game.Workspace:WaitForChild(player.Name)
	local humanoidRoot = character:WaitForChild("HumanoidRootPart")

	local rope = Instance.new("RopeConstraint")
	rope.Name = "rope"
	rope.Parent = humanoidRoot
	rope.Attachment0 = humanoidRoot.RootRigAttachment

	local ropeEnd = Instance.new("Attachment")
	ropeEnd.Name = player.Name .. "-ropeEnd"
	ropeEnd.Parent = game.Workspace.worldCenter
	
	rope.Attachment1 = ropeEnd
	rope.Enabled = true
	rope.Thickness = 0.2
	rope.Color = BrickColor.Gray()
	
	rope.WinchForce = 0
	rope.WinchEnabled = true
	rope.WinchSpeed = 0
end

-- Updates the attachment of the tether for everyone
function tetherScripts.Update_Tether(player, humanoidRoot, part)
	local rope = humanoidRoot.rope
	local ropeEnd = game.Workspace.worldCenter:FindFirstChild(player.Name .."-ropeEnd")
	
	
	ropeEnd.Position = part.Position
	
	if rope.Visible == false then
		rope.Visible = true
	end
end

function tetherScripts.Break_Tether(player, humanoidRoot)
	humanoidRoot.rope.Visible = false
end

function tetherScripts.Delete_Tether(player)
	game.Workspace.worldCenter:FindFirstChild(player.Name .."-ropeEnd"):Destroy()
end

return tetherScripts
