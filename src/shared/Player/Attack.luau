local Debris = game:GetService("Debris")

local function CreateHitbox(cframe: CFrame)
	local hitbox = Instance.new("Part")
	hitbox.Size = Vector3.new(7.5, 7.5, 7.5)
	hitbox.Transparency = 1
	hitbox.CanCollide = false
	hitbox.Anchored = true
	hitbox.CFrame = cframe

	return hitbox
end

local PlayerModule = {}
PlayerModule.__index = PlayerModule

function PlayerModule.new(player)
	local self = setmetatable({}, PlayerModule)

	self.player = player

	return self
end

function PlayerModule:attack()
	local hitbox = CreateHitbox(self.player.Character.PrimaryPart.CFrame * CFrame.new(0, 0, -5))
	hitbox.Parent = workspace

	Debris:AddItem(hitbox, 0.15)

	local parts = workspace:GetPartsInPart(hitbox)
	for _, part in ipairs(parts) do
		local character = part.Parent
		local humanoid = character and character:FindFirstChild("Humanoid")

		if not character:GetTag("Enemy") then
			continue
		end

		if humanoid then
			humanoid:TakeDamage(40)
		end
	end
end

return PlayerModule
