local EnemyTypes = require(script.Parent.Parent.EnemyTypes)
type Enemy = EnemyTypes.Enemy

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local AnimationFolder = ReplicatedStorage:FindFirstChild("AnimationFolder")

export type EnemyAttack = {
	enemy: Enemy,
}

local function GetTargetPosition(target: any): Vector3?
	if typeof(target) == "Vector3" then
		return target
	end

	if typeof(target) == "Instance" then
		if target:IsA("BasePart") then
			return target.Position
		end

		if target:IsA("Model") and target.PrimaryPart then
			return target.PrimaryPart.Position
		end
	end

	if type(target) == "table" and target.Position then
		return target.Position
	end

	return nil
end

local function GetHitboxPosition(enemy: Enemy): Vector3
	if not enemy.spawnedModel or not enemy.spawnedModel.PrimaryPart then
		return Vector3.new(0, 0, 0)
	end

	local HitboxOffset = Vector3.new(0, 0, 2)

	local forwardVector = enemy.spawnedModel.PrimaryPart.CFrame.LookVector

	local hitboxPosition = enemy.spawnedModel.PrimaryPart.Position
		+ forwardVector * HitboxOffset.Z
		+ Vector3.new(0, HitboxOffset.Y, 0)
	return hitboxPosition
end

local EnemyAttack = {}
EnemyAttack.__index = EnemyAttack

function EnemyAttack.new(enemy: Enemy, Target: any): EnemyAttack
	local self = setmetatable({}, EnemyAttack)

	self.enemy = enemy
	self.Target = Target

	self.Root = self.enemy.spawnedModel.PrimaryPart

	self.range = self.enemy.range or 5

	self.CurrentCombo = 1
	self.MaxCombo = 3

	self.animator = self.enemy.spawnedModel:FindFirstChildOfClass("Humanoid").Animator :: Animator
	self.Animations = {}
	self.Connection = nil

	self.HitPlayers = {}

	for _, anim in ipairs(AnimationFolder.Attack.Enemy:GetChildren()) do
		if anim:IsA("Animation") then
			self.Animations[anim.Name] = self.animator:LoadAnimation(anim)
			self.Animations[anim.Name].Priority = Enum.AnimationPriority.Action
		end
	end

	return self
end

function EnemyAttack:execute()
	local targetPosition = GetTargetPosition(self.Target)
	if not targetPosition then
		warn("[EnemyAttack] Invalid target for attack")
		return
	end

	if (self.enemy.spawnedModel.PrimaryPart.Position - targetPosition).Magnitude > self.range then
		warn("Target is out of range for attack")
		return
	end

	local track = self.Animations["Attack" .. self.CurrentCombo]
	if not track then
		warn("[EnemyAttack] Missing animation for combo " .. self.CurrentCombo)
		return
	end

	self.CurrentCombo += 1
	if self.CurrentCombo > self.MaxCombo then
		self.CurrentCombo = 1
	end

	local hitPlayers = {}

	local connection
	connection = track:GetMarkerReachedSignal("Hit"):Connect(function()
		print("Hit marker reached for", self.enemy.name)

		local hitbox = Instance.new("Part")
		hitbox.Size = Vector3.new(7.5, 7.5, 7.5)
		hitbox.Transparency = 1
		hitbox.CanCollide = false
		hitbox.Anchored = true
		hitbox.CFrame = CFrame.new(GetHitboxPosition(self.enemy))
		hitbox.Parent = workspace

		Debris:AddItem(hitbox, 0.15)

		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { self.enemy.spawnedModel }

		local partsInbound = workspace:GetPartsInPart(hitbox, params)

		for _, part in ipairs(partsInbound) do
			local character = part.Parent
			local humanoid = character and character:FindFirstChild("Humanoid")

			if humanoid then
				local player = game.Players:GetPlayerFromCharacter(character)

				if player and not hitPlayers[player] then
					hitPlayers[player] = true
					humanoid:TakeDamage(self.enemy.damage or 10)
				end
			end
		end

		if connection then
			connection:Disconnect()
			connection = nil
		end
	end)

	track:Play()
end

return EnemyAttack
