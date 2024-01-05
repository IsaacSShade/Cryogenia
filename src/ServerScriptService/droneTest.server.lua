local drone = game.ReplicatedStorage.drone1

local i = 0

while i < 500  do
	i += 1
	local droneClone = drone:Clone()
	droneClone.Parent = game.Workspace.Drones
	
	wait(0.05)
end

