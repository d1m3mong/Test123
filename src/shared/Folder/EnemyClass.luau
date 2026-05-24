local EnemyLootPool = require(script.Parent.EnemyLootPool)
local EnemyLootTableModifiersMod = require(script.Parent.EnemyLootTableModifiers)
local EnemyLootTableModifiers = EnemyLootTableModifiersMod.new()
local EnemyTypes = require(script.Parent.EnemyTypes)

--ype LootEntry = { Weight: number?, Amount: number? } | { number }
type Enemy = EnemyTypes.Enemy
type LootEntry = EnemyTypes.LootEntry

local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(name: string, health: number, damage: number, range: number, enemyModel: Model): Enemy
	local self = setmetatable({}, Enemy)

	self.name = name
	self.health = health
	self.damage = damage
	self.enemyModel = enemyModel
	self.spawnedModel = nil
	self.lootTable = EnemyLootPool[name] or {}

	return self
end

function Enemy:takeDamage(amount: number)
	self.health -= amount
	if self.health <= 0 then
		local loot = self:die()
		return loot
	end

	return nil
end

function Enemy:die()
	local rolledLoot = {}

	for itemName, lootEntry in self.lootTable do
		local entry = lootEntry :: any
		local weight = entry[1] or 0
		local itemType = entry[2]
		local pictureId = entry[3]
		local amount = entry[4] or 1

		if math.random() < weight then
			rolledLoot[itemName] = {
				amount = amount,
				itemType = itemType,
				pictureId = pictureId,
			}
		end
	end

	for _, data in rolledLoot do
		if data.itemType == "Weapon" then
			if math.random() < 0.9 then
				local modifier = EnemyLootTableModifiers:rollModifier()
				if modifier then
					data.modifier = modifier.name
				end
			end
		end
	end

	if self.spawnedModel then
		self.spawnedModel:Destroy()
		self.spawnedModel = nil
	end

	return rolledLoot
end

function Enemy:Spawn(position: CFrame)
	local clone = self.enemyModel:Clone()

	clone:PivotTo(position)
	clone.Parent = workspace
end

function Enemy:IsAlive(): boolean
	return self.health > 0
end

return Enemy
