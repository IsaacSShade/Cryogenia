local droneScripts = require(game.ServerScriptService:FindFirstChild("droneScripts", true))

droneScripts.Find_Home(script.Parent)

if script.Parent ~= nil then
	droneScripts.Return_To_Home(script.Parent)
	script:Destroy()
end