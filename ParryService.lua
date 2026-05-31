local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.Knit.Knit)

local gameConfig = require(ReplicatedStorage.Configs.GameConfig)

local ParryService = Knit.CreateService({
	Name = 'ParryService',
	Client = {
		Activate = Knit.CreateSignal(),
		OnParried = Knit.CreateSignal(),
	},
})

local lastPressed = {}

local function getParrying(player:Player)
	local character = player.Character
	if not character then return nil end
	local stats = character:FindFirstChild('Stats')
	return stats and stats:FindFirstChild('Parrying')
end

function ParryService:CheckForParry(player:Player, projectileData:unknown)
	local parrying = getParrying(player)
	
	if parrying and parrying.Value == true then
		self.Client.OnParried:Fire(player)
		
		local ProjectileService = Knit.GetService('ProjectileService')
		ProjectileService:Reflect(projectileData, player)
		
		return true
	end
	
	return false
end

function ParryService:KnitStart()
	self.Client.Activate:Connect(function(player)
		local character = player.Character or player.CharacterAdded:Wait()
		if not character then return end
		local humanoid = character:FindFirstChildOfClass('Humanoid')
		if not humanoid then return end

		local now = tick()
		if now - (lastPressed[player] or 0) < gameConfig.parry_cooldown then return end
		lastPressed[player] = now

		local Parrying = getParrying(player)
		if not Parrying then return end

		task.delay(gameConfig.parry_open_delay, function()
			local p = getParrying(player)
			if not p then return end
			p.Value = true
		end)

		task.delay(gameConfig.parry_close_delay, function()
			local p = getParrying(player)
			if p then p.Value = false end
		end)
	end)
end

function ParryService:KnitInit()
	game.Players.PlayerRemoving:Connect(function(player)
		lastPressed[player] = nil
	end)
end

return ParryService