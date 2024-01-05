workspace.CurrentCamera:GetPropertyChangedSignal("Focus"):Wait()

local folder = script:FindFirstAncestorOfClass("Folder")
local actorAmount = folder.Configuration.ActorAmount.Value
local chunkSize = folder.Configuration.ChunkSize.Value
local loadDistance = folder.Configuration.LoadDistance.Value ^ 2 + 1
local unloadDistance = folder.Configuration.UnloadDistance.Value ^ 2 + 1
local chunkAmount = (folder.Configuration.LoadDistance.Value * 2 + 1) ^ 2
local moveDistance = chunkSize * 4 ^ 2
local positionX = math.huge
local positionZ = math.huge
local selectedActor = nil
local actors = {script.Actor}
local loadedChunks = {}

for i = 2, actorAmount do
	local actor = script.Actor:Clone()
	actor.Parent = script
	table.insert(actors, actor)
end

local function LoadChunk(chunkX, chunkZ)
	if loadedChunks[chunkX] == nil then loadedChunks[chunkX] = {} end
	if loadedChunks[chunkX][chunkZ] ~= nil then return end
	loadedChunks[chunkX][chunkZ] = true
	actors[selectedActor].Load:Fire(chunkX, chunkZ)
	selectedActor += 1
	if selectedActor > actorAmount then task.wait() selectedActor = 1 end
end

local function UnloadChunk(chunkX, chunkZ)
	loadedChunks[chunkX][chunkZ] = nil
	if next(loadedChunks[chunkX]) == nil then loadedChunks[chunkX] = nil end
	actors[selectedActor].Unload:Fire(chunkX, chunkZ)
	selectedActor += 1
	if selectedActor > actorAmount then task.wait() selectedActor = 1 end
end

local function LoadChunks(centerX, centerZ, start)
	local chunkX, chunkZ, directionX, directionZ, count, length = centerX, centerZ, 1, 0, 0, 1
	if start == nil then
		LoadChunk(chunkX, chunkZ)
		start = 2
	end
	for i = start, chunkAmount do
		chunkX += directionX chunkZ += directionZ count += 1
		if count == length then count = 0 directionX, directionZ = -directionZ, directionX if directionZ == 0 then length += 1 end end
		if (chunkX - centerX) ^ 2 + (chunkZ - centerZ) ^ 2 > loadDistance then continue end
		LoadChunk(chunkX, chunkZ)
	end
end

local function UnloadChunks(centerX, centerZ)
	for chunkX, data in pairs(loadedChunks) do
		for chunkZ, value in pairs(data) do
			if (chunkX - centerX) ^ 2 + (chunkZ - centerZ) ^ 2 <= unloadDistance then continue end
			UnloadChunk(chunkX, chunkZ)
		end
	end
end

while true do
	task.wait()
	local focusX, focusZ = workspace.CurrentCamera.Focus.Position.X, workspace.CurrentCamera.Focus.Position.Z
	if (positionX - focusX) ^ 2 + (positionZ - focusZ) ^ 2 < moveDistance then continue end
	positionX, positionZ = focusX, focusZ
	local chunkX, chunkZ = math.floor(positionX / 4 / chunkSize), math.floor(positionZ / 4 / chunkSize)
	selectedActor = 1
	LoadChunks(chunkX, chunkZ)
	if unloadDistance >= loadDistance then UnloadChunks(chunkX, chunkZ) end
end