local EnemyTypes = require(script.Parent.Parent.EnemyTypes)
type Enemy = EnemyTypes.Enemy

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local AnimationFolder = ReplicatedStorage:FindFirstChild("AnimationFolder")

export type EnemyAttack = {
	enemy: Enemy,
}

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

function EnemyAttack.new(enemy: Enemy, Target: Vector3): EnemyAttack
	local self = setmetatable({}, EnemyAttack)

	self.enemy = enemy
	self.Target = Target

	self.Root = self.enemy.spawnedModel.PrimaryPart

	self.range = self.enemy.range or 5

	self.CurrentCombo = 1
	self.MaxCombo = 3

	self.animator = self.enemy.spawnedModel:FindFirstChildOfClass("Humanoid").Animator :: Animator
	self.Animations = {}

	self.HitPlayers = {}

	for _, anim in ipairs(AnimationFolder:GetChildren()) do
		if anim:IsA("Animation") then
			self.Animations[anim.Name] = self.animator:LoadAnimation(anim)
		end
	end

	return self
end

function EnemyAttack:execute()
	if (self.enemy.spawnedModel.PrimaryPart.Position - self.Target).Magnitude <= self.range then
		self.Animations["Attack" .. self.CurrentCombo]:Play()

		self.CurrentCombo += 1
		if self.CurrentCombo > self.MaxCombo then
			self.CurrentCombo = 1
		end

		local hitbox = Instance.new("Part")
		hitbox.Size = Vector3.new(5, 5, 5)
		hitbox.Transparency = 1
		hitbox.CanCollide = false
		hitbox.Anchored = true
		hitbox.CFrame = CFrame.new(GetHitboxPosition(self.enemy))

		hitbox.Parent = workspace

		Debris:AddItem(hitbox, 0.3)

		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { self.enemy.spawnedModel }

		local partsInbound = workspace:GetPartsInPart(hitbox, params)

		for _, part in ipairs(partsInbound) do
			local character = part.Parent
			if character and character:FindFirstChild("Humanoid") then
				local player = game.Players:GetPlayerFromCharacter(character)
				if player and not self.HitPlayers[player] then
					self.HitPlayers[player] = true
					player.Character.Humanoid:TakeDamage(self.enemy.damage)

					task.delay(1, function()
						self.HitPlayers[player] = nil
					end)
				end
			end
		end
	else
		warn("Target is out of range for attack")
	end
end

return EnemyAttack
