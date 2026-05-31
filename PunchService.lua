local RS = game:GetService('ReplicatedStorage')
local Knit = require(RS:WaitForChild('Knit').Knit)
local RunService = game:GetService('RunService')

local PunchService = Knit.CreateService {
	Name = 'PunchService',
	Client = {
		OnM1 = Knit.CreateSignal()
	}
}

local lastPressed = {}

function PunchService.CreateHitbox()
	local hitbox = Instance.new('Part')
	hitbox.Size = Vector3.new(4, 5.5, 2.125)
	hitbox.Material = Enum.Material.ForceField
	hitbox.Transparency = 0.5
	hitbox.CanCollide = false
	hitbox.Anchored = true
	hitbox.Parent = workspace
	return hitbox
end

function PunchService:KnitStart()
	self.Client.OnM1:Connect(function(player)
		local hitPlayers = {}
		
		local character = player.Character
		local humanoid = character:FindFirstChildOfClass('Humanoid')
		local hrp = character:FindFirstChild('HumanoidRootPart')
		
		local now = tick()
		if now - (lastPressed[player] or 0) < 0.6 then return end
		lastPressed[player] = now
		
		local hitbox = PunchService.CreateHitbox()
		local connection
		connection = RunService.Heartbeat:Connect(function()
			if not hrp or not hrp.Parent then 
				connection:Disconnect()
				return
			end
			hitbox.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
		end)

		hitbox.Touched:Connect(function(hit)
			local enemy = hit.Parent
			local enemyHumanoid = enemy:FindFirstChildOfClass('Humanoid')
			if enemyHumanoid then
				if enemy.Name == player.Name then return end
				if hitPlayers[enemy] then return end
				hitPlayers[enemy] = true
				enemyHumanoid:TakeDamage(10)
			end
		end)
		game.Debris:AddItem(hitbox, 0.3)
		task.delay(0.3, function()
			connection:Disconnect()
		end)
	end)
end

function PunchService:KnitInit()
	game.Players.PlayerRemoving:Connect(function(player)
		lastPressed[player] = nil
	end)
end

return PunchService