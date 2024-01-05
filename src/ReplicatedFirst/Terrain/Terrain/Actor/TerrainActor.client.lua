if game:IsLoaded() == false then game.Loaded:Wait() end

local folder = script:FindFirstAncestorOfClass("Folder")
local terrainChild = folder.Data:FindFirstChild("TerrainData")
local heightChild = folder.Data:FindFirstChild("HeightData")
local materialChild = folder.Data:FindFirstChild("MaterialData")

if terrainChild == nil then return end

local chunkSize = folder.Configuration.ChunkSize.Value
local terrainData = require(terrainChild)
local heightData = {}
local materialData = {}

if heightChild ~= nil then
	for i, child in ipairs(heightChild:GetDescendants()) do
		if child.ClassName ~= "ModuleScript" then continue end
		local data = require(child)
		local position = child:GetAttribute("Position")
		for i = 1, #data, 2 do
			local x = position.X + data[i]
			local zData = data[i + 1]
			if heightData[x] == nil then heightData[x] = {} end
			for j = 1, #zData, 2 do
				local z = position.Y + zData[j]
				local height = zData[j + 1]
				heightData[x][z] = height
			end
		end
	end
end

if materialChild ~= nil then
	for i, child in ipairs(materialChild:GetDescendants()) do
		if child.ClassName ~= "ModuleScript" then continue end
		local data = require(child)
		local position = child:GetAttribute("Position")
		for i = 1, #data, 2 do
			local x = position.X + data[i]
			local zData = data[i + 1]
			if materialData[x] == nil then materialData[x] = {} end
			for j = 1, #zData, 2 do
				local z = position.Y + zData[j]
				local material = zData[j + 1]
				materialData[x][z] = material
			end
		end
	end
end

local materialEnums = {}
for i, enum in ipairs(Enum.Material:GetEnumItems()) do
	materialEnums[enum.Value] = enum
end

local function GetHeight(x, z)
	if heightData[x] == nil then heightData[x] = {} end
	if heightData[x][z] ~= nil then return heightData[x][z] end	
	local height = 0
	for i, data in ipairs(terrainData.noises) do
		local noise = math.noise(x * data[3], data[1], z * data[3])
		height += math.clamp(noise, data[4], data[5]) * data[2]
	end
	height += terrainData.shift
	height = math.clamp(height, terrainData.minimumHeight, terrainData.maximumHeight)
	return height
end

script.Parent.Load.Event:ConnectParallel(function(chunkX, chunkZ)
	local startX = chunkX * chunkSize
	local startZ = chunkZ * chunkSize
	local endX = startX + chunkSize - 1
	local endZ = startZ + chunkSize - 1
	local heights = {}
	local models = {}
	local minimumHeight = math.huge
	local maximumHeight = -math.huge
	for x = startX - 1, endX + 1 do
		heights[x] = {}
		for z = startZ - 1, endZ + 1 do
			local height = GetHeight(x, z)
			minimumHeight = math.min(height, minimumHeight)
			maximumHeight = math.max(height, maximumHeight)
			heights[x][z] = height
		end
	end
	minimumHeight -= terrainData.thickness
	maximumHeight = math.max(maximumHeight, terrainData.waterHeight)
	minimumHeight = math.floor(minimumHeight / 4) * 4
	maximumHeight = math.ceil(maximumHeight / 4) * 4
	local region = Region3.new(Vector3.new(startX * 4, minimumHeight, startZ * 4), Vector3.new(endX * 4 + 4, maximumHeight, endZ * 4 + 4))
	local materials, occupancys = game.Workspace.Terrain:ReadVoxels(region, 4)
	for x = 1, materials.Size.X do
		for z = 1, materials.Size.Z do
			local voxelX = startX + x - 1
			local voxelZ = startZ + z - 1
			local height = heights[voxelX][voxelZ]
			local nMinimumHeight, nMaximumHeight = math.huge, -math.huge
			for nx = voxelX-1, voxelX+1 do
				for nz = voxelZ-1, voxelZ+1 do
					local height = heights[nx][nz]
					nMinimumHeight = math.min(height, nMinimumHeight)
					nMaximumHeight = math.max(height, nMaximumHeight)
				end
			end
			local slope = nMaximumHeight - nMinimumHeight
			local material = nil
			if materialData[voxelX] ~= nil and materialData[voxelX][voxelZ] ~= nil then
				material = materialEnums[materialData[voxelX][voxelZ]]
			else
				for i, materialData in ipairs(terrainData.materials) do
					if height < materialData[2] or height >= materialData[3] then continue end
					if slope < materialData[4] or slope >= materialData[5] then continue end
					material = materialEnums[materialData[1]]
					break
				end
			end
			for i, modelData in ipairs(terrainData.models) do
				if math.fmod(voxelX, modelData[2]) ~= 0 or math.fmod(voxelZ, modelData[2]) ~= 0 then continue end
				if height < modelData[3] or height >= modelData[4] then continue end
				if slope < modelData[5] or slope >= modelData[6] then continue end
				local load = true
				local offset = Vector3.new(0, 0, 0)
				local scale = Vector3.new(1, 1, 1)
				local rotation = Vector3.new(0, 0, 0)
				for i, data in ipairs(modelData[7]) do
					if data[1] == 1 then
						local noise = math.noise(voxelX * data[3], data[2], voxelZ * data[3])
						if noise < data[4] or noise >= data[5] then load = false break end
					elseif data[1] == 2 then
						offset += Vector3.new(data[4] + math.noise(voxelX * data[3], data[2], voxelZ * data[3]) * data[5], 0, 0)
					elseif data[1] == 3 then
						offset += Vector3.new(0, data[4] + math.noise(voxelX * data[3], data[2], voxelZ * data[3]) * data[5], 0)
					elseif data[1] == 4 then
						offset += Vector3.new(0, 0, data[4] + math.noise(voxelX * data[3], data[2], voxelZ * data[3]) * data[5])
					elseif data[1] == 5 then
						scale *= data[4] + math.noise(voxelX * data[3], data[2], voxelZ * data[3]) * data[5]
					elseif data[1] == 6 then
						scale *= Vector3.new(data[4] + math.noise(voxelX * data[3], data[2], voxelZ * data[3]) * data[5], 1, 1)
					elseif data[1] == 7 then
						scale *= Vector3.new(1, data[4] + math.noise(voxelX * data[3], data[2], voxelZ * data[3]) * data[5], 1)
					elseif data[1] == 8 then
						scale *= Vector3.new(1, 1, data[4] + math.noise(voxelX * data[3], data[2], voxelZ * data[3]) * data[5])
					elseif data[1] == 9 then
						rotation += Vector3.new(data[4] + math.noise(voxelX * data[3], data[2], voxelZ * data[3]) * data[5], 0, 0)
					elseif data[1] == 10 then
						rotation += Vector3.new(0, data[4] + math.noise(voxelX * data[3], data[2], voxelZ * data[3]) * data[5], 0)
					elseif data[1] == 11 then
						rotation += Vector3.new(0, 0, data[4] + math.noise(voxelX * data[3], data[2], voxelZ * data[3]) * data[5])
					end
				end
				if load == false then continue end
				if scale.X <= 0 or scale.Y <= 0 or scale.Z <= 0 then continue end
				local data = {
					game.ReplicatedStorage.TerrainModels[modelData[1]],
					CFrame.new(Vector3.new(voxelX * 4, height, voxelZ * 4) + offset) * CFrame.fromOrientation(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z)),
					scale
				}
				table.insert(models, data)
				break
			end
			for y = 1, materials.Size.Y do
				if materials[x][y][z] ~= Enum.Material.Air then continue end
				local yHeight = minimumHeight + y * 4 - 2
				local occupancy = (height - yHeight) / 4
				if occupancy > 0 then
					materials[x][y][z] = material
					occupancys[x][y][z] = occupancy
				else
					occupancy = (terrainData.waterHeight - yHeight) / 4
					if occupancy <= 0 then continue end
					materials[x][y][z] = Enum.Material.Water
					occupancys[x][y][z] = occupancy
				end
			end
		end
	end
	task.synchronize()
	game.Workspace.Terrain:WriteVoxels(region, 4, materials, occupancys)
	if #models == 0 then return end
	local folder = Instance.new("Folder")
	folder.Name = chunkX .. "," .. chunkZ
	folder.Parent = workspace.Terrain
	for i, data in ipairs(models) do
		local clone = data[1]:Clone()
		clone:PivotTo(data[2])
		for i, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("BasePart") == false then continue end
			descendant.PivotOffset += (descendant.PivotOffset.Position * data[3]) - descendant.PivotOffset.Position
			descendant.Position = data[2].Position + (descendant.Position - data[2].Position) * data[3]
			descendant.Size *= data[3]
		end
		clone.Parent = folder
	end
end)

script.Parent.Unload.Event:ConnectParallel(function(chunkX, chunkZ)
	local startX = chunkX * chunkSize
	local startZ = chunkZ * chunkSize
	local endX = startX + chunkSize - 1
	local endZ = startZ + chunkSize - 1
	local minimumHeight = math.huge
	local maximumHeight = -math.huge
	for x = startX - 1, endX + 1 do
		for z = startZ - 1, endZ + 1 do
			local height = GetHeight(x, z)
			minimumHeight = math.min(height, minimumHeight)
			maximumHeight = math.max(height, maximumHeight)
		end
	end
	minimumHeight -= terrainData.thickness
	maximumHeight = math.max(maximumHeight, terrainData.waterHeight)
	minimumHeight = math.floor(minimumHeight / 4) * 4
	maximumHeight = math.ceil(maximumHeight / 4) * 4
	local region = Region3.new(Vector3.new(startX * 4, minimumHeight, startZ * 4), Vector3.new(endX * 4 + 4, maximumHeight, endZ * 4 + 4))
	local materials, occupancys = game.Workspace.Terrain:ReadVoxels(region, 4)
	for x = 1, materials.Size.X do
		for z = 1, materials.Size.Z do
			for y = 1, materials.Size.Y do
				materials[x][y][z] = Enum.Material.Air
				occupancys[x][y][z] = 0
			end
		end
	end
	task.synchronize()
	game.Workspace.Terrain:WriteVoxels(region, 4, materials, occupancys)
	local folder = workspace.Terrain:FindFirstChild(chunkX .. "," .. chunkZ)
	if folder == nil then return end
	folder:Destroy()
end)