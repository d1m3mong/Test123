local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

if not root then
	return
end

local hasDoubleJumped = false
local Cooldown = false
local isAirborne = false

local function SetupForce()
	local existingForce: BodyVelocity? = root:FindFirstChild("DoubleJumpForce")

	if existingForce then
		existingForce:Destroy()
	end

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
	bodyVelocity.Velocity = Vector3.new(0, 40, 0)
	bodyVelocity.Parent = root
	bodyVelocity.Name = "DoubleJumpForce"

	Debris:AddItem(bodyVelocity, 0.12)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if Cooldown then
		return
	end

	if hasDoubleJumped then
		return
	end

	if not isAirborne then
		return
	end

	if input.KeyCode == Enum.KeyCode.Space then
		Cooldown = true
		SetupForce()

		task.delay(1, function()
			Cooldown = false
		end)
	end
end)

humanoid.StateChanged:Connect(function(_, newState)
	if newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Freefall then
		isAirborne = true
	elseif
		newState == Enum.HumanoidStateType.Landed
		or newState == Enum.HumanoidStateType.Running
		or newState == Enum.HumanoidStateType.RunningNoPhysics
	then
		isAirborne = false
		hasDoubleJumped = false
	end
end)
