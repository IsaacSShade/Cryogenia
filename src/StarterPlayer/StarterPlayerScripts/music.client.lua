local tweenService = game:GetService("TweenService")

local player = game.Players.LocalPlayer
local character = game.Workspace:WaitForChild(player.Name)
local ambienceFolder = player.PlayerGui.LocalAudio.Ambience
local musicFolder = player.PlayerGui.LocalAudio.Music

local location = nil
local stormIncoming = false

local shortTime = 1
local longTime = 3

local shortFade = TweenInfo.new(shortTime, Enum.EasingStyle.Linear)
local longFade = TweenInfo.new(longTime, Enum.EasingStyle.Linear)

-- Input: A boolean that says whether we're (true) transitioning into ruin music or (false) getting out of it
-- Output: Changes the sounds to ruin settings or sets them back to normal if exiting ruins
local function ruinChange(starting) 
	local ruinMusic = musicFolder:FindFirstChild("Icy Ruins")
	
	local ambienceTweenIn = tweenService:Create(ambienceFolder.Windstorm3, shortFade, {Volume = 0.1})
	local ambienceTweenOut = tweenService:Create(ambienceFolder.Windstorm3, shortFade, {Volume = 0.2})
	local musicTweenOut = tweenService:Create(ruinMusic, longFade, {Volume = 0})
	
	if starting then
		ambienceTweenIn:Play()
		
		wait(shortTime)
		
		ruinMusic.Playing = true
	else
		ambienceTweenOut:Play()
		musicTweenOut:Play()
		
		wait(longTime)
		
		ruinMusic.Playing = false
		ruinMusic.TimePosition = 0
		ruinMusic.Volume = 0.5
	end
end

-- Input: N/A
-- Output: Changes sounds to storm tremor music and then back to normal
local function stormTremor()
	if stormIncoming == true then
		return
	end
	
	stormIncoming = true
	
	local tremorMusic = musicFolder:FindFirstChild("Storm Incoming")
	local ambience1Tween = tweenService:Create(ambienceFolder.Windstorm1, longFade, {Volume = 0})
	local ambience2Tween = tweenService:Create(ambienceFolder.Windstorm1, longFade, {Volume = 0})
	
	
	
	tremorMusic.TimePosition = 0
	tremorMusic.Playing = true
	
	wait(2)
	ambienceFolder.Windstorm2.Playing = true
	wait(4.4)
	ambienceFolder.Windstorm1.Playing = true
	
	wait(tremorMusic.TimeLength - (2.3 * 2))
	stormIncoming = false
	
	ambience1Tween:Play()
	wait(0.5)
	ambience2Tween:Play()
	
	wait(longTime)
	
	ambienceFolder.Windstorm1.Playing = false
	ambienceFolder.Windstorm2.Playing = false
	ambienceFolder.Windstorm1.Volume = 0.2
	ambienceFolder.Windstorm2.Volume = 0.2
	ambienceFolder.Windstorm1.TimePosition = 0
	ambienceFolder.Windstorm2.TimePosition = 0
	
	
end

-- Checks if player is inside ruins using a bound box 20 studs under the player
local function ruinCheck()
	
	for i, part in workspace:GetPartBoundsInBox(CFrame.new(character.HumanoidRootPart.Position - Vector3.new(0, 10, 0)), Vector3.new(2, 20, 2)) do
		if part.Name == "FLOOR_PRIMARY" then
			if location ~= "ruin" and stormIncoming == false then
				location = "ruin"
				ruinChange(true)
			end
			
			return
		end
	end
		
	if location == "ruin" then
		location = nil
		ruinChange(false)
	end
end

game.ReplicatedStorage.Events.stormTremor.OnClientEvent:Connect(stormTremor)



while wait(0.1) do
	ruinCheck()
end

