local EnemyLootPool = require(script.Parent.EnemyLootPool)
local EnemyLootTableModifiersMod = require(script.Parent.EnemyLootTableModifiers)
local EnemyLootTableModifiers = EnemyLootTableModifiersMod.new()

type LootEntry = { Weight: number?, Amount: number? } | { number }

export type Enemy = {
	name: string,
	health: number,
	damage: number,
	enemyModel: Model,
	lootTable: { [string]: LootEntry },
}

local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(name: string, health: number, damage: number, enemyModel: Model): Enemy
	local self = setmetatable({}, Enemy)

	self.name = name
	self.health = health
	self.damage = damage
	self.enemyModel = enemyModel
	self.lootTable = EnemyLootPool[name] or {}

	return self
end

function Enemy:takeDamage(amount: number)
	self.health -= amount
	if self.health <= 0 then
		self:die()
		print(self.name .. " has been defeated!")
	end
end

function Enemy:die()
	local rolledLoot = {}

	for itemName, lootEntry in self.lootTable do
		local entry = lootEntry :: any
		local weight = entry.Weight or entry[1] or 0
		local amount = entry.Amount or 1

		if math.random() < weight then
			rolledLoot[itemName] = amount
		end
	end

	if math.random() < 0.3 then
		local modifier = EnemyLootTableModifiers:rollModifier()
		if modifier then
			print("Applying modifier: " .. modifier.rarity)
			rolledLoot = EnemyLootTableModifiers:applyModifier(modifier.name, rolledLoot)
			print("Modified loot: ", rolledLoot, "with modifier: ", modifier.name)
		end
	end

	if self.spawnedModel then
		self.spawnedModel:Destroy()
		self.spawnedModel = nil
	end

	print(rolledLoot)
	return rolledLoot
end

function Enemy:Spawn(position: CFrame)
	local clone = self.enemyModel:Clone()

	clone:PivotTo(position)
	clone.Parent = workspace
end

return Enemy
