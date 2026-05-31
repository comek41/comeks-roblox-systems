local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UIS = game:GetService('UserInputService')
local Players = game:GetService('Players')
local tweenService = game:GetService('TweenService')

local Animations = ReplicatedStorage.Assets.Animations
local Sounds = ReplicatedStorage.Assets.Sounds

local Knit = require(ReplicatedStorage.Knit.Knit)
local MiscModule = require(ReplicatedStorage.MiscModule)
local gameConfig = require(ReplicatedStorage.Configs.GameConfig)

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass('Humanoid')
local animator = humanoid:FindFirstChildOfClass('Animator')

local function getRootPart()
	local character = player.Character
	if not character then return nil end
	return character:FindFirstChild('HumanoidRootPart')
end

local ParryController = Knit.CreateController({ Name = 'ParryController' })

function ParryController:KnitStart()
	local ParryService = Knit.GetService('ParryService')
	local track = animator:LoadAnimation(Animations.Parry)
	

	local lastPressed = 0

	UIS.InputBegan:Connect(function(inp, proc)
		if proc then return end
		if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

		local now = tick()
		if now - lastPressed < gameConfig.parry_cooldown then return end
		lastPressed = now

		track:Play()
		ParryService.Activate:Fire()
		
		MiscModule.PlaySFX(Sounds.parry, getRootPart(), true)
	end)
	
	ParryService.OnParried:Connect(function(player)
		MiscModule.PlaySFX(Sounds:WaitForChild('parryparry'), getRootPart(), false)
		MiscModule.PlaySFX(Sounds:WaitForChild('daaaaaamn'), getRootPart(), false)
	end)
end

function ParryController:KnitInit() end

return ParryController