local RS = game:GetService('ReplicatedStorage')
local Knit = require(RS:WaitForChild('Knit').Knit)
local UIS = game:GetService('UserInputService')

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass('Humanoid')
local animator = humanoid:FindFirstChildOfClass('Animator')

local PunchController = Knit.CreateController {
	Name = 'PunchController'
}

function PunchController:KnitStart()
	local PunchService = Knit.GetService('PunchService')
	local track = animator:LoadAnimation(script.Animation)
	
	local lastPressed = 0
	
	UIS.InputBegan:Connect(function(inp, proc)
		
		if proc then return end
		if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		
		local now = tick()
		if now - lastPressed < 0.6 then return end
		lastPressed = now
		
		track:Play()
		track:GetMarkerReachedSignal('Hit'):Wait()
		PunchService.OnM1:Fire()
	end)
end

function PunchController:KnitInit()
end

return PunchController